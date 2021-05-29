//
//  Todo.swift
//  Todayo
//
//  Created by Denisa-Ileana Neacsu on 29.05.2021.
//

import Foundation

class Todo{
    var id: Int
    var id_user: Int
    var task: String
    var completed: Bool
    var due: String
    var create_lat: Decimal
    var create_long: Decimal
    
    init(id:Int, id_user: Int, task: String, completed: Bool, due: String, create_lat: Decimal, create_long: Decimal){
        self.id = id
        self.id_user = id_user
        self.task = task
        self.completed = completed
        self.due = due
        self.create_lat = create_lat
        self.create_long = create_long
    }
}
