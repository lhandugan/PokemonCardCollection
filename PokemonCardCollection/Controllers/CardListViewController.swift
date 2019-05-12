//
//  CardListViewController.swift
//  PokemonCardCollection
//
//  Created by LaDonna Handugan on 5/11/19.
//  Copyright © 2019 LaDonna Handugan. All rights reserved.
//

import UIKit
import CoreData

class CardListViewController: UITableViewController {
    
    var cardArray = [Card]()
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var tempCard = Card(context: context)
        tempCard.name = "Bulbasaur"
        tempCard.id = "base1-44"
        
        cardArray.append(tempCard)
        
        var tempCard2 = Card(context: context)
        tempCard2.name = "Charmander"
        tempCard2.id = "base1-46"
        
        cardArray.append(tempCard2)
        
        tableView.reloadData()
        
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
    
}
