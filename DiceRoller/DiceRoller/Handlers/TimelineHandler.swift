//
//  TimelineHandler.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/25/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation

enum ServiceInteraction {
    case checkTimelineExist
    case getHistory

    case addEvent(String, Int) //timelineName, eventIndex
    case addSubEvent(String, Int, Int, String) //timelineName, insertIndex, childIndex, eventInfo

    case removeEvent(Int)
    case removeSubEvent(Int, Int)

    case submitEvent(String, Int, Int, String)
}

enum TimelineEvent {
    case timelineChosen(String)
    case timelineExistence(Bool)

    case createTimeline(String)
    case getHistory

    case addEvent
    case addSubEvent(Int)

    case submitEvent(String, Int)
    case submitSubEvent(String, Int)

    case removeEvent(Int)
    case removeSubEvent(Int, Int)
}

enum TimelineError {
    case gameNotFound
    case emptyTimelineName
    case notEnoughInfoFail
    case notEnoughInfoSoft
    case tooManyCharacters
}

enum TimelineNavigation {
    case history
    case setupGame(String)
    case setupEvent
    case setupSubEvent(Int)
}

struct TimelineState {
    var timelineName: String?
    var error: TimelineError?
    var navigation: TimelineNavigation?
    var isProcessing: Bool = false
    var events: [Event] = []
    var service: ServiceInteraction?

    init() {
        timelineName = nil
        error = nil
        navigation = nil
        isProcessing = false
        events = []
        service = nil
    }
}

struct TimelineHandler: EventHandler {
    
    func handle(event: TimelineEvent, state: TimelineState) -> TimelineState? {
        
        var state = state
        state.error = nil
        state.isProcessing = false
        state.navigation = nil
        state.service = nil
        
        switch event {
        case let .timelineChosen(name):
            if name.isEmpty {
                state.error = .emptyTimelineName
            } else {
                state.timelineName = name
                state.service = .checkTimelineExist
            }
            
        case let .timelineExistence(doesExist):
            if doesExist {
                state.navigation = .history
            } else {
                state.error = .gameNotFound
            }
        
        case let .createTimeline(timelineName):
            state.navigation = .setupGame(timelineName)

        case .getHistory:
            state.service = .getHistory

        case .addEvent:
            state.navigation = .setupEvent

        case let .addSubEvent(eventNumber):
            state.navigation = .setupSubEvent(eventNumber)

        case let .submitEvent(name, number):
            state.service = .addEvent(name, number)

        case let .submitSubEvent(eventInfo, eventNumber):
            let insertEventIndex = eventNumber + 1
            if let timelineName = state.timelineName {
                if insertEventIndex == -99 || timelineName == "" {
                    state.error = .notEnoughInfoFail
                }

                if eventInfo.trimmingCharacters(in: .whitespaces) == "" {
                    state.error = .notEnoughInfoSoft
                }

                if eventInfo.count > 200 {
                    state.error = .tooManyCharacters
                }

                if state.error == nil {
                    let childEventIndex = state.events[eventNumber].subEvents.count
//                    let info = eventInfo.caseInsensitiveCompare("asdf") != .orderedAscending ? "Adding to event:\(eventNumber) and subEvent:\(childEventIndex)" : eventInfo

                    state.service = .addSubEvent(timelineName,
                                                 insertEventIndex,
                                                 childEventIndex,
                                                 eventInfo)
                }
            }

        case let .removeEvent(eventNum):
            state.service = .removeEvent(eventNum)
        
        case let .removeSubEvent(eventNum, subEventNum):
            state.service = .removeSubEvent(eventNum, subEventNum)
        
        }
        return state
    }
    
}
