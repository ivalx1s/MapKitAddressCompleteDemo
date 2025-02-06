//
//  AddressForm.swift
//  MapKitAddressCompleteDemo

import CoreLocation
import MapKit

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

