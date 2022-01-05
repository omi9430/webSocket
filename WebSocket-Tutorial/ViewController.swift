//
//  ViewController.swift
//  WebSocket-Tutorial
//
//  Created by omair khan on 05/01/2022.
//

import UIKit

class ViewController: UIViewController,URLSessionWebSocketDelegate {
    
   
    
    // Button
    let button : UIButton = {
        var btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Disconnect", for: .normal)
        return btn
    }()
    
    private var webSocket : URLSessionWebSocketTask?
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         - Create button frame
         - Add button to SubView
         - Set background color
         - Add Button Target
         - Create Session
         - Create WebSocket from the session
         */
        
        button.frame = CGRect(x: self.view.frame.width/2 - 100, y: self.view.frame.width/2, width: 200, height: 100)
        self.view.addSubview(button)
        self.view.backgroundColor = .blue
        button.addTarget(self, action: #selector(closeSession), for: .touchUpInside)
        
        
        //Session
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        //Server API
        let url = URL(string:  "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
    
        //Socket
        webSocket = session.webSocketTask(with: url!)
        
        //Connect and hanles handshake
        webSocket?.resume()
        
        
    }
    
    //MARK: Receive
    func receive(){
        /// This Recurring will keep us connected to the server
        /*
         - Create a workItem
         - Add it to the Queue
         */
        
        let workItem = DispatchWorkItem{ [weak self] in
            
            self?.webSocket?.receive(completionHandler: { result in
                
                
                switch result {
                case .success(let message):
                    
                    switch message {
                    
                    case .data(let data):
                        print("Data received \(data)")
                        
                    case .string(let strMessgae):
                    print("String received \(strMessgae)")
                        
                    default:
                        break
                    }
                
                case .failure(let error):
                    print("Error Receiving \(error)")
                }
                // Creates the Recurrsion
                self?.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    
    }
    
    //MARK: Send
    func send(){
        /*
         - Create a workItem
         - Add it to the Queue
         */
        
        let workItem = DispatchWorkItem{
            
            self.webSocket?.send(URLSessionWebSocketTask.Message.string("Hello"), completionHandler: { error in
                
                
                if error == nil {
                    // if error is nil we will continue to send messages else we will stop
                    self.send()
                }else{
                    print(error)
                }
            })
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem)
    }
    
    //MARK: Close Session
    @objc func closeSession(){
        webSocket?.cancel(with: .goingAway, reason: "You've Closed The Connection".data(using: .utf8))
        
    }
    
    
    //MARK: URLSESSION Protocols
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to server")
        self.receive()
        self.send()
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnect from Server \(reason)")
    }

}

