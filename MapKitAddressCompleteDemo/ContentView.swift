import SwiftUI
import CoreLocation
import MapKit

extension UI.Address {
    @MainActor
    struct AddressFormView: View {
        @StateObject private var viewModel: AddressFormViewModel
        @Environment(\.dismiss) private var dismiss
        
        @State private var keyboardHeight: CGFloat = 0
        @State private var showAutocomplete: Bool = false
        
        init() {
            _viewModel = StateObject(wrappedValue: AddressFormViewModel())
        }
        
        var body: some View {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            AutoDetectSection(
                                useAutoDetect: $viewModel.form.useAutoDetect,
                                detectLocation: { await viewModel.detectLocation() }
                            )
                            AddressFields(
                                searchQuery: $viewModel.searchQuery,
                                form: $viewModel.form,
                                cityResults: viewModel.cityResults,
                                stateResults: viewModel.stateResults,
                                refreshStreet: { viewModel.refreshStreetSuggestions() },
                                showAutocomplete: $showAutocomplete,
                                viewModel: viewModel
                            )
                            DefaultAddressToggle(isDefault: $viewModel.form.isDefault)
                            SaveButton {
                                try await viewModel.save()
                                await MainActor.run { dismiss() }
                            }
                        }
                        .padding()
                    }
                    
                    if showAutocomplete {
                        StreetAutocompleteOverlay(
                            results: viewModel.searchResults,
                            keyboardHeight: keyboardHeight,
                            onSelect: { result in
                                dismissKeyboard()
                                viewModel.selectSearchResult(result)
                            },
                            onDismiss: {
                                withAnimation {
                                    showAutocomplete = false
                                    viewModel.searchResults = []
                                }
                            }
                        )
                    }
                }
                .navigationTitle("Address")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .keyboardHandlers(
                    keyboardHeight: $keyboardHeight,
                    showAutocomplete: $showAutocomplete,
                    searchResults: viewModel.searchResults
                )
                .onTapGesture { withAnimation { showAutocomplete = true } }
            }
        }
        
        @ToolbarContentBuilder
        private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.clearForm() }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
            }
        }
        
        private func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
    
    // MARK: - Subviews
    
    private struct AutoDetectSection: View {
        @Binding var useAutoDetect: Bool
        let detectLocation: () async -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Add your address to see local stores")
                    .foregroundStyle(.secondary)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Automatically detect")
                        Text("Enable location access").foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $useAutoDetect)
                        .onChange(of: useAutoDetect) { _, _ in
                            Task { await detectLocation() }
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private struct AddressFields: View {
        @Binding var searchQuery: String
        @Binding var form: UI.Address.AddressForm
        let cityResults: [UI.Address.CityInfo]
        let stateResults: [UI.Address.StateInfo]
        let refreshStreet: () -> Void
        @Binding var showAutocomplete: Bool
        @ObservedObject var viewModel: AddressFormViewModel
        
        var body: some View {
            VStack(spacing: 12) {
                TextField("Street address or P.O. Box", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onTapGesture {
                        withAnimation { showAutocomplete = true }
                        refreshStreet()
                    }
                
                CityField(
                    city: $form.city,
                    state: $form.state,
                    results: cityResults,
                    viewModel: viewModel
                )
                
                StateField(
                    state: $form.state,
                    results: stateResults,
                    viewModel: viewModel
                )
                
                TextField("ZIP Code", text: $form.zipCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
        }
    }
    
    private struct CityField: View {
        @Binding var city: String
        @Binding var state: String
        let results: [UI.Address.CityInfo]
        @ObservedObject var viewModel: AddressFormViewModel
        
        var body: some View {
            VStack(alignment: .leading) {
                TextField("City", text: $city)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: city) { _, newValue in
                        Task {
                            guard !viewModel.isAutocompleteFilling else { return }
                            try await viewModel.searchCities(for: newValue, in: state)
                        }
                    }
                
                if !results.isEmpty {
                    InlineSuggestionsListView(
                        suggestions: results,
                        onSelect: { city in
                            self.city = city.name
                            if state.isEmpty { state = city.state }
                            viewModel.cityResults = []
                        },
                        content: { city in
                            Text("\(city.name), \(city.state)")
                        }
                    )
                }
            }
        }
    }
    
    private struct StateField: View {
        @Binding var state: String
        let results: [UI.Address.StateInfo]
        @ObservedObject var viewModel: AddressFormViewModel
        
        var body: some View {
            VStack(alignment: .leading) {
                TextField("State", text: $state)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: state) { _, newValue in
                        Task {
                            guard !viewModel.isAutocompleteFilling else { return }
                            if let stateItem = AddressFormViewModel.states.first(where: {
                                $0.abbreviation.lowercased() == newValue.lowercased()
                            }) {
                                self.state = stateItem.name
                                viewModel.stateResults = []
                            } else if !newValue.isEmpty {
                                await viewModel.searchStates(newValue)
                            } else {
                                viewModel.stateResults = []
                            }
                        }
                    }
                
                if !results.isEmpty {
                    StateSuggestionsView(
                        results: results,
                        onSelect: { stateItem in
                            viewModel.stateResults = []
                            self.state = stateItem.name
                        }
                    )
                }
            }
        }
    }
    
    private struct StateSuggestionsView: View {
        let results: [UI.Address.StateInfo]
        let onSelect: (UI.Address.StateInfo) -> Void
        
        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(results) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text(item.abbreviation)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: 200)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
        }
    }
    
    private struct DefaultAddressToggle: View {
        @Binding var isDefault: Bool
        
        var body: some View {
            Toggle("Set as default address", isOn: $isDefault)
        }
    }
    
    private struct SaveButton: View {
        let action: () async throws -> Void
        
        var body: some View {
            Button {
                Task {
                    try await action()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private struct StreetAutocompleteOverlay: View {
        let results: [UI.Address.AddressSearchResult]
        let keyboardHeight: CGFloat
        let onSelect: (UI.Address.AddressSearchResult) -> Void
        let onDismiss: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(results) { result in
                            Button {
                                onSelect(result)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(result.title).font(.body)
                                    Text(result.subtitle).font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 200)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
            }
            .padding(.bottom, keyboardHeight)
            .padding(.horizontal)
            .overlay(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Color.white.opacity(0.01)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                    }
                    .padding(.trailing, 22)
                    .padding(.top, -8)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale))
            .zIndex(1)
        }
    }
}

// MARK: - View Modifiers

private extension View {
    func keyboardHandlers(
        keyboardHeight: Binding<CGFloat>,
        showAutocomplete: Binding<Bool>,
        searchResults: [UI.Address.AddressSearchResult]
    ) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        if let windowScene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                            
                            let safeAreaBottomInset = keyWindow.safeAreaInsets.bottom
                            keyboardHeight.wrappedValue = frame.height - safeAreaBottomInset
                        } else {
                            keyboardHeight.wrappedValue = frame.height
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    keyboardHeight.wrappedValue = 0
                }
            }
            .onChange(of: searchResults) { _, newResults in
                withAnimation {
                    showAutocomplete.wrappedValue = !newResults.isEmpty
                }
            }
    }
}
