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
    var subEvents: [SubEvent]
}

struct SubEvent {
    var desc: String
}

class HistoryViewController: UIViewController {
    var ref: FIRDatabaseReference!
    
    fileprivate var history: [Event] = []
    fileprivate var name: String?
    
    fileprivate var tableView:UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventCell.self, forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.groupTableViewBackground
        
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

        case let .setupNewEvent(section):
            print("New event added after section: \(section)")

        case let .insertEvent(section):
            print(section)
            if let timelineName = name {
                let vc = AddEventViewController.create(insertEventAt: section, history: history, timelineName: timelineName)
                navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func handleError(_ error: TimelineError?) {
        guard let error = error else { return }
        
        switch error {
        case .gameNotFound, .emptyTimelineName:
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
                        newEvent.subEvents.append(SubEvent(desc: subDesc))
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

    @objc func tappedSection(_ sender:UIButton) {
        coordinator?.notify(event: .addNewSubEvent(sender.tag))
    }

    @objc func insertEvent(_ sender: UIButton) {
        coordinator?.notify(event: .insertEvent(sender.tag))
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = history[indexPath.section].subEvents[indexPath.row]
        print(event)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history[section].subEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.event = history[indexPath.section].subEvents[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return history[safe: section] != nil ? UITableViewAutomaticDimension : 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let event = history[safe: section] {
            let header = UIStackView()
            header.distribution = .fillProportionally
            header.axis = .horizontal
            header.alignment = .fill

            let title = UILabel(frame: .zero)
            title.numberOfLines = 0
            title.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            title.textAlignment = .left
            title.text = "  " + event.name
            title.textColor = UIColor.globalColor

            let spacer = UIView(frame: .zero)

            let addButton = UIButton(type: .contactAdd)
            addButton.tag = section
            addButton.tintColor = UIColor.globalColor
            addButton.addTarget(self, action: #selector(tappedSection(_:)), for: .touchUpInside)

            let trailing = UIView(frame: .zero)

            header.addArrangedSubview(title)
            header.addArrangedSubview(spacer)
            header.addArrangedSubview(addButton)
            header.addArrangedSubview(trailing)

            title.snp.makeConstraints { (make) in
                make.height.greaterThanOrEqualTo(40)
            }

            spacer.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(5)
            }

            trailing.snp.makeConstraints { (make) in
                make.width.greaterThanOrEqualTo(5)
            }

            return header
        }

        return UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 54) )
        footer.backgroundColor = UIColor.groupTableViewBackground

        let addButton = UIButton(type: .custom)
        addButton.tag = section
        addButton.setTitle("Add Event", for: .normal)
        addButton.setTitleColor(UIColor.globalColor, for: .normal)
        addButton.addTarget(self, action: #selector(insertEvent(_:)), for: .touchUpInside)
        addButton.layer.cornerRadius = 4
        addButton.clipsToBounds = true

        footer.addSubview(addButton)
        addButton.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.center.equalToSuperview()
        }

        return footer
    }
}
