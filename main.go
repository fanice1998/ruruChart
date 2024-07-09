package main

import (
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/websocket"
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
	// clients     = make(map[*websocket.Conn]string)
	clients     = make(map[*Client]bool)
	broadcast   = make(chan Message, 1000)
	register    = make(chan *Client)
	unregister  = make(chan *Client)
	mu          sync.Mutex
	jwtSecret   = []byte("your-secret-key")
	chatHistory = []Message{}
)

type Client struct {
	conn     *websocket.Conn
	send     chan Message
	username string
}

type Credentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type Message struct {
	Username string `json:"username"`
	Content  string `json:"content"`
	Type     string `json:"type"`
}

func main() {
	http.HandleFunc("/ws", handleConnections)
	go handleMessages()

	// 添加靜態文件服務器
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "client/clientConn.html")
	})

	log.Println("Server is running on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func handleConnections(w http.ResponseWriter, r *http.Request) {
	log.Printf("Remote IP: %s", r.RemoteAddr)
	ws, err := upgrader.Upgrade(w, r, nil)
	log.Printf("%s upgrade to websocket\n", r.RemoteAddr)
	if err != nil {
		log.Println("Error upgrading to WebSocket:", err)
		return
	}

	var creds Credentials
	err = ws.ReadJSON(&creds)
	if err != nil {
		log.Println("Error reading credentials:", err)
		return
	}

	if !authenticateUser(creds.Username, creds.Password) {
		log.Println("Authentication failed for user:", creds.Username)
		ws.WriteMessage(websocket.TextMessage, []byte("Authentication failed"))
		ws.Close()
		return
	}

	token, err := generateJWT(creds.Username)
	if err != nil {
		log.Println("Error generating JWT:", err)
		ws.Close()
		return
	}
	ws.WriteMessage(websocket.TextMessage, []byte(token))

	// mu.Lock()
	// clients[ws] = creds.Username
	// mu.Unlock()

	// broadcast <- Message{Username: creds.Username, Content: "has joined the chat", Type: "join"}

	// for _, msg := range chatHistory {
	// 	ws.WriteJSON(msg)
	// }

	// for {
	// 	var msg Message
	// 	err := ws.ReadJSON(&msg)
	// 	if err != nil {
	// 		log.Printf("error: %v", err)
	// 		mu.Lock()
	// 		delete(clients, ws)
	// 		mu.Unlock()
	// 		broadcast <- Message{Username: creds.Username, Content: "has left the chat", Type: "leave"}
	// 		break
	// 	}

	// 	if len(msg.Content) > 512 {
	// 		msg.Content = msg.Content[:512]
	// 	}

	// 	msg.Username = creds.Username
	// 	msg.Type = "message"
	// 	broadcast <- msg
	// }

	client := &Client{conn: ws, send: make(chan Message, 256), username: creds.Username}
	register <- client

	go client.writePump()
	go client.readPump()
}

func (c *Client) readPump() {
	defer func() {
		unregister <- c
		log.Printf("client %s left server....\n", c.username)
		c.conn.Close()
	}()

	for {
		var msg Message
		err := c.conn.ReadJSON(&msg)
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("Error reading message: %v", err)
			}
			break
		}

		if len(msg.Content) > 512 {
			msg.Content = msg.Content[:512]
		}

		msg.Username = c.username
		msg.Type = "message"
		log.Printf("Received message from %s: %s", c.username, msg.Content)
		// broadcast <- msg
		select {
		case broadcast <- msg:
			log.Printf("Message from %s sent to broadcast channel", c.username)
		default:
			log.Printf("Failed to send message from %s to broadcast channel", c.username)
		}
	}
}

func (c *Client) writePump() {
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

			log.Printf("Sending message to %s: %v", c.username, message)
			err := c.conn.WriteJSON(message)
			if err != nil {
				log.Printf("Error sending message to %s: %v", c.username, err)
				return
			}
		}
	}
}

func handleMessages() {
	for {
		// msg := <-broadcast
		// chatHistory = append(chatHistory, msg)
		// mu.Lock()
		// for client := range clients {
		// 	log.Println("msg: ", msg)
		// 	err := client.WriteJSON(msg)
		// 	if err != nil {
		// 		log.Printf("error: %v", err)
		// 		client.Close()
		// 		delete(clients, client)
		// 	}
		// }
		// mu.Unlock()
		select {
		case client := <-register:
			mu.Lock()
			clients[client] = true
			mu.Unlock()
			log.Printf("New client registered: %s", client.username)

			for _, msg := range chatHistory {
				select {
				case client.send <- msg:
				default:
					close(client.send)
					delete(clients, client)
				}
			}
			broadcast <- Message{Username: client.username, Content: "has joined the chat", Type: "join"}

		case client := <-unregister:
			mu.Lock()
			if _, ok := clients[client]; ok {
				delete(clients, client)
				close(client.send)
			}
			mu.Unlock()

			log.Printf("Client unregistered: %s", client.username)
			broadcast <- Message{Username: client.username, Content: "has left the chat", Type: "leave"}

		case message := <-broadcast:
			log.Printf("Broadcasting message: %+v", message)
			chatHistory = append(chatHistory, message)

			mu.Lock()
			for client := range clients {
				select {
				case client.send <- message:
				default:
					close(client.send)
					delete(clients, client)
				}
			}
			mu.Unlock()

		}
	}
}

func authenticateUser(username, password string) bool {
	// 在實際應用中,這裡應該檢查數據庫或其他認證系統
	log.Printf("Authenticating user: %s", username)
	return true
}

func generateJWT(username string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", err
	}

	log.Printf("Generated JWT for user: %s", username)
	return tokenString, nil
}
