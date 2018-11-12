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

enum EventType {
    case mainEvent
    case subEvent
}

class AddEventViewController: UIViewController {

    var ref: FIRDatabaseReference!
    var eventType: EventType = .mainEvent
    private var timelineName: String = ""
    private var history: [Event] = []
    private var eventNumber: Int = -100

    private var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "closeIcon"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    private var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private var numberField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.textAlignment = .center
        tf.clipsToBounds = true
        return tf
    }()

    private var eventInfoField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.textAlignment = .center
        tf.clipsToBounds = true
        return tf
    }()

    private var addButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor.globalColor
        b.titleLabel?.textColor = UIColor.white
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        return b
    }()

    var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
    static func create(insertEventAt eventNum: Int, history: [Event], timelineName: String, eventType: EventType = .subEvent) -> AddEventViewController {

        let vc = AddEventViewController()
        vc.eventNumber = eventNum
        vc.history = history
        vc.eventType = eventType

        var initialState = TimelineState()
        initialState.events = history
        initialState.timelineName = timelineName

        let coordinator = EventCoordinator(eventHandler: TimelineHandler(), state: initialState)
        vc.coordinator = coordinator
        coordinator.onStateChange = { [weak vc] state in vc?.updateState(state: state) }

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
        self.title = "Add Event"

        if eventType == .mainEvent {
            setupEventView()
        } else {
            setupSubEventView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        coordinator?.start()
    }

    func setupEventView() {
        view.backgroundColor = UIColor.white

        view.addSubview(descLabel)
        view.addSubview(eventInfoField)
        view.addSubview(addButton)

        addButton.setTitle("Add Event", for: .normal)
        addButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        eventInfoField.placeholder = "Enter event name"
        if let eventName = history[safe: eventNumber]?.name {
            descLabel.text = "Add information to Event: \n\(eventName)"
        }

        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        eventInfoField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.center.equalToSuperview()
            make.height.equalTo(44)
        }

        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }

    func setupSubEventView() {
        view.backgroundColor = UIColor.white

        view.addSubview(descLabel)
        view.addSubview(eventInfoField)
        view.addSubview(addButton)

        addButton.setTitle("Add Event", for: .normal)
        addButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        eventInfoField.placeholder = "Enter event name"
        if let eventName = history[safe: eventNumber]?.name {
            descLabel.text = "Add information to Event: \n\(eventName)"
        }
        eventInfoField.delegate = self

        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        eventInfoField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }

        addButton.snp.makeConstraints { (make) in
//            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            make.top.equalTo(eventInfoField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }

    @objc func close() {
        navigationController?.popViewController(animated: true)
    }

    func updateState(state: TimelineState) {
        history = state.events
        performService(state: state)
        performNavigation(state: state)
        handleError(state.error)
    }

    func performService(state: TimelineState) {
        guard let service = state.service else { return }

        switch service {
        case .getHistory:
            break

        case let .addEvent(timelineName, eventIndex):
            addNewEventService(timelineName: timelineName, eventIndex: eventIndex)

        case let .addSubEvent(timelineName, insertIndex, childIndex, eventInfo):
            addSubEventService(timelineName: timelineName, eventIndex: insertIndex, childEventIndex: childIndex, eventInfo: eventInfo)

        default:
            break

        }
    }

    func performNavigation(state: TimelineState) {
        guard let navigationState = state.navigation else { return }
        switch navigationState {

        case .history, .setupGame, .setupEvent, .setupSubEvent(_):
            break
        }
    }

    func handleError(_ error: TimelineError?) {
        guard let error = error else { return }

        switch error {
        case .gameNotFound, .emptyTimelineName:
            break
        case .notEnoughInfoFail:
            print("event was -1 or timeline was empty")
        case .notEnoughInfoSoft:
            print("Failed softly")
        case .tooManyCharacters:
            print("Too many characters")
        }
    }

    @objc func addEvent() {
        if let eventInfo = eventInfoField.text {
            switch eventType {
            case .mainEvent:
                coordinator?.notify(event: .submitEvent(eventInfo, eventNumber))

            case .subEvent:
                coordinator?.notify(event: .submitSubEvent(eventInfo, eventNumber))
            }
        }
    }

    func addNewEventService(timelineName: String, eventIndex: Int = -100) {
        let newEvent = ref.child("Histories").child(timelineName).child("\(eventIndex-1)").child("Name")
        newEvent.setValue("New event getting inserted")

        let newSub = ref.child("Histories").child(timelineName).child("\(eventIndex-1)").child("SubEvents").child("0")
        newSub.setValue("Example sub event")

        close()
    }

    func addSubEventService(timelineName: String, eventIndex: Int, childEventIndex: Int, eventInfo: String) {
        let newChild = ref.child("Histories").child(timelineName).child("\(eventIndex)").child("SubEvents").child("\(childEventIndex)")
        newChild.setValue(eventInfo)

        close()
    }
}

extension AddEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
