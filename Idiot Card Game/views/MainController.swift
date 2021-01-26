//
//  MainController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import UIKit
import CoreData

class MainController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
        let userFetchRequest: NSFetchRequest = CoreUser.fetchRequest()
        do {
            let fetchResults = try managedObjectContainer.viewContext.fetch(userFetchRequest)
            if(fetchResults.count == 0) {
                // navigate to WelcomeViewController
                let welcomeViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                welcomeViewController.modalPresentationStyle = .fullScreen
                welcomeViewController.sourceVC = "main"
                self.present(welcomeViewController, animated: false, completion: nil)
            } else {
                // navigate to home view controller
                let tabBarController = storyBoard.instantiateViewController(withIdentifier: "TabBarController")
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: false, completion: nil)
            }
        } catch {
            print(exception.self)
        }
    }

}

