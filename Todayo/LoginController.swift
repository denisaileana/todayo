//
//  LoginController.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 27.05.2021.
//

import UIKit
import SQLite3

class LoginController: UIViewController {
    //titlu
    @IBOutlet weak var login: UILabel!
    //campuri
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        //salvarea datelor
        

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = "\(passwordTextField.text ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        //validam ca campurile au fost completate
        if (email?.isEmpty)!{
            emailTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        if (password.isEmpty) {
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            return
        }

        //facem un statement
        var statement: OpaquePointer?

        //query-ul pentru inserarea utilizatorului
        let queryString1 = "SELECT id from user WHERE email = ? AND parola = ?"

        //pregatim query-ul
        if sqlite3_prepare(Database.shared.db, queryString1, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la pregatirea inserarii \(errmsg)")
            return
        }

        //bind-uim parametrii de "?"
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        if sqlite3_bind_text(statement, 1, email, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul emailului: \(errmsg)")
            return
        }
        if sqlite3_bind_text(statement, 2, password, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul parolei: \(errmsg)")
            return
        }

        let rezultat = sqlite3_step(statement)
        print("rezultat \(rezultat) (row: \(SQLITE_ROW)) (done: \(SQLITE_DONE))")
        if (rezultat == SQLITE_ROW) {
            print("test")
            
            let id_user = sqlite3_column_int(statement, 0)
            Database.shared.id_user = id_user
            
            //pentru storyboard-ul de loggedin
            let storyboard = UIStoryboard(name: "LoggedIn", bundle: nil)
            let ecran = storyboard.instantiateInitialViewController()!
            ecran.modalPresentationStyle = .fullScreen
            self.present(ecran, animated: true, completion: nil)

            //punem pe display un mesaj de succes
            print("Logged In!")
        } else {
            //golim textfield-urile
            emailTextField.text = ""
            passwordTextField.text = ""

            //punem pe display un mesaj de succes
            print("No username / password found!")
        }
        



        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}
