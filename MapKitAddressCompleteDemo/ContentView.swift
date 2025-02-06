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
                    // Main scrollable content:
                    ScrollView {
                        VStack(spacing: 16) {
                            autoDetectSection
                            addressFields
                            defaultAddressToggle
                            saveButton
                        }
                        .padding()
                    }
                    
                    // MARK: - Street Address Overlay
                    if showAutocomplete {
                        VStack(spacing: 0) {
                            // Suggestions list
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 12) {
                                    ForEach(viewModel.searchResults) { result in
                                        Button {
                                            dismissKeyboard()
                                            viewModel.selectSearchResult(result)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                Text(result.title)
                                                    .font(.body)
                                                Text(result.subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
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
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.bottom, keyboardHeight)
                        .padding(.horizontal)
                        .overlay(alignment: .topTrailing) {
                            // Xmark in top trailing
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        showAutocomplete = false
                                    }
                                    // Clear overlay suggestions only
                                    viewModel.searchResults = []
                                }) {
                                    Color.white // tap area
                                        .opacity(0.01)
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
                .navigationTitle("Address")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewModel.clearForm() }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                // Subscribe to keyboard notifications
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                    if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation {
                            // Get the key window from the active window scene
                            if let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                                
                                let safeAreaBottomInset = keyWindow.safeAreaInsets.bottom
                                let keyboardHeight = frame.height - safeAreaBottomInset
                                self.keyboardHeight = keyboardHeight
                                // Now use keyboardHeight as needed
                            } else {
                                // Fallback: if no active window is found, assume no safe area inset
                                let keyboardHeight = frame.height
                                self.keyboardHeight = keyboardHeight
                            }
                            
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation {
                        keyboardHeight = 0
                    }
                }
                // Tap anywhere to reveal the overlay (if there's content to show)
                .onTapGesture {
                    withAnimation { showAutocomplete = true }
                }
                .onChange(of: viewModel.searchResults) { _, newResults in
                    if !newResults.isEmpty {
                        withAnimation {
                            showAutocomplete = true
                        }
                    } else {
                        withAnimation {
                            showAutocomplete = false
                        }
                    }
                    
                }
            }
        }
        
        // MARK: - Dismiss Keyboard
        private func dismissKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
        
        // MARK: - Auto-Detect Section
        private var autoDetectSection: some View {
            VStack(alignment: .leading) {
                Text("Add your address to see local stores")
                    .foregroundStyle(.secondary)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Automatically detect")
                        Text("Enable location access")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $viewModel.form.useAutoDetect)
                        .onChange(of: viewModel.form.useAutoDetect) { _, _ in
                            Task { await viewModel.detectLocation() }
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        
        // MARK: - Address Fields
        private var addressFields: some View {
            VStack(spacing: 12) {
                // Street (overlay suggestions)
                TextField("Street address or P.O. Box", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onTapGesture {
                        withAnimation { showAutocomplete = true }
                        viewModel.refreshStreetSuggestions()
                    }
                
                // City (inline suggestions)
                cityField
                
                // State (inline suggestions)
                stateField
                
                // ZIP
                TextField("ZIP Code", text: $viewModel.form.zipCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
        }
        
        // MARK: - City Field
        private var cityField: some View {
            VStack(alignment: .leading) {
                TextField("City", text: $viewModel.form.city)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.form.city) { _, newValue in
                        Task {
                            guard !viewModel.isAutocompleteFilling else { return }
                            try await viewModel.searchCities(for: newValue, in: viewModel.form.state)
                        }
                    }
                
                // Inline suggestions
                if !viewModel.cityResults.isEmpty {
                    InlineSuggestionsListView(
                        suggestions: viewModel.cityResults,
                        onSelect: { city in
                            viewModel.form.city = city.name
                            // If no state is provided, fill from city’s state
                            if viewModel.form.state.isEmpty {
                                viewModel.form.state = city.state
                            }
                            viewModel.cityResults = []
                        },
                        content: { city in
                            Text("\(city.name), \(city.state)")
                        }
                    )
                }
            }
        }
        
        // MARK: - State Field
        private var stateField: some View {
            VStack(alignment: .leading) {
                TextField("State", text: $viewModel.form.state)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.form.state) { _, newValue in
                        Task {
                            guard !viewModel.isAutocompleteFilling else { return }
                            // If user typed an abbreviation, fill it directly
                            if let state = AddressFormViewModel.states.first(where: {
                                $0.abbreviation.lowercased() == newValue.lowercased()
                            }) {
                                viewModel.form.state = state.name
                                viewModel.stateResults = []
                            } else if !newValue.isEmpty {
                                // Search a partial name or mismatch
                                await viewModel.searchStates(newValue)
                            } else {
                                viewModel.stateResults = []
                            }
                        }
                    }
                
                // Inline suggestions
                if !viewModel.stateResults.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(viewModel.stateResults) { stateItem in
                                Button {
                                    viewModel.stateResults = []
                                    viewModel.form.state = stateItem.name
                                } label: {
                                    HStack {
                                        Text(stateItem.name)
                                        Spacer()
                                        Text(stateItem.abbreviation)
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
        }
        
        // MARK: - Toggles & Buttons
        private var defaultAddressToggle: some View {
            Toggle("Set as default address", isOn: $viewModel.form.isDefault)
        }
        
        private var saveButton: some View {
            Button {
                Task {
                    try await viewModel.save()
                    await MainActor.run { dismiss() }
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
}
