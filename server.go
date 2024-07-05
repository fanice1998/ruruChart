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
	Type     string `json:"type"`
	Account  string `json:"account"`
	Password string `json:"password"`
}

type Response struct {
	Type    string `json:"type"`
	Message string `json:"message"`
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	for {
		// messageType, p, err := conn.ReadMessage()
		_, p, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("收到消息: %s\n", p)

		var msg Message
		err = json.Unmarshal(p, &msg)
		if err != nil {
			log.Println("JSON解析錯誤:", err)
			continue
		}

		var response Response
		if msg.Type == "login" {
			// 進行帳號密碼驗證
			// if msg.Account == "admin" && msg.Password == "password" {
			// 	response = "login_success"
			// } else {
			// 	response = "login_failed"
			// }
			response = Response{
				Type:    "login_success",
				Message: "login_success",
			}
		} else {
			response = Response{
				Type:    "echo",
				Message: string(p),
			}
		}

		responseJSON, err := json.Marshal(response)
		if err != nil {
			log.Println("JSON轉換錯誤:", err)
			continue
		}

		if err := conn.WriteMessage(websocket.TextMessage, responseJSON); err != nil {
			log.Panicln(err)
			return
		}
	}
}

func main() {
	http.HandleFunc("/ws", handleWebSocket)
	log.Println("WebSocket 服務器正在運行於 :8080 端口...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("ListenAndServe: ", err)
	}
}
