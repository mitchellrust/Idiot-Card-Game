//
//  PlayerHandFlowLayout.swift
//  Idiot Card Game
//
//  Created by Mitchell Rust on 1/12/21.
//

import UIKit

class PlayerHandFlowLayout: UICollectionViewFlowLayout {

    var overlap: CGFloat = 30

    override init() {
        super.init()
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func sharedInit() {
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        let attributesArray = super.layoutAttributesForElements(in: rect)

        for attributes in attributesArray! {
            var xPosition = attributes.center.x
            let yPosition = attributes.center.y

            if attributes.indexPath.row != 0 {
                xPosition -= self.overlap * CGFloat(attributes.indexPath.row)
            }

            attributes.center = CGPoint(x: xPosition, y: yPosition)
        }

        return attributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forCellWith: indexPath)
    }
    
}
