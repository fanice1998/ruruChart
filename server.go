package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	maxRooms       = 10
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 512
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
	rooms = make(map[string]*Room)
	mu    sync.Mutex
)

type Client struct {
	conn     *websocket.Conn
	send     chan []byte
	room     *Room
	username string
}

type Room struct {
	clients    map[*Client]bool
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
}

type Message struct {
	Type     string `json:"type"`
	Content  string `json:"content"`
	Username string `json:"username"`
	Room     string `json:"room,omitempty"`
}

func newRoom() *Room {
	return &Room{
		broadcast:  make(chan []byte),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
	}
}

func (c *Client) readPump() {
	defer func() {
		c.room.unregister <- c
		c.conn.Close()
	}()
	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error { c.conn.SetReadDeadline(time.Now().Add(pongWait)); return nil })
	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}
		var msg Message
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("error: %v", err)
			continue
		}
		if msg.Type == "chat" && msg.Content == "/exit" {
			c.room.unregister <- c
			c.room = nil
			c.send <- []byte(`{"type":"system","content":"You have left the room. Please choose another room."}`)
		} else if c.room != nil {
			msg.Username = c.username
			jsonMessage, _ := json.Marshal(msg)
			c.room.broadcast <- jsonMessage
		}
	}
}

func (c *Client) writePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()
	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}
		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func handleConnections(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	client := &Client{conn: conn, send: make(chan []byte, 256), username: r.URL.Query().Get("username")}

	go client.writePump()

	mu.Lock()
	roomList := make([]string, 0, len(rooms))
	for roomName := range rooms {
		roomList = append(roomList, roomName)
	}
	mu.Unlock()

	roomListMsg, _ := json.Marshal(Message{Type: "roomList", Content: "", Room: "", Username: ""})
	client.send <- roomListMsg

	client.readPump()
}

func (r *Room) run() {
	for {
		select {
		case client := <-r.register:
			r.clients[client] = true
		case client := <-r.unregister:
			if _, ok := r.clients[client]; ok {
				delete(r.clients, client)
				close(client.send)
			}
		case message := <-r.broadcast:
			for client := range r.clients {
				select {
				case client.send <- message:
				default:
					close(client.send)
					delete(r.clients, client)
				}
			}
		}
	}
}

func main() {
	for i := 1; i <= maxRooms; i++ {
		roomName := fmt.Sprintf("Room %d", i)
		room := newRoom()
		rooms[roomName] = room
		go room.run()
	}

	http.HandleFunc("/ws", handleConnections)

	log.Println("Server starting on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
