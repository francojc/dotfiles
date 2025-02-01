import curses
from curses import wrapper
import json
import os
import sys
from typing import List, Dict

class ChatBot:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.models: List[str] = []
        self.selected_model_index: int = 0
        self.chat_history: List[Dict[str, str]] = []
        self.current_message = ""

        # Curses setup
        curses.init_color(curses.COLOR_CYAN, 500, 0, 0)
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)
        self.win = curses.newwin(curses.LINES, curses.COLS)

    def get_models(self):
        models_dir = os.path.expanduser("~/.ollama/models")
        if not os.path.exists(models_dir):
            return []

        self.models = [f for f in os.listdir(models_dir) if os.path.isdir(os.path.join(models_dir, f))]
        if not self.models:
            self.models.append("none")  # Fallback

    def display_menu(self):
        # Display model selection menu
        self.win.clear()
        self.win.addstr(0, 0, "Select Model: ", curses.color_pair(1))
        for i, model in enumerate(self.models):
            if i == self.selected_model_index:
                self.win.addstr(i + 1, 0, f"> {model}", curses.A_REVERSE)
            else:
                self.win.addstr(i + 1, 0, f"  {model}")
        self.win.refresh()

    def display_chat(self):
        # Display chat history and current messages
        self.win.clear()
        for i, message in enumerate(self.chat_history):
            sender = message["sender"]
            text = message["text"]
            if sender == "user":
                self.win.addstr(i + 2, 0, f"User: {text}")
            else:
                self.win.addstr(i + 2, 0, f"Bot: {text}")

        self.win.addstr(curses.LINES - 1, 0, "You: " + self.current_message)
        self.win.refresh()

    def handle_input(self):
        # Handle keyboard input
        c = self.stdscr.getch()
        if c == curses.KEY_UP:
            self.selected_model_index = (self.selected_model_index - 1) % len(self.models)
        elif c == curses.KEY_DOWN:
            self.selected_model_index = (self.selected_model_index + 1) % len(self.models)
        elif c == ord('\n'):
            # Select the model and start chatting
            selected_model = self.models[self.selected_model_index]
            if selected_model != "none":
                self.chat_history.append({"sender": "user", "text": f"Selected model: {selected_model}"})
                self.current_message = ""
        elif c == 27:  # ESC key to exit
            sys.exit(0)
        else:
            if c == curses.KEY_BACKSPACE or c == 127:
                self.current_message = self.current_message[:-1]
            else:
                self.current_message += chr(c)

def main(stdscr):
    chatbot = ChatBot(stdscr)
    chatbot.get_models()

    while True:
        chatbot.display_menu()
        chatbot.display_chat()
        chatbot.handle_input()

if __name__ == "__main__":
    wrapper(main)
