//
//  ProfileViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import UIKit
import FirebaseAuth
import CoreData
import Photos

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    fileprivate var cellObjects: Array<TableCellProps> = []
    var currentUser: FirebaseAuth.User!
    var coreUser: CoreUser!
    let managedObjectContainer: NSPersistentContainer = CoreDataController.getInstance()
    let imagePickerController = UIImagePickerController()
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        // Remove back button text
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Add table cells
//        let preferences = TableCellProps(title: "Preferences", actionId: "prefs", iconName: "settings-icon")
        let support = TableCellProps(title: "Support", actionId: "support", iconName: "support-icon")
        let logOut = TableCellProps(title: "Log Out", actionId: "logOut", iconName: "logout-icon")
//        cellObjects.append(preferences)
        cellObjects.append(support)
        cellObjects.append(logOut)
        
        tableView.tableFooterView = UIView() // cover all extra lines without populated cells
        tableView.separatorInset.right = 20 // keep seperator lines from going to edge
        
        // create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))

        // add it to the image view;
        profileImage.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        profileImage.isUserInteractionEnabled = true
        
        updateHeader()
    }
    
    func updateHeader() {
        let userFetchRequest: NSFetchRequest = CoreUser.fetchRequest()
        do {
            let fetchResults = try managedObjectContainer.viewContext.fetch(userFetchRequest)

            coreUser = fetchResults[0]
            nameLabel.text = coreUser.displayName!
            profileImage.image = UIImage(data: coreUser.profileImage ?? UIImage(named: "warm-mountains")!.pngData()!)
        } catch {
            print(exception.self)
        }
    }

    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil { // profile photo tapped
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (alertAction) in
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (alertAction) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePickerController.sourceType = .camera
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Dismiss image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // Photo was selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.editedImage] as! UIImage
        
        // Get binary data for storing
        let data = chosenImage.jpegData(compressionQuality: 0.75)!
        
        // Save to firebase storage
        self.showSpinner(onView: self.view)
        FSStorage.addProfilePicture(userId: coreUser.id!, data: data, completion: { [self] url in
            guard url != nil else {
                self.removeSpinner()
                let alert = UIAlertController(title: "An error occurred", message: "Your profile photo could not be saved. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            CloudFS.updateUser(docId: self.coreUser.id!, data: ["profilePhotoUrl": url as Any], completion: { error in
                guard error == nil else {
                    print("Could not save photo")
                    return // The photo url didn't get saved, but this isn't the end of the world
                }
            })
            
            // Save to core data
            coreUser.profileImage = data
            CoreDataController.saveContext()
            profileImage.image = UIImage(data: coreUser.profileImage ?? UIImage(named: "warm-mountains")!.pngData()!)
            self.removeSpinner()
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        // Do any additional setup before the view appears
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.font: UIFont(name: "Gotham-Bold", size: 18)!]
        
        // Make profile photo circular
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
    }
    
    // Get number of cells in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellObjects.count
    }
    
    // Create cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableCell")!
        let props: TableCellProps = cellObjects[indexPath.row]
        let iconView: UIImageView = UIImageView(image: UIImage(named: props.iconName)!)
        cell.textLabel?.text = props.title
        cell.textLabel?.font = UIFont(name: "Gotham-Light", size: 17)!
        cell.accessoryView = iconView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let actionId: String = cellObjects[indexPath.row].actionId
        if actionId == "logOut" {
            let alert = UIAlertController(title: "Are you sure?", message: "You must be logged in to play the game!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { [self] _ in 
                let error = Authentication.logOut()
                guard error == nil else {
                    let alert = UIAlertController(title: "Could not log out", message: "This is an unexpected error. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                // Remove user from Core Data
                managedObjectContainer.viewContext.delete(self.coreUser)
                CoreDataController.saveContext()
                // navigate to WelcomeViewController
                let welcomeViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                welcomeViewController.modalPresentationStyle = .fullScreen
                welcomeViewController.sourceVC = "profile"
                welcomeViewController.onDoneBlock = { result in
                    guard result == true else {
                        return
                    }
                    self.updateHeader()
                }
                self.present(welcomeViewController, animated: false, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else if actionId == "prefs" {
            performSegue(withIdentifier: "ShowPreferences", sender: self)
        } else if actionId == "support" {
            performSegue(withIdentifier: "ShowSupport", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // height for tableview cells
    }

}

// Object class for defining the different properties of a
// table cell
private class TableCellProps {
    let title: String!
    let actionId: String!
    let iconName: String!
    
    init(title: String, actionId: String, iconName: String) {
        self.title = title
        self.actionId = actionId
        self.iconName = iconName
    }
}
