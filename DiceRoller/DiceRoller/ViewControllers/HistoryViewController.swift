//
//  HistoryViewController.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/24/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseDatabase

struct Event {
    var name: String
    var subEvents: [SubEvents]
}

struct SubEvents {
    var desc: String
}

class HistoryViewController: UIViewController {
    var ref: FIRDatabaseReference!
    
    fileprivate var history: [Event] = []
    
    fileprivate var tableView:UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.allowsSelection = true
        tv.estimatedRowHeight = 120
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventCell.self, forCellReuseIdentifier: "EventCell")
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getHistory()
        
    }
    
    func getHistory() {
        history = []
        ref.child("Histories").child("GameExample").observe(.value, with: {[weak self] (snapshot: FIRDataSnapshot!) in
            print(snapshot)
            let enumerator = snapshot.children
            while let event = enumerator.nextObject() as? FIRDataSnapshot {
                let value = event.value as? NSDictionary
//                let value = snapshot.value as? NSDictionary
                let name = value?["Name"] as? String ?? ""
                var newEvent = Event(name: name, subEvents: [])
                
                if let events = value?["SubEvents"] as? NSArray {
                    print(events)
                    for i in 0..<events.count {
                        let subDesc = events[i] as? String ?? ""
                        newEvent.subEvents.append(SubEvents(desc: subDesc))
                    }
                }
                
                self?.history.append(newEvent)
            }
            
            self?.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = history[indexPath.row]
        print("Sub events =  \(event.subEvents)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.event = history[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 1) )
    }
}
