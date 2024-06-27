package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // 允许所有来源，仅用于开发环境
	},
}

type Client struct {
	conn     *websocket.Conn
	username string
	send     chan []byte
}

type Message struct {
	Type     string `json:"type"`
	Username string `json:"username,omitempty"`
	Content  string `json:"content,omitempty"`
}

type ChatRoom struct {
	clients    map[*Client]bool
	broadcast  chan Message
	register   chan *Client
	unregister chan *Client
	logFile    *os.File
}

func newChatRoom() *ChatRoom {
	return &ChatRoom{
		broadcast:  make(chan Message),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
	}
}

func (cr *ChatRoom) run() {
	defer cr.logFile.Close()

	for {
		select {
		case client := <-cr.register:
			cr.clients[client] = true
		case client := <-cr.unregister:
			if _, ok := cr.clients[client]; ok {
				delete(cr.clients, client)
				close(client.send)
			}
		case message := <-cr.broadcast:
			// 将消息写入日志文件
			cr.logMessage(message)

			for client := range cr.clients {
				select {
				case client.send <- encodeMessage(message):
				default:
					close(client.send)
					delete(cr.clients, client)
				}
			}
		}
	}
}

func (cr *ChatRoom) logMessage(msg Message) {
	encoded, err := json.Marshal(msg)
	if err != nil {
		log.Println("Error encoding message:", err)
		return
	}

	_, err = cr.logFile.Write(encoded)
	if err != nil {
		log.Println("Error writing to log file:", err)
		return
	}
	_, err = cr.logFile.WriteString("\n")
	if err != nil {
		log.Panicln("Error writing newline to log file:", err)
	}
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	chatRoom := globalChatRoom // 使用全局聊天室

	// 等待客户端发送用户名
	var msg Message
	err = conn.ReadJSON(&msg)
	if err != nil {
		log.Println(err)
		return
	}

	if msg.Type != "join" {
		conn.Close()
		return
	}

	client := &Client{conn: conn, username: msg.Username, send: make(chan []byte, 256)}
	chatRoom.register <- client

	go client.writePump(chatRoom)
	client.readPump(chatRoom)
}

func (c *Client) readPump(cr *ChatRoom) {
	defer func() {
		cr.unregister <- c
		c.conn.Close()
	}()

	for {
		var msg Message
		err := c.conn.ReadJSON(&msg)
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}
		msg.Username = c.username
		cr.broadcast <- msg
	}
}

func (c *Client) writePump(cr *ChatRoom) {
	defer func() {
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			if err := w.Close(); err != nil {
				return
			}
		}
	}
}

func encodeMessage(msg Message) []byte {
	encoded, err := json.Marshal(msg)
	if err != nil {
		log.Println("Error encoding message:", err)
		return []byte{}
	}
	return encoded
}

var globalChatRoom *ChatRoom

func main() {
	globalChatRoom = newChatRoom()
	go globalChatRoom.run()

	http.HandleFunc("/ws", handleWebSocket)

	// 添加静态文件服务
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "client/clientConn.html")
	})

	log.Println("Server is starting on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
