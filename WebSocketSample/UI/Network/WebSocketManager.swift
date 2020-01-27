//
//  WebSocketManager.swift
//  WebSocketSample
//
//  Created by Vladyslav Vcherashnii on 27.01.2020.
//  Copyright © 2020 Vladyslav Vcherashnii. All rights reserved.
//

import UIKit

@objc
protocol SocketObservable: ObservableProtocol {
    @objc
    func didConnect()
    
    @objc
    func didDisconnect()
    
    @objc
    func handleError(_ error: String)

    @objc
    optional func logSignal(_ signal: String?)
}

final class WebSocketManager: NSObject, Observable {
    
    private enum NetworkEnvironment {
        case debug
        case master
    }
    
    // MARK: - Singletone
    static var shared = WebSocketManager()

    // MARK: - Properties
    var observers: [SocketObservable] = []
    
    private let environment: NetworkEnvironment = .master
    private var session: URLSession!
    private var webSocketTask: URLSessionWebSocketTask!
    private var isConnected: Bool = false
    
    private var baseURL: String {
        switch self.environment {
        case .debug: return "ws://0.0.0.0:8080/echo"
        case .master: return "wss://echo.websocket.org"
        }
    }
    
    // MARK: - Behavior
    func connect() {
        guard !self.isConnected else { return }
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        self.webSocketTask = self.session.webSocketTask(with: URL(string: self.baseURL)!)
        self.webSocketTask.resume()
    }
    
    func disconnect() {
        guard self.isConnected else { return }
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
    }
    
    func sendSignal(message: String) {
        self.webSocketTask.send(.string(message)) { [weak self] error in
            guard let error = error else { return }
            self?.handleError(error.localizedDescription)
        }
    }

    // MARK: - Private configuration
    private func connected() {
        self.notifyObservers { observers in
            observers.didConnect()
        }
        self.subscribe()
    }
    
    private func subscribe() {
        self.webSocketTask.receive { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleError("Failed to receive message: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.logSignal("Received text message: \(text)")
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
            
            self?.subscribe()
        }
    }
    
    private func disconnected() {
        self.notifyObservers { observers in
            observers.didDisconnect()
        }
    }
    
    private func handleError(_ errorMessage: String) {
        self.notifyObservers { observers in
            observers.handleError(errorMessage)
        }
    }
    
    private func logSignal(_ message: String?) {
        self.notifyObservers { observers in
            observers.logSignal?(message)
        }
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.isConnected = true
        self.connected()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.isConnected = false
        self.disconnected()
    }
}
