//
//  ViewController.swift
//  MatchApp
//
//  Created by Nitisha on 12/22/19.
//  Copyright © 2019 Nitisha. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var model = CardModel()
    var cardArray = [Card]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var firstFlippedCardIndex: IndexPath?
    var timer:Timer?
    var milliseconds:Float = 30 * 1000     // 30 seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate - for any events that happen in the grid
        collectionView.delegate = self
        
        // data source - for the data that is going to power the grid
        collectionView.dataSource = self
        
        // Call the getCards() method of the CardModel
        cardArray = model.getCards()
        
        // Create timer
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        
        // Keep the timer running when scrolling
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        SoundManager.playSound(.shuffle)
    }
    
    // MARK: - Timer Methods
    @objc func timerElapsed(){
        milliseconds -= 1
        
        // Convert to seconds
        let seconds = String(format: "%.2f", milliseconds/1000)
        
        // Set label
        timerLabel.text = "Time Remaining: \(seconds)"
        
       if milliseconds <= 0 {
        // Stop when timer reaches 0
        timer?.invalidate()
        
        // Change the color of the label
        timerLabel.textColor = UIColor.red
        
        // Check for remaining matches
        
        checkGameEnded()
       }
    }

    // MARK:- UICollectionView Protocol methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // IndexPath - describes which cell the collection view is asking for
        // Try to get a cell that it can reuse or create a new one
        
        // Cast as CardCollectionViewCell -> able to access setCards method
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        
        // Get the card that the collection view is trying to display
        // Row property in the index path - indicates which item it is trying to display
        let card = cardArray[indexPath.row]
        
        // Set that card for the cell
        cell.setCard(card)
        
        return cell
    }
    
    // When the user taps on a cell - capture that information
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Check if there's any time left
        if milliseconds <= 0 {
            return
        }
        
        // Get the cell that the user selected
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        // Get the card that the user selected
        let card = cardArray[indexPath.row]
        
        if card.isFlipped == false && card.isMatched == false {
            
            // Flip the card
            cell.flip()
            card.isFlipped = true       // Set the status of the card
            
            // Play the flip sound
            SoundManager.playSound(.flip)
            
            // Determine if it's the first card or the second card that's flipped over
            if firstFlippedCardIndex == nil{
                // If this is the first card being flipped
                firstFlippedCardIndex = indexPath
            }
                
            else{
                // This is the second card being flipped
                
                // Perform the matching logic
                checkforMatches(indexPath)
            }
        }
    } // End of didSelectItemAt func
    
    // MARK: - Game logic methods
    
    func checkforMatches(_ secondFlippedCardIndex: IndexPath){
        
        // Get the cells for the two cards that were revealed
        
        // as? - sometimes it cannot find the flipped card index items?
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        // Get the cards for the two cards that were revealed
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        // Compare the two cards
        if cardOne.imageName == cardTwo.imageName{
            
            // It's a match
            // Play the match sound
            SoundManager.playSound(.match)
            
            // Set the statuses of the cards
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // Remove the cards from the grid
            
            // Optional chaining - if cardonecell is nil, it will not call the remove method
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Check if there are cards left unmatched
            checkGameEnded()
        }
        else {
            
            // It's not a match
            // Play the no match sound
            SoundManager.playSound(.nomatch)
            
            // Set the statuses of the cards
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Flip the cards back
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
        }
        
        // Tell the collectionview to reload the cell of the first card if it is nil
        if cardOneCell == nil {
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        // Reset the property that sets the firstFlippedCardIndex
        firstFlippedCardIndex = nil
        
    } // End of checkForMatches
    
    func checkGameEnded(){
        
        // Determine if there are any cards unmatched
        var isWon = true
        
        for card in cardArray{
            if card.isMatched == false{
                isWon = false
                break
            }
        }
        
        //Message variables
        var title = ""
        var message = ""
        
        // If not - user has won, stop the timer
        if isWon == true{
            if milliseconds > 0 {
                timer?.invalidate()
            }
            
            title = "Congratulations"
            message = "You've Won!"
        }
        else{
            // If there are unmatched cards, check if there is any time left
            if milliseconds > 0 {
                return              // There is still time left
            }
            
            title = "Game Over"
            message = "You've Lost :("
        }
        
        // Show won/lost message
        showAlert(title, message)
    }
    
    func showAlert(_ title:String, _ message:String){
        
        // Alert message to display
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Let the user get rid of the message by pressing "Okay"
        
        //let alertAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {action -> Void in self.resetApp()})
        
        alert.addAction(alertAction)
        
        // Present the message
        present(alert, animated: true, completion: nil)
    }
    
    // TODO: Add "Play Again" and "Exit" alert buttons
    
    // Reset the app after the user presses "OK"
    func resetApp() {
        UIApplication.shared.windows[0].rootViewController = UIStoryboard(
            name: "Main",
            bundle: nil
            ).instantiateInitialViewController()
    }
    
} // End of view controller class

