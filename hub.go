package main

import (
	"encoding/json"
	"log"
)

type Hub struct {
	clients    map[*Client]string
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
}

func newHub() *Hub {
	return &Hub{
		broadcast:  make(chan []byte),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]string),
	}
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			_, message, err := client.conn.ReadMessage()
			if err != nil {
				log.Println("讀取消息發生錯誤:", err)
				h.handleRegisterError(client)
				continue
			}
			var msg Message
			err = json.Unmarshal(message, &msg)
			if err != nil {
				log.Println("JSON解析錯誤:", err)
				h.handleRegisterError(client)
				continue
			}
			h.clients[client] = msg.Account
			log.Printf("用戶 %s 成功註冊", msg.Account)

		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.send)
				log.Printf("用戶 %s 已斷開連接", h.clients[client])
			}
		case message := <-h.broadcast:
			for client := range h.clients {
				select {
				case client.send <- message:
				default:
					close(client.send)
					delete(h.clients, client)
				}
			}
		}
	}
}

func (h *Hub) handleRegisterError(client *Client) {
	log.Printf("註冊失敗,關閉連接: %s", client.conn.RemoteAddr())
	client.conn.Close()
	delete(h.clients, client)
	close(client.send)
}
