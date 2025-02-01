import curses
from curses import wrapper
import json
import os
import sys
import requests
from typing import List, Dict

class ChatBot:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.models: List[str] = []
        self.selected_model_index: int = 0
        self.chat_history: List[Dict[str, str]] = []
        self.current_message = ""
        self.mode = "menu"  # Add mode tracking: "menu" or "chat"

        # Curses setup
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)    # Headers
        curses.init_pair(2, curses.COLOR_GREEN, -1)                   # User messages
        curses.init_pair(3, curses.COLOR_BLUE, -1)                    # Bot messages
        curses.init_pair(4, curses.COLOR_YELLOW, -1)                  # Highlights
        curses.init_pair(5, curses.COLOR_WHITE, curses.COLOR_RED)     # Errors

        self.win = curses.newwin(curses.LINES, curses.COLS)
        self.win.keypad(1)  # Enable keypad mode

    def get_models(self):
        try:
            response = requests.get('http://localhost:11434/api/tags')
            if response.status_code == 200:
                models_data = response.json()
                self.models = [model['name'] for model in models_data['models']]
            else:
                self.models = ["Error: Couldn't connect to Ollama"]
        except requests.exceptions.RequestException:
            self.models = ["Error: Ollama service not running"]

        if not self.models:
            self.models = ["No models found"]

    def display_menu(self):
        self.win.clear()

        # Header
        header = "🤖 Ollama Chat Interface"
        self.win.addstr(0, (curses.COLS - len(header)) // 2, header, curses.color_pair(1))

        # Model selection area
        self.win.addstr(2, 2, "Available Models:", curses.color_pair(4))
        for i, model in enumerate(self.models):
            if i == self.selected_model_index:
                self.win.addstr(i + 3, 4, f"► {model}", curses.A_REVERSE)
            else:
                self.win.addstr(i + 3, 4, f"  {model}")

        # Commands help
        help_y = 5 + len(self.models)
        self.win.addstr(help_y, 2, "Commands:", curses.color_pair(4))
        self.win.addstr(help_y + 1, 4, "↑/↓ - Select model")
        self.win.addstr(help_y + 2, 4, "Enter - Choose model and start chat")
        self.win.addstr(help_y + 3, 4, "ESC - Exit application")

        self.win.refresh()

    def display_chat(self):
        self.win.clear()

        # Header
        selected_model = self.models[self.selected_model_index]
        header = f"🤖 Chat with {selected_model}"
        self.win.addstr(0, (curses.COLS - len(header)) // 2, header, curses.color_pair(1))

        # Chat history
        start_y = 2
        for i, message in enumerate(self.chat_history):
            sender = message["sender"]
            text = message["text"]
            prefix = "You: " if sender == "user" else "Bot: "
            color = curses.color_pair(2) if sender == "user" else curses.color_pair(3)

            self.win.addstr(start_y + i, 2, prefix, color)
            self.win.addstr(start_y + i, len(prefix) + 2, text)

        # Input area
        input_y = curses.LINES - 3
        self.win.addstr(input_y - 1, 2, "─" * (curses.COLS - 4))  # Separator line
        self.win.addstr(input_y, 2, "Message: " + self.current_message)

        # Commands help
        self.win.addstr(curses.LINES - 1, 2, "ESC - Exit | Enter - Send message",
                       curses.color_pair(4))

        self.win.refresh()

    def handle_input(self):
        c = self.win.getch()

        if self.mode == "menu":
            if c == curses.KEY_UP:
                self.selected_model_index = (self.selected_model_index - 1) % len(self.models)
            elif c == curses.KEY_DOWN:
                self.selected_model_index = (self.selected_model_index + 1) % len(self.models)
            elif c == ord('\n'):
                selected_model = self.models[self.selected_model_index]
                if selected_model != "none":
                    self.mode = "chat"
                    self.chat_history.append({
                        "sender": "bot",
                        "text": f"Connected to {selected_model}. Start chatting!"
                    })
            elif c == 27:  # ESC
                sys.exit(0)

        elif self.mode == "chat":
            if c == 27:  # ESC
                self.mode = "menu"
                return
            elif c == ord('\n'):
                if self.current_message.strip():
                    self.chat_history.append({
                        "sender": "user",
                        "text": self.current_message
                    })
                    self.current_message = ""
            elif c == curses.KEY_BACKSPACE or c == 127:
                self.current_message = self.current_message[:-1]
            else:
                try:
                    self.current_message += chr(c)
                except ValueError:
                    pass

def main(stdscr):
    chatbot = ChatBot(stdscr)
    chatbot.get_models()

    while True:
        if chatbot.mode == "menu":
            chatbot.display_menu()
        else:
            chatbot.display_chat()
        chatbot.handle_input()

if __name__ == "__main__":
    wrapper(main)
