//
//  GameModuleController.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 10/7/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation
import UIKit

class GameModuleController {

    fileprivate let coordinator: EventCoordinator<TimelineEvent, TimelineState>
    var navigationController: UINavigationController?

    let rootVC: UIViewController

    init() {
        coordinator = EventCoordinator(eventHandler: TimelineHandler(),
                                       state: TimelineState())
        //TODO: Add analytics
        //coordinator.subscribe(TimelineAnalytics())

        let gameVC = GameFinderViewController()
        gameVC.coordinator = coordinator
        rootVC = gameVC

        coordinator.onStateChange = {[weak self] state in self?.updateState(state: state)}
    }

    func updateState(state: TimelineState) {
        performService(state: state)
        performNavigation(state: state)
        updateChild(state: state)
//        handleError(error: state.error) {
//            navigationController?
//                .topViewController?
//                .present(alertError, animated: true, completion: nil)
//        }
    }

    func updateChild(state: TimelineState) {
        guard let vc = navigationController?.topViewController else { return }
        switch vc {
        case let vc as GameFinderViewController:
            vc.updateState(state: state)
        case let vc as HistoryViewController:
            vc.updateState(state: state)
        case let vc as AddEventViewController:
            vc.updateState(state: state)
        default: break
        }
    }

    func performService(state: TimelineState) {
        guard let service = state.service else { return }

        switch service {
        case .getHistory:
            break

        case let .submitEvent(timelineName, insertIndex, childIndex, eventInfo):
            addSubEventService(timelineName: timelineName, eventIndex: insertIndex, childEventIndex: childIndex, eventInfo: eventInfo)

        default: break

        }
    }

    func performNavigation(state: TimelineState) {
        guard let navigationState = state.navigation else { return }
//        switch navigationState {
//
//        case let .insertEvent(section):
//            let vc = AddEventViewController()
//            vc.coordinator = coordinator
//            navigationController?.pushViewController(vc, animated: true)
//
//        case .history, .setupGame, .setupNewEvent(_):
//            break
//        }
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

    func addSubEventService(timelineName: String, eventIndex: Int, childEventIndex: Int, eventInfo: String) {
//        let example = ref.child("Histories").child(timelineName).child("\(eventIndex)").child("SubEvents").child("\(childEventIndex)")
//        example.setValue(eventInfo)
    }

}
