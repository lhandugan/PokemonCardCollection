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
    let baseURL = "https://api.pokemontcg.io/v1/sets"
    
    
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
            destinationVC.selectedCardSet = cardSetArray[indexPath.row]
        }
        
    }
    
    
    
    //MARK: - Networking
    
    func getCardSetData (url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the pokemon data")
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
        
        saveCardSets()
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
    
    
    
    //MARK: - CoreData
    
    func loadCardSets (with request: NSFetchRequest<CardSet> = CardSet.fetchRequest()) {
        
        do {
            cardSetArray = try context.fetch(request)
            cardSetArray.sort { $0.releaseDate! < $1.releaseDate! }
            
        } catch {
            print("Error loading sets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    func saveCardSets() {
        
        do {
            try context.save()
        } catch {
            print("Error saving sets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func ReloadButtonPressed(_ sender: UIBarButtonItem) {
        print("reload button pressed")
        getCardSetData(url: baseURL)
    }
}
