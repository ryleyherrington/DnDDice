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
    case addEvent(String, Int)
    case addSubEvent(String, Int, Int)
    case removeEvent(Int)
    case removeSubEvent(Int, Int)
}

enum TimelineEvent {
    case timelineChosen(String)
    case timelineExists
    case timelineNotExists
    case createTimeline
    case getHistory
    case addEvent(String, Int)
    case addSubEvent(String, Int, Int)
    case removeEvent(Int)
    case removeSubEvent(Int, Int)
}

enum TimelineError {
    case gameNotFound
}

enum TimelineNavigation {
    case history
    case setupGame
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
            state.timelineName = name
            state.service = .checkTimelineExist
        
        case .timelineExists:
            state.navigation = .history
        
        case .timelineNotExists:
            state.error = .gameNotFound
        
        case .createTimeline:
            state.navigation = .setupGame
            
        case .getHistory:
            state.service = .getHistory
            
        case let .addEvent(name, number):
            state.service = .addEvent(name, number)
        
        case let .addSubEvent(name, eventNum, subEventNumber):
            state.service = .addSubEvent(name, eventNum, subEventNumber)
        
        case let .removeEvent(eventNum):
            state.service = .removeEvent(eventNum)
        
        case let .removeSubEvent(eventNum, subEventNum):
            state.service = .removeSubEvent(eventNum, subEventNum)
        
        }
        return state
    }
    
}