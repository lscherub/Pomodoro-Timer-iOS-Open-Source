//
//  TimerManager.swift
//  Timer
//
//  Created by Gilda on 01/01/23.
//

import Foundation
import UserNotifications

enum TimerState {
    case notStarted
    case focusing
    case pausing
}

enum TimingPlan : String {
    case short = "25:05"
    case medium = "35:05"
    case long = "45:05"
    
    var timerLenght : Double {
        
        switch self {
        case .short:
            return 25
        case .medium:
            return 35
        case .long:
            return 45
        }
    }
}

class TimerManager : ObservableObject {
    
    @Published private(set) var timerState : TimerState = .notStarted {
        // when the state changes, set the end time dinamically
        didSet {
            if timerState == .focusing {
                startTime = Date()
                endTime = startTime.addingTimeInterval(focusingTime)
            } else if timerState == .pausing {
                startTime = Date()
                endTime = startTime.addingTimeInterval(pausingTime)
            }
        }
    }
    @Published private(set) var timingPlan : TimingPlan = .short
    @Published private(set) var startTime : Date {
        didSet {
            // just for convenience:
            print("Start time: ", startTime.formatted(
                .dateTime.month().day().hour().minute().second()
            ))
        }
    }
    @Published private(set) var endTime : Date {
        didSet {
            // just for convenience:
            print("End time: ", endTime.formatted(
                .dateTime.month().day().hour().minute().second()
            ))
        }
    }
    // to track the remaining timer:
    @Published private(set) var elapsed : Bool = false
    // to set and reset the progress accordingly:
    @Published private(set) var elapsedTime : Double = 0.0
    @Published private(set) var progress : Double = 0.0
    // return a value from the switch case in the enum:
    var focusingTime : Double { return timingPlan.timerLenght*60 }
    // we set the pausing time at a fixed value
    var pausingTime : Double = 300
    
    init() {
        // required while using a class
        startTime = Date()
        endTime = Date()
    }
    
    // switch from focus mode to pause and back
    func toggleTimerState() {
        timerState = timerState == .focusing ? .pausing : .focusing
        elapsedTime = 0.0
        progress = 0.0
        
        if timerState == .focusing {
            scheduleNotification(for: .focus)
        } else {
            scheduleNotification(for: .breakStart)
        }
    }
    
    func scheduleNotification(for sessionType: SessionType) {
        let content = UNMutableNotificationContent()
            
        switch sessionType {
        case .focus:
            content.title = "Time's Up!"
            content.body = "Your focus session has ended. Take a break!"
        case .breakStart:
            content.title = "Break Time!"
            content.body = "Time to take a break!"
        case .breakEnd:
            content.title = "Break Over!"
            content.body = "Your break is over, time to focus again!"
        }
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: sessionType == .focus ? focusingTime : pausingTime, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }
        
    enum SessionType {
        case focus
        case breakStart
        case breakEnd
    }
    
        // Add method to handle break end notification
    func breakEnded() {
        scheduleNotification(for: .breakEnd)
    }
    
    
    // to get notified when the remaining timer is elapsed
    func track() {
        guard timerState != .notStarted else {return}
        if endTime >= Date() {
            print("Not elapsed")
            elapsed = false
        } else {
            print("Elapsed")
            elapsed = true
            
            if timerState == .pausing && elapsedTime >= pausingTime {
                        // Notify the user that the break has ended
                        breakEnded()
                }
        }
        
        
        elapsedTime += 1
        print("Elapsed time: ", elapsedTime)
        
        // progress calculation:
        let totalTime = timerState == .focusing ? focusingTime : pausingTime
        progress = (elapsedTime / totalTime * 100).rounded()/100
        print("Progress: ", progress)
    }
    
    // reset the state at not-started
    func reset() {
        timerState = .notStarted
        elapsedTime = 0.0
        progress = 0.0
        startTime = Date()
        endTime = Date()
        
    }
    
    // change timing plan case
    func switchTiming() {
        
        if timingPlan == .short {
            timingPlan = .medium
        } else if timingPlan == .medium {
            timingPlan = .long
        } else if timingPlan == .long {
            timingPlan = .short
        }
        
        reset()
    }
}
