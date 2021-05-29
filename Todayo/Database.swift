//
//  Database.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 27.05.2021.
//
import Foundation
import SQLite3

class Database{
    
    //instanta bazei de date
    static let shared = Database()
    //constructor private
    private init(){}
    //avem nevoie de un obiect opaquepointer ca sa putem deschide baza de date
    public var db: OpaquePointer?
    public func conecteaza(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Todayo.sqlite")

        //deschidem baza de date
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Eroare la deschiderea bazei de date")
        }

        //creare tabel user
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, nume TEXT, prenume TEXT, email EMAIL, parola TEXT); INSERT INTO user (nume, prenume, email, parola) VALUES ('admin', 'admin', 'admin@gmail.com', 'admin123')", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Eroare la crearea tabelului \(errmsg)")
        }
        //creare tabel task-uri
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS task (id INTEGER PRIMARY KEY AUTOINCREMENT, id_user INTEGER, task TEXT, completed TINYINT(1), due DATE, create_lat DECIMAL, create_long DECIMAL); INSERT INTO task VALUES (null, 1, 'de cumparat legume', 0, '2021-10-31', 0, 0)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Eroare la crearea tabelului \(errmsg)")
        }
        print("avem date")
    }

}
