//
//  WelcomeViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import UIKit
import Firebase
import GoogleSignIn

class WelcomeViewController: UIViewController, GIDSignInDelegate {
    
    var storyBoard: UIStoryboard!
    
    var sourceVC: String!
    var onDoneBlock : ((Bool) -> Void)? // used to reload profile header
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        self.showSpinner(onView: self.view)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.removeSpinner()
                print(error.localizedDescription)
                return
            }
            
            let currentUser = authResult!.user
            
            CloudFS.getUser(docId: currentUser.uid, completion: { [self, currentUser] user in
                guard user != nil else {
                    let userObj: User = User(id: currentUser.uid, displayName: currentUser.displayName ?? currentUser.email!, email: currentUser.email!)
                    CloudFS.createUser(user: userObj, completion: { [self, userObj] error in
                        self.removeSpinner()
                        guard error == nil else {
                            let alert = UIAlertController(title: "Could not create user", message: "This is an unexpected error. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            return
                        }
                        
                        // Save new user to core data
                        let managedObjectContainer = CoreDataController.getInstance()
                        let coreUser = CoreUser(context: managedObjectContainer.viewContext)
                        coreUser.id = userObj.id
                        coreUser.displayName = userObj.displayName
                        coreUser.email = userObj.email
                        CoreDataController.saveContext()
                        
                        navigate()
                    })
                    return
                }
                
                self.removeSpinner()
                
                let managedObjectContainer = CoreDataController.getInstance()
                // Save user to core data
                let coreUser = CoreUser(context: managedObjectContainer.viewContext)
                coreUser.id = user!.id
                coreUser.displayName = user!.displayName
                coreUser.email = user!.email
                coreUser.profilePhotoUrl = user!.profilePhotoUrl
                
                if coreUser.profilePhotoUrl != "" {
                    FSStorage.getProfilePicture(url: coreUser.profilePhotoUrl!, completion: { [self] data in
                        coreUser.profileImage = data
                        CoreDataController.saveContext()
                        navigate()
                    })
                } else {
                    CoreDataController.saveContext()
                    navigate()
                }
            })
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func navigate() {
        if sourceVC == "main" {
            let homeViewController = self.storyBoard.instantiateViewController(withIdentifier: "TabBarController")
            homeViewController.modalPresentationStyle = .fullScreen
            self.present(homeViewController, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: {
                self.onDoneBlock!(true)
            })
        }
    }
}
