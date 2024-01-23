//
//  ViewController.swift
//  WebSockets
//
//  Created by Saurabh Bisht on 21/01/24.
//


import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    var socket: URLSessionWebSocketTask?
    @IBOutlet weak var sendText: UITextField!
    @IBOutlet weak var recieveText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func connectToServer(_ sender: UIButton) {
        let session  = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        socket = session.webSocketTask(with: URL(string: "ws://localhost:8080")!)
        socket?.resume()
    }
    
    // MARK: Write Text Action
    @IBAction func sendText(_ sender: Any) {
        socket?.send(.string(sendText.text ?? ""), completionHandler: { err in
            if let err {
                print(err)
            }
            Task {
                self.sendText.text = ""
            }
            self.recieveMessage()
        })
       
    }
    
    func recieveMessage() {
        socket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print(data)
                case .string(let string):
                    Task {
                        self?.recieveText.text?.append("\n")
                        self?.recieveText.text?.append(self?.recieveText.text ?? "")
                        self?.recieveText.text = string
                    }
                default:
                    print("")
                }
            case .failure(let err):
                print(err)
            }
            self?.recieveMessage()
        })
    }
    
    @IBAction func disconnect(_ sender: Any) {
        let reason = "Network Error"
        socket?.cancel(with: .internalServerError, reason: reason.data(using: .utf8))
        sendText.text = ""
        recieveText.text = ""
        print("Session Disconnected!!")
    }
    
    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected")
        recieveMessage()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnected")
    }

}

// THIRD PARTY IMPLEMENTATION

//import UIKit
//import Starscream


//
//class ViewController: UIViewController, WebSocketDelegate {
//    var socket: WebSocket!
//    let server = WebSocketServer()
//    @IBOutlet weak var sendText: UITextField!
//    @IBOutlet weak var recieveText: UILabel!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        var request = URLRequest(url: URL(string: "ws://localhost:8080")!)
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        
//    }
//    
//    // MARK: - WebSocketDelegate
//    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
//        switch event {
//        case .connected(let headers):
//            print("Connected: \(headers)")
//        case .text(let string):
//            recieveText.text?.append("\n")
//            recieveText.text?.append(recieveText.text ?? "")
//            recieveText.text = string
//        default:
//            print(event)
//        }
//    }
//
//    @IBAction func connectToServer(_ sender: UIButton) {
//        socket.connect()
//    }
//    
//    // MARK: Write Text Action
//    @IBAction func sendText(_ sender: Any) {
//        socket.write(string: sendText.text ?? "")
//        sendText.text = ""
//    }
//    
//    @IBAction func disconnect(_ sender: Any) {
//        socket.disconnect()
//        sendText.text = ""
//        recieveText.text = ""
//        print("Session Disconnected!!")
//    }
//}
//
