//
//  GameLobbyViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/21.
//

import UIKit
import CoreData
import FirebaseFirestore

class GameLobbyViewController: UIViewController {
    
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var player1Image: UIImageView!
    @IBOutlet weak var player2Image: UIImageView!
    @IBOutlet weak var player3Image: UIImageView!
    @IBOutlet weak var player4Image: UIImageView!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var loadingViewLabel: UILabel!
    @IBOutlet weak var loadingViewAnimationView: UIImageView!
    
    @IBOutlet weak var loadingView: UIView!
    
    var animationImages: Array<UIImage> = []
    var animatedImage: UIImage!
    var defaultImage: UIImage!
    
    let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
    
    var game: Game!
    var user: CoreUser!
    var player: Player!
    var numPlayers: Int = 0
    
    var idToJoin: String? // passed from parent VC if joining a game to get ID
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        defaultImage = UIImage(named: "warm-mountains")!
        
        // Get user profile photo
        let userFetchRequest: NSFetchRequest = CoreUser.fetchRequest()
        do {
            let fetchResults = try managedObjectContainer.viewContext.fetch(userFetchRequest)
            user = fetchResults[0]
            player = Player(id: user.id!)
        } catch {
            print(exception.self)
        }
        
        // Create loading animations
        for i in 0...30 {
            let imageName: String = "frame-\(i)"
            let image: UIImage = UIImage(named: imageName)!
            animationImages.append(image)
        }
        animatedImage = UIImage.animatedImage(with: animationImages, duration: 1.0)
        loadingViewAnimationView.image = animatedImage
        player2Image.image = animatedImage
        player3Image.image = animatedImage
        player4Image.image = animatedImage
        
        startGameButton.isEnabled = false
        startGameButton.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide tab bar
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        player1Image.clipsToBounds = true;
        player1Image.layer.cornerRadius = 50;
        player2Image.clipsToBounds = true;
        player2Image.layer.cornerRadius = 50;
        player3Image.clipsToBounds = true;
        player3Image.layer.cornerRadius = 50;
        player4Image.clipsToBounds = true;
        player4Image.layer.cornerRadius = 50;
        
