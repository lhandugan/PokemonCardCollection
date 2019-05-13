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
        var newCardSetArray = [CardSet]()
        //print(json)
        
        for (_,cardSet):(String, JSON) in json["sets"] {
            //print(cardSet)
            let newCardSet = CardSet(context: self.context)
            newCardSet.name = cardSet["name"].stringValue
            newCardSet.code = cardSet["code"].stringValue
            newCardSet.totalCards = cardSet["totalCards"].int64Value
            newCardSet.symbolUrl = cardSet["symbolUrl"].stringValue
            newCardSet.logoUrl = cardSet["logoUrl"].stringValue
            
            let releaseDateFormatter = DateFormatter()
            releaseDateFormatter.dateFormat = "MM/dd/yyyy"
            releaseDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            newCardSet.releaseDate = releaseDateFormatter.date(from: cardSet["releaseDate"].stringValue)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            newCardSet.updatedAt = dateFormatter.date(from: cardSet["updatedAt"].stringValue)
            
            
            
            print(newCardSet.code!)
            print(newCardSet.releaseDate!)
            print(newCardSet.updatedAt!)
            
            
            newCardSetArray.append(newCardSet)
        }
        
        
        
        
//        for newCardSet : CardSet in newCardSetArray {
//
//            if let index = cardSetArray.firstIndex(where: { $0.code == newCardSet.code }) {
//                let oldUpdatedAt = cardSetArray[index].updatedAt!
//                let newUpdatedAt = newCardSet.updatedAt!
//
//
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
//                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//                let oldDate = dateFormatter.date(from: oldUpdatedAt)
//                let newDate = dateFormatter.date(from: newUpdatedAt)
//
//                if oldDate != newDate {
//                    cardSetArray[index].needToUpdate = true
//                }
//
//            } else {
//
//            }
        
//        }
        
        
        
        
        //let sortedNewCardSetArray = newCardSetArray.sorted {  $0.releaseDate < $1.releaseDate  }
        
        self.cardSetArray = newCardSetArray
        
        
        do {
            try context.save()
        } catch {
            print("Error saving sets, \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: -
    
    func loadCardSets (with request: NSFetchRequest<CardSet> = CardSet.fetchRequest()) {
        
        do {
            cardSetArray = try context.fetch(request)
            cardSetArray.sort { $0.releaseDate! < $1.releaseDate! }
            
        } catch {
            print("Error loading sets, \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    
    
    @IBAction func ReloadButtonPressed(_ sender: UIBarButtonItem) {
        print("reload button pressed")
        getCardSetData(url: baseURL)
    }
}
