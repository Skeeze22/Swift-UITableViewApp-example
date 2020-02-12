//
//  StorageManager.swift
//  UITableView APP
//
//  Created by Егор Грива on 04.02.2020.
//  Copyright © 2020 Егор Грива. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager{
    static func saveObect(_ place: Place){
        try! realm.write {
            realm.add(place)
        }
    }
    static func deleteObject(_ place: Place){
        try! realm.write {
            realm.delete(place)
        }
    }
}
