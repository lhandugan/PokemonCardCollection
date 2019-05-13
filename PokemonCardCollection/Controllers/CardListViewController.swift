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
    var selectedCardSet : CardSet?  {
        didSet{
            loadCards()
            print("load cards called")
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    
    //MARK: - CoreData
    
    func loadCards() {
        let request : NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "parentSet.code == %@", selectedCardSet!.code!)
        
        do {
            cardArray = try context.fetch(request)
            cardArray.sort { $0.number < $1.number }
        } catch {
            print("Error loading cards for set, \(error)")
        }
        
        tableView.reloadData()
    }
    
 
    
}
