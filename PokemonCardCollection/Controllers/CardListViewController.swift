//
//  CardListViewController.swift
//  PokemonCardCollection
//
//  Created by LaDonna Handugan on 5/11/19.
//  Copyright © 2019 LaDonna Handugan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class CardListViewController: UITableViewController {
    
    var cardArray = [Card]()
    var selectedCardSet : CardSet?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let baseURL = "https://api.pokemontcg.io/v1/cards"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        //let endURL = "?setCode=base1&name=char"
        let endURL = "?setCode=base1"
        //let endURL = "/xy7-54" //probably not going to do this here
        let finalURL = baseURL + endURL
        print(finalURL)
        getData(url: finalURL)
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)
        
        let card = cardArray[indexPath.row]
        
        cell.textLabel?.text = card.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    
    
    
    //MARK: - Networking
    
    func getData (url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                //print("Success! Got the pokemon data")
                let responseJSON : JSON = JSON(response.result.value!)
                
                self.updateData(json: responseJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
            }
            
            
        }
    }
    
    //MARK: - JSON Parsing
    
    func updateData (json : JSON) {
        var newCardArray = [Card]()
        //print(json)
        
        for (_,card):(String, JSON) in json["cards"] {
            //print(card)
            let newCard = Card(context: self.context)
            newCard.name = card["name"].stringValue
            newCard.id = card["id"].stringValue
            newCard.number = card["number"].int64Value
            
            newCardArray.append(newCard)
        }
        
        let sortedNewCardArray = newCardArray.sorted {  $0.number < $1.number  }
        
        self.cardArray = sortedNewCardArray
        
        self.tableView.reloadData()
    }
    
    
}
