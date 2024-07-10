//  
//  BeaconDetectionManager.swift
//  DoNothings
//
//  Created by Kosal Pen on 9/7/24.
//

import UIKit
import CoreLocation
import UserNotifications

class BeaconDetectionManager: NSObject, CLLocationManagerDelegate {

    static let shared = BeaconDetectionManager()

    private var locationManager: CLLocationManager!
    private let beaconUUID = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
    private let beaconIdentifier = "beacon_master"

    private override init() {
        super.init()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            startMonitoring()
        } else {
            print("Beacon monitoring is not available on this device.")
        }
        
        locationManager.startUpdatingLocation()
    }

    private func startMonitoring() {
        let beaconRegion = CLBeaconRegion(uuid: beaconUUID, identifier: beaconIdentifier)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyEntryStateOnDisplay = true
        locationManager.startMonitoring(for: beaconRegion)
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(#function, locations.first?.coordinate)
//    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: beaconRegion.uuid))
            print("Entered beacon region: \(beaconRegion.identifier)")
            sendLocalNotification(with: "Entered beacon region: \(beaconRegion.identifier)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: beaconRegion.uuid))
            print("Exited beacon region: \(beaconRegion.identifier)")
            sendLocalNotification(with: "Exited beacon region: \(beaconRegion.identifier)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            switch state {
            case .inside:
                print("Inside region: \(beaconRegion.identifier)")
                locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: beaconRegion.uuid))
            case .outside:
                print("Outside region: \(beaconRegion.identifier)")
                locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: beaconRegion.uuid))
            case .unknown:
                print("Unknown region state for: \(beaconRegion.identifier)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        for beacon in beacons {
            let proximity = beacon.proximity
            let major = beacon.major
            let minor = beacon.minor
        

            print("Beacon found with proximity: \(proximity.rawValue), major: \(major), minor: \(minor)")
            //sendLocalNotification(with: "Beacon found with major: \(major), minor: \(minor)")
        }
    }

    private func sendLocalNotification(with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Beacon Detection"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

