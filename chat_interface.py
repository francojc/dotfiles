import curses

class ChatBot:
    def __init__(self, stdscr):
        self.stdscr = stdscr
        self.win = curses.newwin(curses.LINES, curses.COLS)
        self.models = ["Model 1", "Model 2", "Model 3"]
        self.selected_model_index = 0
        self.chat_history = []

        # Layout configuration
        self.layout = {
            'menu_height': 5,
            'chat_area_height': curses.LINES - 8,
            'input_line_y': curses.LINES - 3
        }

        # Color pairs for different message types
        curses.start_color()
        curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLUE)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_CYAN, curses.COLOR_BLACK)

        self.color_pairs = {
            'user_message': curses.color_pair(2),
            'bot_message': curses.color_pair(3),
            'highlight': curses.color_pair(1)
        }

        # Initialize status messages
        self.status_bar = "Ready"

    def display_menu(self):
        self.win.clear()

        # Draw menu border
        menu_win = self.win.subwin(self.layout['menu_height'], 30, 0, 0)
        menu_win.border(0)

        # Display model selection with better formatting
        for i, model in enumerate(self.models):
            y = i + 1
            prefix = "   "
            if i == self.selected_model_index:
                prefix = "> "
                model_str = f" {model}"
                menu_win.addstr(y, 1, model_str, curses.A_REVERSE)
            else:
                model_str = f" {model}"
                menu_win.addstr(y, 1, model_str)

        # Add section headers with colors
        self.win.addstr(0, 35, "Available Commands:", self.color_pairs['highlight'])

    def display_chat(self):
        self.win.clear()

        # Draw chat area border
        chat_area = self.win.subwin(self.layout['chat_area_height'], curses.COLS,
                                    self.layout['menu_height'], 0)
        chat_area.border(0)

        # Display messages with better formatting
        for i, message in enumerate(self.chat_history):
            y = i + 1
            if i == len(self.chat_history) - 1:
                continue  # Skip last line for status bar

            if message['type'] == 'user':
                style = self.color_pairs['user_message']
            else:
                style = self.color_pairs['bot_message']

            chat_area.addstr(y, 2, f">> {message['content']}", style)

        # Draw input prompt
        input_line = self.win.subwin(1, curses.COLS,
                                     self.layout['input_line_y'], 0)
        input_line.addstr("Enter your message (Ctrl+C to exit): ",
                          self.color_pairs['highlight'])

    def handle_input(self, key):
        # ... existing input handling code ...

        # Update status bar with connection info
        if success:
            self.status_bar = "Connected to AI service"
        else:
            self.status_bar = "Connection failed - check internet"

    def run(self):
        curses.wrapper(self.main_loop)

    def main_loop(self, stdscr):
        self.stdscr = stdscr
        self.win = curses.newwin(curses.LINES, curses.COLS)
        while True:
            self.display_menu()
            self.display_chat()
            key = self.win.getch()
            if key == ord('q'):
                break
            self.handle_input(key)

if __name__ == "__main__":
    ChatBot().run()
