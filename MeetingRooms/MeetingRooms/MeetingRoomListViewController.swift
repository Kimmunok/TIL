//
//  MeetingRoomListViewController.swift
//  MeetingRooms
//
//  Created by 김문옥 on 2017. 6. 7..
//  Copyright © 2017년 김문옥. All rights reserved.
//

import UIKit

class MeetingRoomListViewController: UITableViewController {
    
    var service:Service?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.title = service?.name
        self.navigationItem.title = "\(service!.name) 정보"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //let categoryValues = Array(meetingRooms.values)[section]
        //let orderedMeetingRooms = meetingRooms.sorted(by: {$0.1.first!.1 < $1.1.first!.1})
        guard  let rowCount = service?.items?.count else {
            return 0
        }
        return rowCount
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        guard let meetingRoom = service?.items?[indexPath.row] else {
            return cell
        }
        
        
        cell.textLabel!.text = meetingRoom.name
        cell.detailTextLabel!.text = String(meetingRoom.capacity)

        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReservationSegue" {
            guard let destination = segue.destination as? ReservationListViewController , let selectedIndex = self.tableView.indexPathForSelectedRow?.row , let meetingRoom = service?.items?[selectedIndex] else {
                return
            }
            destination.meetingRoom = meetingRoom
        }
    }
    

}
