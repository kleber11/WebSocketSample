//
//  ViewController.swift
//  WebSocketSample
//
//  Created by Vladyslav Vcherashnii on 27.01.2020.
//  Copyright © 2020 Vladyslav Vcherashnii. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak private var messageTextField: UITextField!
    @IBOutlet weak private var receivedMessageLabel: UILabel!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }

    // MARK: - Setting up WebSocket manager
    private func setup() {
        WebSocketManager.shared.add(observer: self)
        WebSocketManager.shared.connect()
    }
}

// MARK: - @IBActions
extension ViewController {
    @IBAction private func sendMessage(_ sender: Any?) {
        guard let text = messageTextField.text else { return }
        WebSocketManager.shared.sendSignal(message: text)
    }
}

extension ViewController: SocketObservable {
    func didConnect() {
        DispatchQueue.main.async { [weak self] in
            self?.receivedMessageLabel.text = "WebSocket status: Connected"
            self?.receivedMessageLabel.textColor = .green
        }
        debugPrint("Session connected on [\(String(describing: self).uppercased())]")
    }
    
    func didDisconnect() {
        DispatchQueue.main.async { [weak self] in
            self?.receivedMessageLabel.text = "WebSocket status: Disconnected"
            self?.receivedMessageLabel.textColor = .red
        }
        debugPrint("Session disconnected on [\(String(describing: self).uppercased())]")
    }
    
    func handleError(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.receivedMessageLabel.text = "Handled error: \(error)"
            self?.receivedMessageLabel.textColor = .red
        }
        debugPrint("Handled error: \(error)")
    }
    
    func logSignal(_ signal: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.receivedMessageLabel.text = signal
            self?.receivedMessageLabel.textColor = .black
            self?.messageTextField.text = ""
        }
    }
}

