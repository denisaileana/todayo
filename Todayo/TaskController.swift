//
//  TaskController.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 29.05.2021.
//

import UIKit
import SQLite3

class TaskController: UITableViewController {
    //tabelul
    var todolist = [Todo]()
    
    func readValues(){
        
        //golim lista de taskuri
        todolist.removeAll()
        
        //query
        let query = "SELECT * FROM task"
        
        //statement pointer
        var statement:OpaquePointer?
        
        //pregatire query
        if sqlite3_prepare(Database.shared.db, query, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Eroare la pregatire: \(errmsg)")
            return
        }
        
        //trecem prin toate inregistrarile
        while(sqlite3_step(statement) == SQLITE_ROW){
            let id = sqlite3_column_int(statement, 0)
            let id_user = sqlite3_column_int(statement, 1)
            let task = String(cString: sqlite3_column_text(statement, 2))
            let completed = sqlite3_column_int(statement, 3) == 1
            let due = String(cString: sqlite3_column_text(statement, 4))
            let create_lat = sqlite3_column_double(statement, 5)
            let create_long = sqlite3_column_double(statement, 6)
            
            //adaugare valori in lista
            todolist.append(Todo(id: Int(id), id_user: Int(id_user), task: task, completed: Bool(completed), due: due, create_lat: Decimal(create_lat), create_long: Decimal(create_long)))
        }
        self.tableView.reloadData()
    }
    
    //cate sectiuni am in tabel
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //cate randuri pe sectiune
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todolist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //instanta celulei
        let todoCell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        //fac o varibila todo de tipul clasei Todo
        let todo: Todo
        //pun in todo randul
        todo = todolist[indexPath.row]
        todoCell.textLabel?.text = todo.task
        return todoCell
    }
    
    override func viewDidLoad() {
        readValues()
    }
    
    func deleteValue(indexPath: IndexPath){
        
        print("\(indexPath)")
        //facem un statement
        var statement: OpaquePointer?

        //query-ul pentru inserarea utilizatorului
        let queryString1 = "DELETE FROM task WHERE id=?"

        //pregatim query-ul
        if sqlite3_prepare(Database.shared.db, queryString1, -1, &statement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la pregatirea stergerii \(errmsg)")
            return
        }

        //bind-uim parametrii de "?"
        if sqlite3_bind_int(statement, 1, Int32(todolist[indexPath.row].id)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la bindingul id-ului: \(errmsg)")
            return
        }

        //executam query-ul de inserare
        if sqlite3_step(statement) != SQLITE_DONE{
            let errmsg = String(cString: sqlite3_errmsg(Database.shared.db)!)
            print("Am esuat la stergere: \(errmsg)")
            return
        }
        
        readValues()
    }
    
    
    //configurare optiune stanga
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Done", handler: {
            [weak self](action, view, completionhandler) in
            self?.deleteValue(indexPath: indexPath)
            completionhandler(true)
        })
        action.backgroundColor = .init(red: 0.2, green: 0.7, blue: 0, alpha: 1)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
