//
//  DetailViewController.swift
//  MP4
//
//  Created by Oti Oritsejafor on 10/30/19.
//  Copyright © 2019 Magloboid. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource,
UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var runs: [Run]?
    
    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Run>!
    
    fileprivate func setupFetchResultsController()  {
        let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataStack.context, sectionNameKeyPath: nil, cacheName: "runs")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try runs = DataStack.context.fetch(fetchRequest)
        } catch {
            fatalError("The fetch could not be performed")
        }
        setupFetchResultsController()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func configureUI() {
        self.configureNavBar(withTitle: "Past Runs", prefersLargeTitles: true, color: UIColor.white, titleColor: UIColor.black)
        tableView.tableFooterView = UIView()
    }
    
    func deleteEntity(at indexPath: IndexPath) {
        let runToDelete = runs![indexPath.row]
        DataStack.persistentContainer.viewContext.delete(runToDelete)
        
        runs!.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)

        DataStack.saveContext()
     }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let runs = runs { return runs.count }
        else {
            return 0
        }
       // return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
        
        let currentRun = runs![indexPath.row]
        cell.configureData(currentRun: currentRun)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEntity(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPath" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedRun = runs![indexPath.row]
                let locsToSend = Array(selectedRun.locations!)
                
                let controller = segue.destination as! PathViewController
                controller.locations = locsToSend as! [Location]
            }
        }
    }

}

extension HistoryViewController {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: break // tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
}
