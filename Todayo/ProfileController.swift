//
//  ProfileController.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 12.06.2021.
//

import Foundation


import UIKit
import SQLite3
import CoreLocation
import MapKit

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userimg: UIImageView!
    @IBOutlet weak var usernume: UILabel!
    @IBOutlet weak var userprenume: UILabel!
    @IBAction func edituserimg(_ sender: UIButton) {
        let controller = UIImagePickerController()
        //selectare poze (fara logica de pus poza in aplicatie)
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            controller.delegate = self
            controller.sourceType = .savedPhotosAlbum
            controller.allowsEditing = true
            present(controller, animated: true, completion: nil)
        }
    }
    //logica
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        userimg.image = image
        //ca sa se inchida tab-ul dupa ce am selectat imaginea
        picker.dismiss(animated: true, completion: nil)
        //salvare imagine
        
        //facem un statement
        var statement: OpaquePointer?

        //query-ul pentru inserarea utilizatorului
        let queryString1 = "UPDATE user SET imagine=? WHERE id=?"

        //pregatim query-ul
        if sqlite3_prepare(Database.shared.db, queryString1, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la pregatirea actualizarii \(errmsg)")
            return
        }

        //bind-uim parametrii de "?"
        let imaginedata = image.pngData()!
        let imaginesql = imaginedata.base64EncodedString(options: .lineLength64Characters)
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(statement, 1, imaginesql, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul imaginii: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(statement, 2, Database.shared.id_user!) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul id-ului: \(errmsg)")
            return
        }

        //executam query-ul de inserare
        if sqlite3_step(statement) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la actualizare: \(errmsg)")
            return
        }
        
    }
    
    //ca sa citim nume prenume imagine
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //query
        let query = "SELECT nume, prenume, imagine FROM user where id=?"
        
        //statement pointer
        var statement:OpaquePointer?
        
        
        
        //pregatire query
        if sqlite3_prepare(Database.shared.db, query, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Eroare la pregatire: \(errmsg)")
            return
        }
        
        //bind-uim parametrii de "?"
        if sqlite3_bind_int(statement, 1, Database.shared.id_user!) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul id-ului de user: \(errmsg)")
            return
        }
        
        //trecem prin toate inregistrarile
        if sqlite3_step(statement) != SQLITE_ROW{
            print("Userul nu exita?!")
            return
        }
        
        usernume.text = String(cString: sqlite3_column_text(statement, 0))
        userprenume.text = String(cString: sqlite3_column_text(statement, 1))
        let imaginesql = sqlite3_column_text(statement, 2)
        if imaginesql != nil{
            let imagine = String(cString: imaginesql!)
            let data = Data(base64Encoded: imagine, options: .ignoreUnknownCharacters)
            if data != nil {
                let uiimage = UIImage(data: data!)
                userimg.image = uiimage
            }
            
        }

    }
    
}
