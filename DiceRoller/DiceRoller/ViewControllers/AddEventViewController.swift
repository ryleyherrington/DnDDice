//
//  AddEventViewController.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 6/20/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseDatabase

class AddEventViewController: UIViewController {

    var ref: FIRDatabaseReference!
    fileprivate var timelineName: String = ""
    fileprivate var history: [Event] = []
    fileprivate var eventNumber: Int = -1

    var addButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        b.titleLabel?.textColor = UIColor.white
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        return b
    }()

    fileprivate var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
    static func create(insertEventAt: Int, history: [Event], timelineName: String) -> AddEventViewController {
        let vc = AddEventViewController()

        var initialState = TimelineState()

        let coordinator = EventCoordinator(eventHandler: TimelineHandler(), state: initialState)
        vc.coordinator = coordinator
        coordinator.onStateChange = { [weak vc] state in vc?.updateState(state: state) }

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        self.title = "Add Event"

        setupView()
    }

    func setupView() {
        view.addSubview(addButton)

        addButton.setTitle("Add Event", for: .normal)
        addButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            break

        default: break

        }
    }

    func performNavigation(state: TimelineState) {
        guard let navigationState = state.navigation else { return }
        switch navigationState {
        case .history, .setupGame, .setupNewEvent(_), .insertEvent(_):
            break
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
        guard eventNumber != -1 else { return }
        guard timelineName != "" else { return }

//        var children = history[eventNumber].subEvents
 //       children.append(SubEvent(desc: "ADDING CHILD"))

        let example = ref.child("Histories").child(timelineName).child("\(eventNumber)").child("SubEvents").childByAutoId()
        example.setValue("Testing adding sub child")
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
