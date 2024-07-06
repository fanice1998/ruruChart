package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Message struct {
	Type     string      `json:"type"`
	Account  string      `json:"account"`
	Password string      `json:"password"`
	Message  UserMessage `json:"Message"`
}

type Response struct {
	Type    string      `json:"type"`
	Message UserMessage `json:"userMessage"`
}

type UserMessage struct {
	Account string `json:"account"`
	Message string `json:"message"`
}

func handleWebSocket(hub *Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	client := &Client{hub: hub, conn: conn, send: make(chan []byte, 256)}

	func() {
		log.Printf("client IP %s connected", client.conn.RemoteAddr())
		_, register, err := client.conn.ReadMessage()
		if err != nil {
			log.Println("註冊發生錯誤:", err)
			return
		}
		log.Printf("註冊訊息: %s\n", register)

		var msg Message
		err = json.Unmarshal(register, &msg)
		if err != nil {
			log.Println("JSON解析錯誤:", err)
			return
		}

		var response Response
		if msg.Type != "login" {
			response = Response{
				Type: "login_success",
				Message: UserMessage{
					Account: msg.Account,
					Message: "註冊成功",
				},
			}

			responseJSON, err := json.Marshal(response)
			if err != nil {
				log.Panicln("註冊資訊轉換錯誤:", err)
				return
			}

			if err := client.conn.WriteMessage(websocket.TextMessage, responseJSON); err != nil {
				log.Panicln(err)
				return
			}
		}
		client.hub.register <- client
	}()

	go client.writePump()
	go client.readPump()

	// for {
	// 	// messageType, p, err := conn.ReadMessage()
	// 	_, p, err := conn.ReadMessage()
	// 	if err != nil {
	// 		log.Println(err)
	// 		return
	// 	}
	// 	log.Printf("收到消息: %s\n", p)

	// 	var msg Message
	// 	err = json.Unmarshal(p, &msg)
	// 	if err != nil {
	// 		log.Println("JSON解析錯誤:", err)
	// 		continue
	// 	}

	// 	var response Response
	// 	if msg.Type == "login" {
	// 		// 進行帳號密碼驗證
	// 		// if msg.Account == "admin" && msg.Password == "password" {
	// 		// 	response = "login_success"
	// 		// } else {
	// 		// 	response = "login_failed"
	// 		// }
	// 		response = Response{
	// 			Type:    "login_success",
	// 			Message: UserMessage{Account: msg.Account, Message: "login_success"},
	// 		}
	// 	} else {
	// 		response = Response{
	// 			Type:    "message",
	// 			Message: UserMessage{Account: msg.Message.Account, Message: msg.Message.Message},
	// 		}
	// 	}

	// 	responseJSON, err := json.Marshal(response)
	// 	if err != nil {
	// 		log.Println("JSON轉換錯誤:", err)
	// 		continue
	// 	}

	// 	if err := conn.WriteMessage(websocket.TextMessage, responseJSON); err != nil {
	// 		log.Panicln(err)
	// 		return
	// 	}
	// }
}

func main() {

	hub := newHub()
	go hub.run()

	// 添加聊天服務器
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		handleWebSocket(hub, w, r)
	})

	// 添加靜態文件服務器
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "client/clientConn.html")
	})

	log.Println("WebSocket 服務器正在運行於 :8080 端口...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("ListenAndServe: ", err)
	}
}
