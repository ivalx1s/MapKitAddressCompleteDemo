import SwiftUI
import CoreLocation
import MapKit

enum UI {
    enum Address { }
}

extension MKLocalSearchCompletion: @retroactive @unchecked Sendable {}
extension MKLocalSearch.Response: @retroactive @unchecked Sendable {}
extension MKLocalSearchCompleter: @retroactive @unchecked Sendable {}
extension CLLocationManager: @retroactive @unchecked Sendable {}
extension CLGeocoder: @retroactive @unchecked Sendable {}

// MARK: - Models
extension UI.Address {
    struct AddressForm: Equatable {
        var street: String = ""
        var city: String = ""
        var state: String = ""
        var zipCode: String = ""
        var isDefault: Bool = false
        var useAutoDetect: Bool = false
    }
    
    struct AddressSearchResult: Identifiable, Hashable, Sendable {
        let id = UUID()
        let title: String
        let subtitle: String
        let completerResult: MKLocalSearchCompletion
        
        init(completerResult: MKLocalSearchCompletion) {
            self.title = completerResult.title
            self.subtitle = completerResult.subtitle
            self.completerResult = completerResult
        }
    }
    
    struct StateInfo: Identifiable, Hashable {
        var id: String { abbreviation }
        let name: String
        let abbreviation: String
        let coordinate: CLLocationCoordinate2D
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(abbreviation)
        }
        
        static func == (lhs: StateInfo, rhs: StateInfo) -> Bool {
            lhs.name == rhs.name && lhs.abbreviation == rhs.abbreviation
        }
        
