//
//  TintColorViewController.swift
//  MeetingRooms
//
//  Created by 김문옥 on 2017. 7. 12..
//  Copyright © 2017년 김문옥. All rights reserved.
//

import UIKit

enum TintColor:Int {
    case BLUE = 0, RED, GREEN, PURPLE
    
    var color:UIColor { get{
        switch self {
        case .BLUE:
            return UIColor.blue
        case .RED:
            return UIColor.red
        case .GREEN:
            return UIColor.green
        case .PURPLE:
            return UIColor.purple
        }
    }}
}

let TintColorKey = "TintColor"

func applyTintColor(color:UIColor) {
    guard let window = UIApplication.shared.keyWindow else {
        return
    }
    window.tintColor = color
}

class TintColorViewController: UITableViewController {

    @IBOutlet weak var tintColorSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaultColor = UserDefaults.standard.integer(forKey: TintColorKey)
        self.tintColorSegment.selectedSegmentIndex = userDefaultColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tintColorChanged(_ sender: Any) {
        let selectedIndex = self.tintColorSegment.selectedSegmentIndex
        UserDefaults.standard.set(selectedIndex, forKey: TintColorKey)
        guard let changedColor = TintColor(rawValue: selectedIndex)?.color else {
            return
        }
        applyTintColor(color: changedColor)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
