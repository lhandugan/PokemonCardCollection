//
//  SetListViewController.swift
//  PokemonCardCollection
//
//  Created by LaDonna Handugan on 5/11/19.
//  Copyright © 2019 LaDonna Handugan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON


class SetListViewController : UITableViewController {
    
    var cardSetArray = [CardSet]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let setBaseURL = "https://api.pokemontcg.io/v1/sets"
    let cardBaseURL = "https://api.pokemontcg.io/v1/cards"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCardSets()
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath)
        
        let cardSet = cardSetArray[indexPath.row]
        cell.textLabel?.text = cardSet.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardSetArray.count
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCards", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! CardListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            if cardSetArray[indexPath.row].needToUpdate {
                getCardData(cardSetArray[indexPath.row])
            }
            
            destinationVC.selectedCardSet = cardSetArray[indexPath.row]
            print("destinationVC card set array set")
        }
        
        
    }
    
    
    
    //MARK: - Networking
    
    func getCardSetData (url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the pokemon card set data")
                let responseJSON : JSON = JSON(response.result.value!)
                
                self.updateCardSetData(json: responseJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
            
        }
    }
    
    

    
    
    //MARK: - JSON handling
    
    func updateCardSetData (json : JSON) {
        //print(json)
        
        for (_,cardSet):(String, JSON) in json["sets"] {
            //print(cardSet)

            let newUpdatedAt = dateFromString(cardSet["updatedAt"].stringValue)

            // Check if cardSet is already in CoreData
            if let index = cardSetArray.firstIndex(where: {$0.code == cardSet["code"].stringValue} ) {
                // Check if cardSet has been updated since last loaded
                if cardSetArray[index].updatedAt! < newUpdatedAt {
                    cardSetArray[index].updatedAt = newUpdatedAt
                    cardSetArray[index].needToUpdate = true
                }
            } else {
                let newCardSet = createNewCardSet(cardSet)
                cardSetArray.append(newCardSet)
            }
        }

        cardSetArray.sort { $0.releaseDate! < $1.releaseDate! }
        
        saveData()
    }
    
    func createNewCardSet (_ cardSet: JSON) -> CardSet {
        let newCardSet = CardSet(context: context)
        newCardSet.code = cardSet["code"].stringValue
        newCardSet.name = cardSet["name"].stringValue
        newCardSet.totalCards = cardSet["totalCards"].int64Value
        newCardSet.symbolUrl = cardSet["symbolUrl"].stringValue
        newCardSet.logoUrl = cardSet["logoUrl"].stringValue
        newCardSet.needToUpdate = true
        newCardSet.updatedAt = dateFromString(cardSet["updatedAt"].stringValue)
        newCardSet.releaseDate = releaseDateFromString(cardSet["releaseDate"].stringValue)
        
        return newCardSet
    }
    
    
    func dateFromString (_ dateString: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter.date(from: dateString)!
    }
    
    func releaseDateFromString (_ dateString: String) -> Date {
        
        let releaseDateFormatter = DateFormatter()
        releaseDateFormatter.dateFormat = "MM/dd/yyyy"
        releaseDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return releaseDateFormatter.date(from: dateString)!
        
    }
    
    
    
    
    func getCardData (_ cardSet : CardSet) {
        
        let endURL = "?setCode=\(cardSet.code ?? "")"
        let finalURL = cardBaseURL + endURL
        print(finalURL)
        
        Alamofire.request(finalURL, method: .get).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the pokemon card data")
                let responseJSON : JSON = JSON(response.result.value!)
                
                self.updateCardData(cardSet: cardSet, json: responseJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateCardData (cardSet: CardSet, json : JSON) {
        //print(json)
        
        var cardArray = loadCards(set: cardSet)
        
        for (_,card):(String,JSON) in json["cards"] {
            
            //Check if card is already in Core Data
            //If yes, update it.
            //If no, add it.
            
            if let index = cardArray.firstIndex(where: {$0.id == card["id"].stringValue}) {
                cardArray[index].name = card["name"].stringValue
                cardArray[index].rarity = card["rarity"].stringValue
                cardArray[index].number = card["number"].int64Value
                
            } else {
                let newCard = Card(context: context)
                newCard.name = card["name"].stringValue
                newCard.id = card["id"].stringValue
                newCard.number = card["number"].int64Value
                newCard.rarity = card["rarity"].stringValue
                newCard.parentSet = cardSet
                
                cardArray.append(newCard)
            }

        }
        
        cardSet.needToUpdate = false
        saveData()
        print("card data saved")
        

    }
    
    
    
    //MARK: - CoreData
    
    func loadCardSets () {
        
        let request : NSFetchRequest<CardSet> = CardSet.fetchRequest()
        
        do {
            cardSetArray = try context.fetch(request)
            cardSetArray.sort { $0.releaseDate! < $1.releaseDate! }
            
        } catch {
            print("Error loading sets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving data, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCards (set : CardSet) -> [Card] {
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        var cardArray = [Card]()
        
        do {
            cardArray = try context.fetch(request)
        } catch {
            print("Error loading cards for set, \(error)")
        }
        
        return cardArray
        
    }
    
    @IBAction func ReloadButtonPressed(_ sender: UIBarButtonItem) {
        print("reload button pressed")
        getCardSetData(url: setBaseURL)
    }
}