        static let states: [StateInfo] = [
            .init(name: "Alabama", abbreviation: "AL", coordinate: CLLocationCoordinate2D(latitude: 32.806671, longitude: -86.791130)),
            .init(name: "Alaska", abbreviation: "AK", coordinate: CLLocationCoordinate2D(latitude: 61.370716, longitude: -152.404419)),
            .init(name: "Arizona", abbreviation: "AZ", coordinate: CLLocationCoordinate2D(latitude: 33.729759, longitude: -111.431221)),
            .init(name: "Arkansas", abbreviation: "AR", coordinate: CLLocationCoordinate2D(latitude: 34.969704, longitude: -92.373123)),
            .init(name: "California", abbreviation: "CA", coordinate: CLLocationCoordinate2D(latitude: 36.778259, longitude: -119.417931)),
            .init(name: "Colorado", abbreviation: "CO", coordinate: CLLocationCoordinate2D(latitude: 39.550051, longitude: -105.782067)),
            .init(name: "Connecticut", abbreviation: "CT", coordinate: CLLocationCoordinate2D(latitude: 41.603221, longitude: -73.087749)),
            .init(name: "Delaware", abbreviation: "DE", coordinate: CLLocationCoordinate2D(latitude: 39.318523, longitude: -75.507141)),
            .init(name: "Florida", abbreviation: "FL", coordinate: CLLocationCoordinate2D(latitude: 27.664827, longitude: -81.515754)),
            .init(name: "Georgia", abbreviation: "GA", coordinate: CLLocationCoordinate2D(latitude: 32.165622, longitude: -82.900078)),
            .init(name: "Hawaii", abbreviation: "HI", coordinate: CLLocationCoordinate2D(latitude: 19.896766, longitude: -155.582782)),
            .init(name: "Idaho", abbreviation: "ID", coordinate: CLLocationCoordinate2D(latitude: 44.068203, longitude: -114.742041)),
            .init(name: "Illinois", abbreviation: "IL", coordinate: CLLocationCoordinate2D(latitude: 40.633125, longitude: -89.398528)),
            .init(name: "Indiana", abbreviation: "IN", coordinate: CLLocationCoordinate2D(latitude: 39.766999, longitude: -86.441277)),
            .init(name: "Iowa", abbreviation: "IA", coordinate: CLLocationCoordinate2D(latitude: 41.878003, longitude: -93.097702)),
            .init(name: "Kansas", abbreviation: "KS", coordinate: CLLocationCoordinate2D(latitude: 39.011902, longitude: -98.484246)),
            .init(name: "Kentucky", abbreviation: "KY", coordinate: CLLocationCoordinate2D(latitude: 37.839333, longitude: -84.270018)),
            .init(name: "Louisiana", abbreviation: "LA", coordinate: CLLocationCoordinate2D(latitude: 31.244823, longitude: -92.145024)),
            .init(name: "Maine", abbreviation: "ME", coordinate: CLLocationCoordinate2D(latitude: 45.253783, longitude: -69.445469)),
            .init(name: "Maryland", abbreviation: "MD", coordinate: CLLocationCoordinate2D(latitude: 39.045754, longitude: -76.641273)),
            .init(name: "Massachusetts", abbreviation: "MA", coordinate: CLLocationCoordinate2D(latitude: 42.407211, longitude: -71.382437)),
            .init(name: "Michigan", abbreviation: "MI", coordinate: CLLocationCoordinate2D(latitude: 44.314844, longitude: -85.602364)),
            .init(name: "Minnesota", abbreviation: "MN", coordinate: CLLocationCoordinate2D(latitude: 46.729553, longitude: -94.685900)),
            .init(name: "Mississippi", abbreviation: "MS", coordinate: CLLocationCoordinate2D(latitude: 32.354668, longitude: -89.398528)),
            .init(name: "Missouri", abbreviation: "MO", coordinate: CLLocationCoordinate2D(latitude: 37.964253, longitude: -91.831833)),
            .init(name: "Montana", abbreviation: "MT", coordinate: CLLocationCoordinate2D(latitude: 46.879682, longitude: -110.362566)),
            .init(name: "Nebraska", abbreviation: "NE", coordinate: CLLocationCoordinate2D(latitude: 41.492537, longitude: -99.901813)),
            .init(name: "Nevada", abbreviation: "NV", coordinate: CLLocationCoordinate2D(latitude: 38.802610, longitude: -116.419389)),
            .init(name: "New Hampshire", abbreviation: "NH", coordinate: CLLocationCoordinate2D(latitude: 43.193851, longitude: -71.572395)),
            .init(name: "New Jersey", abbreviation: "NJ", coordinate: CLLocationCoordinate2D(latitude: 40.058324, longitude: -74.405661)),
            .init(name: "New Mexico", abbreviation: "NM", coordinate: CLLocationCoordinate2D(latitude: 34.972730, longitude: -105.032363)),
            .init(name: "New York", abbreviation: "NY", coordinate: CLLocationCoordinate2D(latitude: 42.165726, longitude: -74.948051)),
            .init(name: "North Carolina", abbreviation: "NC", coordinate: CLLocationCoordinate2D(latitude: 35.630066, longitude: -79.806419)),
            .init(name: "North Dakota", abbreviation: "ND", coordinate: CLLocationCoordinate2D(latitude: 47.650589, longitude: -100.437012)),
            .init(name: "Ohio", abbreviation: "OH", coordinate: CLLocationCoordinate2D(latitude: 40.417287, longitude: -82.907123)),
            .init(name: "Oklahoma", abbreviation: "OK", coordinate: CLLocationCoordinate2D(latitude: 35.007752, longitude: -97.092877)),
            .init(name: "Oregon", abbreviation: "OR", coordinate: CLLocationCoordinate2D(latitude: 43.804133, longitude: -120.554201)),
            .init(name: "Pennsylvania", abbreviation: "PA", coordinate: CLLocationCoordinate2D(latitude: 41.203323, longitude: -77.194527)),
            .init(name: "Rhode Island", abbreviation: "RI", coordinate: CLLocationCoordinate2D(latitude: 41.580095, longitude: -71.477429)),
            .init(name: "South Carolina", abbreviation: "SC", coordinate: CLLocationCoordinate2D(latitude: 33.836081, longitude: -81.163725)),
            .init(name: "South Dakota", abbreviation: "SD", coordinate: CLLocationCoordinate2D(latitude: 44.299782, longitude: -99.438828)),
            .init(name: "Tennessee", abbreviation: "TN", coordinate: CLLocationCoordinate2D(latitude: 35.517491, longitude: -86.580447)),
            .init(name: "Texas", abbreviation: "TX", coordinate: CLLocationCoordinate2D(latitude: 31.968599, longitude: -99.901813)),
            .init(name: "Utah", abbreviation: "UT", coordinate: CLLocationCoordinate2D(latitude: 39.320980, longitude: -111.093731)),
            .init(name: "Vermont", abbreviation: "VT", coordinate: CLLocationCoordinate2D(latitude: 44.558803, longitude: -72.577841)),
            .init(name: "Virginia", abbreviation: "VA", coordinate: CLLocationCoordinate2D(latitude: 37.431573, longitude: -78.656894)),
            .init(name: "Washington", abbreviation: "WA", coordinate: CLLocationCoordinate2D(latitude: 47.751076, longitude: -120.740139)),
            .init(name: "West Virginia", abbreviation: "WV", coordinate: CLLocationCoordinate2D(latitude: 38.597626, longitude: -80.454903)),
            .init(name: "Wisconsin", abbreviation: "WI", coordinate: CLLocationCoordinate2D(latitude: 43.784439, longitude: -88.787868)),
            .init(name: "Wyoming", abbreviation: "WY", coordinate: CLLocationCoordinate2D(latitude: 43.075970, longitude: -107.290283))
        ]
    }
    
    struct CityInfo: Identifiable, Hashable {
        var id: String { name }
        let name: String
        let state: String
    }
}

