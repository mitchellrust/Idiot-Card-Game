//
//  PreferencesViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/7/2021.
//

import UIKit

class PreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferencesCell")!
        cell.textLabel?.text = "Preference"
        cell.textLabel?.font = UIFont(name: "Gotham-Light", size: 17)!
        return cell
    }

}
