//
//  LocationService.swift
//  MapKitAddressCompleteDemo
//

import CoreLocation
import MapKit

extension MKLocalSearchCompletion: @retroactive @unchecked Sendable {}
extension MKLocalSearch.Response: @retroactive @unchecked Sendable {}
extension MKLocalSearchCompleter: @retroactive @unchecked Sendable {}
extension CLLocationManager: @retroactive @unchecked Sendable {}
extension CLGeocoder: @retroactive @unchecked Sendable {}

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
