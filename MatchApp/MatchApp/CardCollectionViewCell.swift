//
//  CardCollectionViewCell.swift
//  MatchApp
//
//  Created by Nitisha on 12/23/19.
//  Copyright © 2019 Nitisha. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var frontImageView: UIImageView!

    @IBOutlet weak var backImageView: UIImageView!

    var card:Card?
    
    func setCard(_ card:Card){
        
        // Keep track of the card that gets passed in
        self.card = card
        
        if card.isMatched == true {
            
            // If the card has been matched then make the image views invisible
            backImageView.alpha = 0
            frontImageView.alpha = 0
            
            return          // Exit the method if the statement is true
        }
        else {
            
            // If the card hasn't been matched then make the image views visible
            backImageView.alpha = 1
            frontImageView.alpha = 1
        }
            
        frontImageView.image = UIImage(named: card.imageName)
        
        // Reset the card statuses because the same cells can be reused at different times in the collection view 
        
        // Determine if the card is flipped up or flippe down
        if card.isFlipped == true{
            // Make sure the frontImageView is on top
            UIView.transition(from: backImageView, to: frontImageView, duration: 0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        }
        else{
            // Make sure the backImageView is on top
            UIView.transition(from: frontImageView, to: backImageView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
    }
    
    func flip(){
        UIView.transition(from: backImageView, to: frontImageView, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
    }
    
    func flipBack(){
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            UIView.transition(from: self.frontImageView, to: self.backImageView, duration: 0.3, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
    }
    
    func remove(){
        
        // Alpha is the opacity -> 0 - make them invisible
        
        // Removes both image views from being visible
        backImageView.alpha = 0
        
        // Add animations
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
            self.frontImageView.alpha = 0
        }, completion: nil)
        
    }

}
