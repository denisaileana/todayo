//
//  SignupController.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 27.05.2021.
//

import UIKit
import SQLite3

class SignupController: UIViewController {
    
    //pentru pagina de creare cont
    //titlu
    @IBOutlet weak var signup: UILabel!
    //campuri
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        //buton
    @IBAction func signupButton(_ sender: UIButton) {
        //salvarea datelor
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastname = lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        //validam ca campurile au fost completate
        if (name?.isEmpty)!{
            nameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        if (lastname?.isEmpty)!{
            lastnameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        if (email?.isEmpty)!{
            emailTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        if (password?.isEmpty)!{
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            return
        }

        //facem un statement
        var statement: OpaquePointer?

        //query-ul pentru inserarea utilizatorului
        let queryString1 = "INSERT INTO user (nume, prenume, email, parola) VALUES (?,?,?,?)"

        //pregatim query-ul
        if sqlite3_prepare(Database.shared.db, queryString1, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la pregatirea inserarii \(errmsg)")
            return
        }
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        //bind-uim parametrii de "?"
        if sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul numelui: \(errmsg)")
            return
        }

        if sqlite3_bind_text(statement, 2, lastname, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul prenumelui: \(errmsg)")
            return
        }
        if sqlite3_bind_text(statement, 3, email, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul emailului: \(errmsg)")
            return
        }
        if sqlite3_bind_text(statement, 4, password, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul parolei: \(errmsg)")
            return
        }

        //executam query-ul de inserare
        if sqlite3_step(statement) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la inserare: \(errmsg)")
            return
        }

        //golim textfield-urile
        nameTextField.text = ""
        lastnameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""


        //citireValori()

        //punem pe display un mesaj de succes
        print("User salvat cu succes!")
        
        Database.shared.id_user = Int32(sqlite3_last_insert_rowid(Database.shared.db))

        //pentru storyboard-ul de loggedin
        let storyboard = UIStoryboard(name: "LoggedIn", bundle: nil)
        let ecran = storyboard.instantiateInitialViewController()!
        ecran.modalPresentationStyle = .fullScreen
        self.present(ecran, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        


    }


}



