//
//  AddtaskController.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 05.06.2021.
//

import UIKit
import SQLite3
import CoreLocation
import MapKit

class AddtaskController: UIViewController {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var dataField: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func addTaskButton(_ sender: UIButton) {
        //salvarea datelor
        let taskname = taskTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = ISO8601DateFormatter().string(from: dataField.date)
        let lat = mapView.userLocation.coordinate.latitude
        let lon = mapView.userLocation.coordinate.longitude
        
        //validam ca campurile au fost completate
        if (taskname?.isEmpty)!{
            taskTextField.layer.borderColor = UIColor.red.cgColor
            return
        }

        //facem un statement
        var statement: OpaquePointer?

        //query-ul pentru inserarea utilizatorului
        let queryString1 = "INSERT INTO task (id_user, task, completed, due, create_lat, create_long) VALUES (?,?,?,?,?,?)"

        //pregatim query-ul
        if sqlite3_prepare(Database.shared.db, queryString1, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la pregatirea inserarii \(errmsg)")
            return
        }

        //bind-uim parametrii de "?"
        if sqlite3_bind_int(statement, 1, Database.shared.id_user!) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul id-ului de user: \(errmsg)")
            return
        }

        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(statement, 2, taskname, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul taskname-ului: \(errmsg)")
            return
        }
        if sqlite3_bind_int(statement, 3, 0) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul completed: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(statement, 4, data, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul data: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(statement, 5, lat) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul latitudinii: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(statement, 6, lon) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul longitudinii: \(errmsg)")
            return
        }

        //executam query-ul de inserare
        if sqlite3_step(statement) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la inserare: \(errmsg)")
            return
        }

        //golim textfield-urile
        taskTextField.text = ""
        
    }
    
    
    
    //pozitia mea pe harta
    let locationManager = CLLocationManager()
    var overlay: MKOverlay? = nil
    var pin: MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pop up de request location
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.delegate = self
        //sa primim eventurile de actualizare pozitiei
        locationManager.delegate = self
        
        
        
    }
    
    //adaug cercul pe harta + pin
    func showCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance){
        let circle = MKCircle(center: center, radius: radius)
        if overlay != nil {
            mapView.removeOverlay(overlay!)
        }
        overlay = circle
        mapView.addOverlay(overlay!)
        //pin
        let newpin = MKPointAnnotation()
        if pin != nil{
            mapView.removeAnnotation(pin!)
        }
        newpin.coordinate = center
        mapView.addAnnotation(newpin)
        pin = newpin
    }
}

extension AddtaskController: MKMapViewDelegate{
    //desenam cerc pe harta - overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.fillColor = .black
            circleRenderer.alpha = 0.2
            return circleRenderer
        }
        return MKCircleRenderer()
    }
}

extension AddtaskController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = location.coordinate
        showCircle(center: center, radius: 200)
        
    }
}
