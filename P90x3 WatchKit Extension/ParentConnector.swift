//
//  ParentConnector.swift
//  P90x3 WatchKit Extension
//
//  Created by Naman Kedia on 7/17/17.
//
//  Abstract:
//  Utilites class to encapsulate messaging with parent application on iPhone.

import WatchConnectivity

class ParentConnector: NSObject, WCSessionDelegate {
    
    // MARK: Properties
    
    var wcSession: WCSession?
    
    var statesToSend = [String]()
    
    // MARK: Utility methods
    
    func send(state: String) {
        if let session = wcSession {
            if session.isReachable {
                session.sendMessage(["State": state], replyHandler: nil)
            }
        } else {
            WCSession.default.delegate = self
            WCSession.default.activate()
            statesToSend.append(state)
        }
    }
    
    // MARK : WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        if activationState == .activated {
            wcSession = session
            sendPending()
        }
    }
    
    private func sendPending() {
        if let session = wcSession, session.isReachable {
            for state in statesToSend {
                session.sendMessage(["State": state], replyHandler: nil)
            }
            statesToSend.removeAll()
        }
    }
}

