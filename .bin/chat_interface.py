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
        self.input_buffer_lines = 3  # Space for multiple lines of input
        self.is_processing = False   # Flag for showing processing status
        self.spinner_frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
        self.spinner_index = 0

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

        # Calculate available height for chat history
        input_start_y = curses.LINES - (self.input_buffer_lines + 2)  # +2 for borders/help
        chat_height = input_start_y - 2  # -2 for header

        # Chat history
        start_y = 2
        current_y = start_y

        # Add boundary checking
        def safe_addstr(y, x, text, *args):
            if y >= input_start_y:
                return
            try:
                if x + len(text) > curses.COLS:
                    text = text[:curses.COLS - x - 1]
                self.win.addstr(y, x, text, *args)
            except curses.error:
                pass

        for message in self.chat_history:
            if current_y >= input_start_y - 1:
                break

            sender = message["sender"]
            text = message["text"]
            prefix = "You: " if sender == "user" else "Bot: "
            color = curses.color_pair(2) if sender == "user" else curses.color_pair(3)

            # Word wrap the message
            wrapped_text = text.split('\n')
            for line in wrapped_text:
                while len(line) > curses.COLS - 10 and current_y < input_start_y - 1:
                    split_point = curses.COLS - 10
                    safe_addstr(current_y, 2, prefix if line == wrapped_text[0] else "     ")
                    safe_addstr(current_y, 7, line[:split_point], color)
                    line = line[split_point:]
                    current_y += 1
                if current_y < input_start_y - 1:
                    safe_addstr(current_y, 2, prefix if line == wrapped_text[0] else "     ")
                    safe_addstr(current_y, 7, line, color)
                    current_y += 1

            if self.is_processing and message == self.chat_history[-1] and current_y < input_start_y - 1:
                spinner = self.spinner_frames[self.spinner_index]
                safe_addstr(current_y, 2, f"Bot: {spinner} thinking...", curses.color_pair(3))

        # Input area separator
        safe_addstr(input_start_y - 1, 2, "─" * (curses.COLS - 4))

        # Multi-line input area
        input_y = input_start_y
        safe_addstr(input_y, 2, "Message: ")
        wrapped_input = self.current_message
        max_width = curses.COLS - 11  # -11 for "Message: " and margin

        while len(wrapped_input) > max_width and input_y < curses.LINES - 1:
            safe_addstr(input_y, 11, wrapped_input[:max_width])
            wrapped_input = wrapped_input[max_width:]
            input_y += 1
        if input_y < curses.LINES - 1:
            safe_addstr(input_y, 11, wrapped_input)

        # Commands help
        safe_addstr(curses.LINES - 1, 2, "ESC - Exit | Enter - Send message", curses.color_pair(4))

        self.win.refresh()

    def send_message(self, message: str) -> str:
        """Send a message to Ollama and return the response."""
        try:
            url = 'http://localhost:11434/api/chat'
            data = {
                "model": self.models[self.selected_model_index],
                "messages": [{"role": "user", "content": message}]
            }
            response = requests.post(url, json=data, stream=True)
            if response.status_code == 200:
                # Handle streaming response
                full_response = ""
                for line in response.iter_lines():
                    if line:
                        json_response = json.loads(line)
                        if 'message' in json_response:
                            content = json_response['message'].get('content', '')
                            if content:
                                full_response += content
                return full_response
            else:
                return f"Error: Failed to get response (Status {response.status_code})"
        except requests.exceptions.RequestException as e:
            return f"Error: Could not connect to Ollama service: {str(e)}"
        except json.JSONDecodeError as e:
            return f"Error: Invalid response from Ollama: {str(e)}"

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
                    # Add user message to chat history immediately
                    self.chat_history.append({
                        "sender": "user",
                        "text": self.current_message
                    })
                    user_message = self.current_message
                    self.current_message = ""

                    # Show processing status
                    self.is_processing = True

                    # Start processing response
                    def update_spinner():
                        while self.is_processing:
                            self.spinner_index = (self.spinner_index + 1) % len(self.spinner_frames)
                            self.display_chat()
                            curses.napms(100)  # 100ms delay between spinner frames

                    # Get bot response
                    try:
                        response = self.send_message(user_message)
                        self.chat_history.append({
                            "sender": "bot",
                            "text": response
                        })
                    finally:
                        self.is_processing = False
                        self.display_chat()
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
