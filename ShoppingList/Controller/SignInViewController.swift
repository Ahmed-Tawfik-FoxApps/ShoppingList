//
//  SignInViewController.swift
//  ShoppingList
//
//  Created by Ahmed Tawfik on 12/23/17.
//  Copyright © 2017 Fox Apps. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    // MARK: Properties
    fileprivate var authHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: IBOutlet
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: App Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFirebaseAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAuthHandle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAuthHandle()
    }
    
    // MARK: IBAction
    
    @IBAction func signIn(_ sender: Any) {
    }
    
    @IBAction func signOut(segue: UIStoryboardSegue) {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

// MARK: Extension SignInViewController - FIRAuth

extension SignInViewController {
    func configureFirebaseAuth() {
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        signInButton.style = .wide
        signInButton.colorScheme = .dark
    }
    
    func addAuthHandle() {
        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            FirebaseClient.sharedInstance().getPredefinedItems()
            if let activeUser = user {
                DispatchQueue.main.async {
                    self.signInButton.isEnabled = false
                    self.activityIndicator.startAnimating()
                }
                FirebaseClient.sharedInstance().getUserNode(for: activeUser.uid, completionHandler: { (currentUser) in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    if let currentUser = currentUser {
                        Model.sharedInstance().currentUser = currentUser
                        self.performSegue(withIdentifier: SegueIdentiers.ListsView, sender: nil)
                    } else {
                        self.setNewCurrentUser(activeUser)
                        FirebaseClient.sharedInstance().addNewUser(for: Model.sharedInstance().currentUser)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: SegueIdentiers.ListsView, sender: nil)
                        }
                    }
                })
            } else {
                self.signInButton.isEnabled = true
            }
        })
    }
    
    func removeAuthHandle() {
        Auth.auth().removeStateDidChangeListener(authHandle!)
    }
}

// MARK: Extension SignInViewController - Helper Functions

extension SignInViewController {
    func setNewCurrentUser(_ activeUser: User) {
        Model.sharedInstance().currentUser.userID = activeUser.uid
        Model.sharedInstance().currentUser.displayName = activeUser.displayName!
        Model.sharedInstance().currentUser.email = activeUser.email!
        // To be Added -- demo item need to be added to the demo list
        let demoList = [FirebaseClient.NodeKeys.ListName: "Demo List" as AnyObject,
                        FirebaseClient.NodeKeys.DueDate: getStringFromDate(Date().addingTimeInterval(Constants.SecondsForDay)) as AnyObject,
                        FirebaseClient.NodeKeys.ListKey: "" as AnyObject,
                        FirebaseClient.NodeKeys.Items: [[String: AnyObject]]() as AnyObject]
        Model.sharedInstance().currentUser.lists = [ShoppingList(dictionary: demoList)]
    }
}
