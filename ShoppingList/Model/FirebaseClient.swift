//
//  FirebaseClient.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/26/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import Firebase

class FirebaseClient {
    
    // MARK: - Firebase Properties
    
    private var dbRef: DatabaseReference!
    fileprivate var dbRefHandles = [String:DatabaseHandle]()

    // MARK: - Shared Instance
    
    class func sharedInstance() -> FirebaseClient
    {
        struct Singleton {
            static var sharedInstance = FirebaseClient()
        }
        return Singleton.sharedInstance
    }

    // MARK: - Firebase Configurations
    
    func configureFirebaseClient() {
        configureDatabase()
    }
    
    private func configureDatabase() {
        Database.database().isPersistenceEnabled = true
        dbRef = Database.database().reference()
    }
    
    deinit {
        for(nodePath, handle) in dbRefHandles {
            dbRef.child(nodePath).removeObserver(withHandle: handle)
        }
    }
    
    // MARK: - Database Read and Write
    
    func writeData(at nodePath: String, value: AnyObject) {
        dbRef.child(nodePath).setValue(value)
    }
        
    func readDataOnce(at nodePath: String, completionHandler:@escaping (_ results: AnyObject?, _ error: String?) -> Void) {
        dbRef.child(nodePath).observeSingleEvent(of: .value, with: { (snapshot) in
            completionHandler(snapshot.value as AnyObject?, nil)
        }) { (error) in
            completionHandler(nil,error.localizedDescription)
        }
    }
    
    func addChildByAutoID(at nodePath: String, value: AnyObject) -> String {
        let reference = dbRef.child(nodePath).childByAutoId()
        reference.setValue(value)
        return reference.key
    }
    
    func addObserver(at nodePath: String, completionHandler:@escaping (_ results: AnyObject?, _ error: String?) -> Void) {
        let handle = dbRef.child(nodePath).observe(.value, with: { (snapshot) in
            completionHandler(snapshot.value as AnyObject?, nil)
        }) { (error) in
            completionHandler(nil,error.localizedDescription)
        }
        dbRefHandles[nodePath] = handle
    }
    
    func deleteData(at nodePath: String) {
        dbRef.child(nodePath).removeValue()
    }
}
