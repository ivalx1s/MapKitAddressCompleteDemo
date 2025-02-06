//
//  AddressFormViewModel.swift
//  MapKitAddressCompleteDemo
//

import Foundation
import CoreLocation
import MapKit

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
