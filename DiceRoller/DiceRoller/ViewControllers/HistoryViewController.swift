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
    fileprivate var name: String?
    
    fileprivate var tableView:UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.allowsSelection = true
        tv.estimatedRowHeight = 120
        return tv
    }()
    
    
    fileprivate var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
    typealias Dependencies = String //in case we need more later, just send in a tuple (String, String, Int...)
    static func create(deps: Dependencies) -> HistoryViewController {
        let vc = HistoryViewController()
        vc.name = deps //timeLineName
        
        var initialState = TimelineState()
        initialState.timelineName = deps
        
        let coordinator = EventCoordinator(eventHandler: TimelineHandler(), state: initialState)
        vc.coordinator = coordinator
        coordinator.onStateChange = { [weak vc] state in vc?.updateState(state: state) }

        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        self.title = "History"

        setupView()
    }
    
    func setupView() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEvent))
        navigationItem.setRightBarButton(addButton, animated: true)

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
        
        self.coordinator?.notify(event: .getHistory)
    }
    
    func updateState(state: TimelineState) {
        performService(state: state)
        performNavigation(state: state)
        handleError(state.error)
    }
    
    func performService(state: TimelineState) {
        guard let service = state.service else { return }
        
        switch service {
        case .getHistory:
            guard let timelineName = state.timelineName else { return }
            getHistory(timelineName: timelineName)
            
        default: break
            
        }
    }
    
    func performNavigation(state: TimelineState) {
        guard let navigationState = state.navigation else { return }
        switch navigationState {
        case .history, .setupGame:
            break
        }
    }
    
    func handleError(_ error: TimelineError?) {
        guard let error = error else { return }
        
        switch error {
        case .gameNotFound:
            let alert = UIAlertController(title: "Uh Oh", message: "Game not found, do you want to create one?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                self?.coordinator?.notify(event: .createTimeline)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
            self.navigationController?.present(alert, animated: true, completion: nil)
            
        case .emptyTimelineName:
            break
        }
    }
    
    @objc func addEvent() {
        print("Add")
    }
    
    func getHistory(timelineName: String) {
        //.child("GameExample")
        ref.child("Histories").child(timelineName).observe(.value, with: {[weak self] (snapshot: FIRDataSnapshot!) in
            self?.history = []
            let enumerator = snapshot.children
            while let event = enumerator.nextObject() as? FIRDataSnapshot {
                let value = event.value as? NSDictionary
                let name = value?["Name"] as? String ?? ""
                var newEvent = Event(name: name, subEvents: [])
                
                if let events = value?["SubEvents"] as? NSArray {
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
