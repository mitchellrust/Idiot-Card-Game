//
//  HomeViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    let db: Firestore = Firestore.firestore()
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var biggestIdiotsButton: UIButton!
    
    var idToJoin: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show tab bar
        self.tabBarController?.tabBar.isHidden = false
        
        newGameButton.clipsToBounds = true;
        newGameButton.layer.cornerRadius = 10;
        joinGameButton.clipsToBounds = true;
        joinGameButton.layer.cornerRadius = 10;
        biggestIdiotsButton.clipsToBounds = true;
        biggestIdiotsButton.layer.cornerRadius = 10;
        
        // Reset game code for joining new game
        idToJoin = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToLobby" {
            let vc = segue.destination as! GameLobbyViewController
            vc.idToJoin = idToJoin
        }
    }
    
    @IBAction func newGameTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToLobby", sender: sender)
    }
    
    @IBAction func joinGameTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Game Code", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Game Code"
            textField.keyboardType = .numberPad
        }
        
        let joinAction = UIAlertAction(title: "Join", style: .default, handler: { alert -> Void in
            let codeTextField = alertController.textFields![0] as UITextField
            let gameCode: Int? = Validation.validateGameCode(code: codeTextField.text!)
            guard gameCode != nil else {
                self.alertInvalidGameCode()
                return
            }
            self.showSpinner(onView: self.view)
            let query = self.db.collection("games").whereField("code", isEqualTo: gameCode!)
            CloudFS.queryForGameId(query: query, completion: { [self] id in
                self.removeSpinner()
                guard id != nil else {
                    self.alertInvalidGameCode()
                    return
                }
                self.idToJoin = id
                self.performSegue(withIdentifier: "GoToLobby", sender: nil)
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(joinAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    func alertInvalidGameCode() {
        let alert = UIAlertController(title: "Invalid Game Code", message: "The code entered is invalid. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}
