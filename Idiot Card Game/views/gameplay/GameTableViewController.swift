//
//  GameTableViewController.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/10/21.
//

import UIKit

class GameTableViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @NibWrapped(OtherPlayerView.self)
    @IBOutlet var topPlayerView: UIView!
    
    @NibWrapped(OtherPlayerView.self)
    @IBOutlet var leftPlayerView: UIView!
    
    @NibWrapped(OtherPlayerView.self)
    @IBOutlet var rightPlayerView: UIView!
    
    @NibWrapped(BottomPlayerView.self)
    @IBOutlet var bottomPlayerView: UIView!
    
    let tempNumCells: Int = 3
    var flowLayout: PlayerHandFlowLayout!
    
    var topView: OtherPlayerView!
    var leftView: OtherPlayerView!
    var rightView: OtherPlayerView!
    var bottomView: BottomPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        flowLayout = PlayerHandFlowLayout()
        
        topView = _topPlayerView.unwrapped
        topView.displayNameLabel.text = "allioharra"
        
        leftView = _leftPlayerView.unwrapped
        leftView.displayNameLabel.text = "soup"
        
        rightView = _rightPlayerView.unwrapped
        rightView.displayNameLabel.text = "rachelahrens"
        
        bottomView = _bottomPlayerView.unwrapped
        bottomView.displayNameLabel.text = "mitchellrust"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bottomView.handCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0)
        UIView.animate(withDuration: 3) {
            self.leftView.transform = CGAffineTransform.identity.rotated(by: .pi / -2).translatedBy(x: (self.leftView.frame.height * -1), y: (self.view.frame.width / -2) + (self.leftView.frame.height / 2) + 10)
//            self.rightView.transform = CGAffineTransform.identity.rotated(by: .pi / 2).translatedBy(x: 0, y: (self.view.frame.width / -2) + (self.rightView.frame.height / 2) + 10)
        }
        print(leftView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempNumCells
    }
    
    /*
     Makes cells fill entire height of collection view
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45.0, height: 65.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        if collectionView != bottomView.handCollectionView {
            cell.imageView.image = UIImage(named: "card_back")!
        } else { // get specific card from stack, temp for now
            cell.imageView.image = UIImage(named: "7_of_diamonds")
        }
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 45 * tempNumCells
        let totalSpacingWidth = Int(flowLayout.overlap * -1) * (tempNumCells - 1)

        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

}
