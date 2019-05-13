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

//        var tempCardSet = CardSet(context: context)
//        tempCardSet.name = "Base"
//
//        cardSetArray.append(tempCardSet)
        
        let finalURL = baseURL
        getData(url: finalURL)
        
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
    
    func updateData (json : JSON) {
        var newCardSetArray = [CardSet]()
        //print(json)
        
        for (_,cardSet):(String, JSON) in json["sets"] {
            //print(cardSet)
            let newCardSet = CardSet(context: self.context)
            newCardSet.name = cardSet["name"].stringValue
            newCardSet.releaseDate = cardSet["releaseDate"].stringValue
            
            newCardSetArray.append(newCardSet)
        }
        
        //let sortedNewCardSetArray = newCardSetArray.sorted {  $0.releaseDate < $1.releaseDate  }
        
        self.cardSetArray = newCardSetArray
        
        self.tableView.reloadData()
    }
    
}