// MARK: - Location Service
extension UI.Address {
    
    final class LocationService: NSObject, ObservableObject, @unchecked Sendable {
        nonisolated private let locationManager = CLLocationManager()
        private var completion: ((Result<CLLocation, Error>) -> Void)?
        
        override init() {
            super.init()
            locationManager.delegate = self
        }
        
        func requestLocation(completion: @escaping @Sendable (Result<CLLocation, Error>) -> Void) {
            self.completion = completion
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension UI.Address.LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            completion?(.failure(LocationError.accessDenied))
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completion?(.success(location))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(error))
    }
    
    enum LocationError: Error {
        case accessDenied
    }
}

// MARK: - View Model
extension UI.Address {
    
    final actor AddressFormViewModel: NSObject, ObservableObject {
        @MainActor @Published var form = AddressForm()
        @MainActor @Published var searchQuery = ""
        
        /// Street address suggestions (overlay)
        @MainActor @Published var searchResults: [AddressSearchResult] = []
        
        /// Inline suggestions for state & city
        @MainActor @Published var stateResults: [StateInfo] = []
        @MainActor @Published var cityResults: [CityInfo] = []
        
        @MainActor @Published private(set) var isLoading = false
        @MainActor @Published private(set) var error: Error?
        
        private let locationService: LocationService
        private let geocoder = CLGeocoder()
        
        @MainActor private(set) var isAutocompleteFilling = false
        
        @MainActor
        private lazy var searchCompleter: MKLocalSearchCompleter = {
            let completer = MKLocalSearchCompleter()
            completer.delegate = self
            completer.resultTypes = .address
            let regionCenter = CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129)
            let regionSpan = MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 60)
            completer.region = MKCoordinateRegion(center: regionCenter, span: regionSpan)
            return completer
        }()
        
        static let states: [StateInfo] = StateInfo.states
        
        override init() {
            self.locationService = LocationService()
            super.init()
            Task { await setupSearchBinding() }
        }
        
        private func setupSearchBinding() async {
            // Observes typing in the street address field
            Task {
                for await _ in NotificationCenter.default.notifications(named: UITextField.textDidChangeNotification).map({ _ in }) {
                    await handleSearchQueryChange()
                }
            }
        }
        
        @MainActor
        private func handleSearchQueryChange() async {
            guard !searchQuery.isEmpty else {
                searchResults = []
                return
            }
            searchCompleter.queryFragment = searchQuery
        }
        
        // MARK: - Refresh Autocomplete Suggestions
        @MainActor
        func refreshStreetSuggestions() {
            if !searchQuery.isEmpty {
                searchCompleter.queryFragment = searchQuery
            }
        }
        
        // MARK: - State
        func searchStates(_ query: String) async {
            await handleStateResults(query)
        }
        
        // Inline logic for filtering states
        @MainActor
        private func handleStateResults(_ query: String) async {
            // If user typed only a known abbreviation, fill it directly
            if let matchedState = Self.states.first(where: { state in
                state.abbreviation.lowercased() == query.lowercased()
            }) {
                form.state = matchedState.name
                stateResults = []
                return
            }
            guard !query.isEmpty else {
                stateResults = []
                return
            }
            let lowercasedQuery = query.lowercased()
            let filteredStates = Self.states.filter {
                $0.name.lowercased().contains(lowercasedQuery) ||
                $0.abbreviation.lowercased().contains(lowercasedQuery)
            }
            if filteredStates.count == 1 {
                form.state = filteredStates[0].name
                stateResults = []
            } else {
                stateResults = filteredStates
            }
        }
        
        // MARK: - City
        @MainActor
        func searchCities(for query: String, in state: String? = nil) async throws {
            guard !query.isEmpty else {
                cityResults = []
                return
            }
            
            let searchRequest = MKLocalSearch.Request()
            // If a state is provided, append it to the query
            let queryWithState: String = {
                if let state = state, !state.isEmpty {
                    return "\(query), \(state)"
                } else {
                    return query
                }
            }()
            searchRequest.naturalLanguageQuery = queryWithState
            searchRequest.resultTypes = .address
            
            // If a state is provided, narrow the search region
            if let state = state, !state.isEmpty,
               let stateInfo = Self.states.first(where: {
                   $0.name.caseInsensitiveCompare(state) == .orderedSame ||
                   $0.abbreviation.caseInsensitiveCompare(state) == .orderedSame
               }) {
                searchRequest.region = MKCoordinateRegion(
                    center: stateInfo.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                )
            }
            
            let search = MKLocalSearch(request: searchRequest)
            let response = try await search.start()
            let cities = response.mapItems.compactMap { item -> CityInfo? in
                guard let locality = item.placemark.locality,
                      let administrativeArea = item.placemark.administrativeArea else { return nil }
                // If a state is provided in the form, only return matching results
                if let currentState = self.form.state as String?, !currentState.isEmpty,
                   currentState.caseInsensitiveCompare(administrativeArea) != .orderedSame {
                    return nil
                }
                return CityInfo(name: locality, state: administrativeArea)
            }
            
            self.cityResults = Array(Set(cities))
                .sorted(by: { $0.name < $1.name })
                .prefix(5)
                .map { $0 }
        }
        
        // MARK: - Detect Location
        
        @MainActor
        func detectLocation() async {
            guard form.useAutoDetect else { return }
            isLoading = true
            error = nil
            locationService.requestLocation { [weak self] result in
                Task { @MainActor in
                    defer { self?.isLoading = false }
                    switch result {
                    case .success(let location):
                        do {
                            try await self?.reverseGeocode(location)
                        } catch {
                            self?.error = error
                        }
                    case .failure(let error):
                        self?.error = error
                    }
                }
            }
        }
        
        @MainActor
        private func reverseGeocode(_ location: CLLocation) async throws {
            let locale = Locale(identifier: "en_US")
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: locale)
            guard let placemark = placemarks.first, placemark.isoCountryCode == "US" else {
                throw GeocodingError.noResults
            }
            let mkPlacemark = MKPlacemark(placemark: placemark)
            updateFormWithPlacemark(mkPlacemark)
        }
        
        // MARK: - Selecting a Street Address
        @MainActor
        func selectSearchResult(_ result: AddressSearchResult) {
            Task {
                let searchRequest = MKLocalSearch.Request(completion: result.completerResult)
                let search = MKLocalSearch(request: searchRequest)
                do {
                    let response = try await search.start()
                    if let placemark = response.mapItems.first?.placemark {
                        // Persist in street text field
                        updateFormWithPlacemark(placemark)
                        
                        // Clear out the overlay’s suggestions, but keep the typed address
                        // in the text box so the user can see it.
                        searchResults = []
                    }
                } catch {
                    self.error = error
                }
            }
        }
        
        // MARK: - Update Form from Placemark
        @MainActor
        private func updateFormWithPlacemark(_ placemark: MKPlacemark) {
            isAutocompleteFilling = true
            
            let streetAddress = [placemark.subThoroughfare, placemark.thoroughfare]
                .compactMap { $0 }
                .joined(separator: " ")
            form.street = streetAddress
            
            // Also show it in the text field
            searchQuery = streetAddress
            
            form.city = placemark.locality ?? ""
            form.zipCode = placemark.postalCode ?? ""
            
            if let stateAbbrev = placemark.administrativeArea {
                if let matchedState = Self.states.first(where: { $0.abbreviation == stateAbbrev }) {
                    form.state = matchedState.name
                } else {
                    form.state = stateAbbrev
                }
            }
            
            // Clear leftover inline suggestions
            stateResults = []
            cityResults = []
            
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 500_000_000)
                isAutocompleteFilling = false
            }
        }
        
        func save() async throws {
            // Implement your save logic here
        }
        
        @MainActor
        func clearForm() {
            form = AddressForm()
            searchQuery = ""
            searchResults = []
            stateResults = []
            cityResults = []
            error = nil
        }
        
        enum GeocodingError: Error {
            case noResults
        }
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension UI.Address.AddressFormViewModel: @preconcurrency MKLocalSearchCompleterDelegate {
    
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
            let filteredResults = completer.results.filter { result in
                if !form.city.isEmpty && cityResults.isEmpty { return true }
                _ = "\(result.title), \(result.subtitle)"
                return result.subtitle.contains("United States") ||
                result.subtitle.contains("USA") ||
                Self.states.contains { state in
                    result.subtitle.contains(", \(state.abbreviation)")
                }
            }
            
            // If both city & state are filled, we interpret the results as city-based completions
            if !form.state.isEmpty && !form.city.isEmpty {
                processCityResults(filteredResults)
            } else {
                // Street-level suggestions
                searchResults = filteredResults.map {
                    UI.Address.AddressSearchResult(completerResult: $0)
                }
            }
        }
    }
    
    @MainActor
    private func processCityResults(_ results: [MKLocalSearchCompletion]) {
        let cityResults = results.compactMap { result -> UI.Address.CityInfo? in
            let primaryComponents = result.title.components(separatedBy: ",")
            let secondaryComponents = result.subtitle.components(separatedBy: ",")
            let cityComponent = primaryComponents.first?.trimmingCharacters(in: .whitespaces)
            let stateComponent = [primaryComponents.dropFirst().first, secondaryComponents.first]
                .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
                .first
            guard let cityName = cityComponent, let state = stateComponent else { return nil }
            let cleanedState = state.components(separatedBy: " ").first ?? state
            return UI.Address.CityInfo(name: cityName, state: cleanedState)
        }
        
        let filtered = form.state.isEmpty
        ? cityResults
        : cityResults.filter { $0.state == form.state }
        
        self.cityResults = Array(Set(filtered)).sorted(by: { $0.name < $1.name })
    }
    
    @MainActor
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.error = error
        searchResults = []
    }
}

// MARK: - Inline SuggestionsListView
/// Used for inline suggestions of City or State.
struct InlineSuggestionsListView<Suggestion: Identifiable, Content: View>: View {
    let suggestions: [Suggestion]
    let onSelect: (Suggestion) -> Void
    let content: (Suggestion) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions) { suggestion in
                Button {
                    onSelect(suggestion)
                } label: {
                    content(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .buttonStyle(.plain)
                
                // Divider except for the last
                if suggestion.id != suggestions.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - View
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
