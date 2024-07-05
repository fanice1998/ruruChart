package main

import (
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

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	for {
		messageType, p, err := conn.ReadMessage()
		if err != nil {
			log.Println(err)
			return
		}
		log.Printf("收到消息: %s\n", p)

		if err := conn.WriteMessage(messageType, p); err != nil {
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
