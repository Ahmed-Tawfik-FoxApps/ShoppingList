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
import ReachabilitySwift

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    // MARK: Properties
    
    fileprivate var authHandle: AuthStateDidChangeListenerHandle?
    fileprivate var reachability = Reachability()!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reachabilityTextLabel: UILabel!
    
    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFirebaseAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAuthHandle()
        startReachabilityNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAuthHandle()
        stopReachabilityNotifier()
    }
    
    // MARK: IBAction

    @IBAction func signOut(segue: UIStoryboardSegue) {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: Helper Functions
    private func startReachabilityNotifier() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        reachabilityWarning()
    }
    
    private func stopReachabilityNotifier() {
        reachability.stopNotifier()
    }
    
    private func reachabilityWarning() {
        reachability.whenUnreachable = {_ in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.reachabilityTextLabel.alpha = 1
                    self.signInButton.isEnabled = false
                })
            }
        }
        reachability.whenReachable = {_ in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.reachabilityTextLabel.alpha = 0
                    self.signInButton.isEnabled = true
                })
            }
        }
    }
}

// MARK: Extension SignInViewController - FIRAuth

extension SignInViewController {
    func configureFirebaseAuth() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        signInButton.style = .wide
        signInButton.colorScheme = .dark
    }
    
    func addAuthHandle() {
        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            FirebaseClient.sharedInstance().getPredefinedItems()
            if let activeUser = user {
                FirebaseClient.sharedInstance().getUserNode(for: activeUser.uid, completionHandler: { (currentUser) in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    if let currentUser = currentUser {
                        Model.sharedInstance().currentUser = currentUser
                        DispatchQueue.main.async {
                        self.performSegue(withIdentifier: SegueIdentiers.ListsView, sender: nil)
                        }
                    } else {
                        self.setNewCurrentUser(activeUser)
                        FirebaseClient.sharedInstance().addNewUser(for: Model.sharedInstance().currentUser)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: SegueIdentiers.ListsView, sender: nil)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.signInButton.isEnabled = true
                }
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
        let demoItems = Model.sharedInstance().predefinedItems.count >= 2 ? [Model.sharedInstance().predefinedItems[0], Model.sharedInstance().predefinedItems[1]] : [ShoppingItem]()
        let demoList = [FirebaseClient.NodeKeys.ListName: Constants.DemoListName as AnyObject,
                        FirebaseClient.NodeKeys.DueDate: getStringFromDate(Date().addingTimeInterval(Constants.SecondsForDay)) as AnyObject,
                        FirebaseClient.NodeKeys.ListKey: "" as AnyObject,
                        FirebaseClient.NodeKeys.Items: getDictionaryFromItems(demoItems) as AnyObject]
        Model.sharedInstance().currentUser.lists = [ShoppingList(dictionary: demoList)]
    }
}

// MARK: Extension SignInViewController - GIDSignInDelegate

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print("Error while sign in: \(error!.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential)
        activityIndicator.startAnimating()
        self.signInButton.isEnabled = false
    }
}
