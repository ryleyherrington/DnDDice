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
    private var timelineName: String = ""
    private var history: [Event] = []
    private var eventNumber: Int = -1

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

    private var textField: UITextField = {
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

    private var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
    static func create(insertEventAt eventNum: Int, history: [Event], timelineName: String) -> AddEventViewController {

        let vc = AddEventViewController()
        vc.eventNumber = eventNum
        vc.timelineName = timelineName
        vc.history = history

        let initialState = TimelineState()
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
        view.backgroundColor = UIColor.white

        view.addSubview(closeButton)
        view.addSubview(descLabel)
        view.addSubview(textField)
        view.addSubview(addButton)

        addButton.setTitle("Add Event", for: .normal)
        addButton.addTarget(self, action: #selector(addEvent), for: .touchUpInside)

        textField.placeholder = "Enter event name"
        descLabel.text = "Add information to Event: \n\(history[eventNumber].name)"

        descLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        textField.snp.makeConstraints { (make) in
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

        closeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(25)
            make.width.equalTo(25)
        }

    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
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
        coordinator?.notify(event: .addEvent)
    }

    func addSubEventService() {
        guard eventNumber != -1 && timelineName != "" else { return }

        let normalizedEventNumber = eventNumber + 1 //this is because we're
        let childEventNumber = history[eventNumber].subEvents.count  // +1
        let eventInfo = textField.text != "" ? textField.text : "Adding to event:\(eventNumber) and subEvent:\(childEventNumber)"
//        if eventInfo?.count > 200 {
//            coordinator?.notify(event: .inputDescriptionTooLarge)
//        }

        let example = ref.child("Histories").child(timelineName).child("\(normalizedEventNumber)").child("SubEvents").child("\(childEventNumber)")
        example.setValue(eventInfo)

        close()
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