        startGameButton.clipsToBounds = true;
        startGameButton.layer.cornerRadius = 5;
        exitButton.clipsToBounds = true;
        exitButton.layer.cornerRadius = 5;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if idToJoin == nil {
            create() // create new game first
        } else {
            getAndListen(gameId: idToJoin!) // joining game, so get it and listen
        }
    }
    
    /*
     Create a new game with user as player
     */
    func create() {
        //Create game and set up listener
        let deckOrder = Array(0...51).shuffled()
        let game = Game(player1: player, deckOrder: deckOrder)
        CloudFS.createGame(game: game, completion: { [self] id in
            guard id != nil else {
                let alert = UIAlertController(title: "Could not create a game", message: "Please check your internet connection and try again. If the problem persists, please submit a support ticket with the attached error code. Error code: GameLobby.create", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
                return
            }
            self.numPlayers = 1
            getAndListen(gameId: id!)
        })
    }
    
    func getAndListen(gameId: String) {
        CloudFS.getGame(docId: gameId, completion: { [self] obj in
            // First load or updated data, do something with it
            guard obj != nil else {
                let alert = UIAlertController(title: "Could not get game", message: "Please check your internet connection and try again. If the problem persists, please submit a support ticket with the attached error code. Error code: GameLobby.getAndListen.getGame", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
                return
            }
            
            // Add user to the game in first available spot
            if game == nil && idToJoin != nil {
                var data: [String: Any]
                if obj?.player1.id == "" {
                    data = [ "player1" : [ "id" : player!.id, "hand" : player!.hand ] ]
                } else if obj?.player2.id == "" {
                    data = [ "player2" : [ "id" : player!.id, "hand" : player!.hand ] ]
                } else if obj?.player3.id == "" {
                    data = [ "player3" : [ "id" : player!.id, "hand" : player!.hand ] ]
                } else {
                    data = [ "player4" : [ "id" : player!.id, "hand" : player!.hand ] ]
                }
                CloudFS.updateGame(docId: idToJoin!, data: data, completion: { [self] error in
                    if error != nil {
                        let alert = UIAlertController(title: "Could not join game", message: "Please check your internet connection and try again. If the problem persists, please submit a support ticket with the attached error code. Error code: GameLobby.getAndListen.updateGame", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                    }
                })
            }
            
            updateUI(updatedGame: obj!)
            game = obj
        })
    }
    
    // The game was updated, so check if UI needs to change
    func updateUI(updatedGame: Game) {
        // Check if code is set yet
        if codeLabel.text == "" && updatedGame.code > -1 {
            codeLabel.text = String(updatedGame.code)
        }
        
        if updatedGame.code == -1 {
            loadingViewLabel.text = "Generating game code..."
        } else {
            loadingView.isHidden = true
        }
        
        // Check if players are first loaded or changed
        if game == nil || updatedGame.player1 != game.player1 {
            updatePhotoDisplay(imageView: player1Image, playerId: updatedGame.player1.id)
        }
        if game == nil || updatedGame.player2 != game.player2 {
            updatePhotoDisplay(imageView: player2Image, playerId: updatedGame.player2.id)
        }
        if game == nil || updatedGame.player3 != game.player3 {
            updatePhotoDisplay(imageView: player3Image, playerId: updatedGame.player3.id)
        }
        if game == nil || updatedGame.player4 != game.player4 {
            updatePhotoDisplay(imageView: player4Image, playerId: updatedGame.player4.id)
        }
        
        // Check if enough players are present to start
        numPlayers = 0
        if updatedGame.player1.id != "" {
            numPlayers += 1
        }
        if updatedGame.player2.id != "" {
            numPlayers += 1
        }
        if updatedGame.player3.id != "" {
            numPlayers += 1
        }
        if updatedGame.player4.id != "" {
            numPlayers += 1
        }
        if numPlayers > 1 {
            startGameButton.isEnabled = true
            startGameButton.alpha = 1.0
        } else {
            startGameButton.isEnabled = false
            startGameButton.alpha = 0.5
        }
    }
    
    // Update photo display as players enter/leave game
    func updatePhotoDisplay(imageView: UIImageView, playerId: String) {
        if playerId == "" {
            imageView.image = animatedImage
            return
        } else if playerId == user.id {
            imageView.image = UIImage(data: user.profileImage ?? defaultImage.pngData()!)
        }
        
        // Get Player Profile Picture
        CloudFS.getUser(docId: playerId, completion: { [self, imageView] user in
            guard user != nil else {
                print("Error, could not get player \(playerId)")
                return
            }
            
            // If User has not set a profile photo, use default
            if user?.profilePhotoUrl == "" {
                imageView.image = self.defaultImage
                return
            }
            
            FSStorage.getProfilePicture(url: user!.profilePhotoUrl, completion: { [playerId, imageView] data in
                guard data != nil else {
                    print("Error, could not get profile image for player \(playerId)")
                    return
                }
                imageView.image = UIImage(data: data!)!
            })
        })
    }
    
    @IBAction func startGameTapped(_ sender: UIButton) {
        print("TODO: Build this functionality")
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        if numPlayers == 1 {
            CloudFS.deleteGame(docId: game.id!)
        } else {
            var dict: [String: Any];
            if game.player1.id == user.id! {
                dict = [ "player1" : [ "id": "", "hand": [] ] ]
            } else if game.player2.id == user.id! {
                dict = [ "player2" : [ "id": "", "hand": [] ] ]
            } else if game.player3.id == user.id! {
                dict = [ "player3" : [ "id": "", "hand": [] ] ]
            } else {
                dict = [ "player4" : [ "id": "", "hand": [] ] ]
            }
            CloudFS.updateGame(docId: game.id!, data: dict, completion: { error in
                if error != nil {
                    print(error.debugDescription)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
