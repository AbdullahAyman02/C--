import tkinter as tk
import customtkinter as ctk
from tkinter import scrolledtext, font
from tkinter import ttk, filedialog
from tkinterdnd2 import DND_FILES, TkinterDnD
from PIL import Image, ImageTk
import subprocess
import threading
import time
import os

temp_path = "temp/temp_input.txt"


class CompilerGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("يلا نكتب كود")
        self.root.geometry("+10+10")

        # Configure grid layout to expand with window
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_columnconfigure(1, weight=0)

        # Initial background color
        self.root.configure(bg="#2e2e2e")

        # Dark mode settings for the text editor
        self.dark_mode = True
        self.editor_bg_dark = "#2e2e2e"
        self.editor_fg_dark = "#fefefe"
        self.editor_insert_bg_dark = "#fefefe"
        self.editor_select_bg_dark = "#555555"
        self.root_bg_dark = "#2e2e2e"

        # Light mode settings for the text editor
        self.editor_bg_light = "#fefefe"
        self.editor_fg_light = "#000000"
        self.editor_insert_bg_light = "#000000"
        self.editor_select_bg_light = "#cccccc"
        self.root_bg_light = "#fefefe"

        # Define a custom font
        custom_font = font.Font(family="Arial", size=11)

        self.editor = scrolledtext.ScrolledText(root, wrap=tk.WORD, width=70, height=25, undo=True,
                                                bg=self.editor_bg_dark, fg=self.editor_fg_dark, insertbackground=self.editor_insert_bg_dark,
                                                selectbackground=self.editor_select_bg_dark, font=custom_font)
        self.editor.grid(row=0, column=0, padx=0, pady=0, sticky="nsew")

        self.editor.drop_target_register(DND_FILES)
        self.editor.dnd_bind('<<Drop>>', self.drop)

        self.notebook = ttk.Notebook(root)
        self.notebook.grid(row=1, column=0, padx=0, pady=0, sticky="nsew")

        self.terminal_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.terminal_frame, text="Terminal")

        self.output = scrolledtext.ScrolledText(self.terminal_frame, wrap=tk.WORD, width=70, height=10, state='disabled',
                                                bg=self.editor_bg_dark, fg=self.editor_fg_dark, insertbackground=self.editor_insert_bg_dark,
                                                selectbackground=self.editor_select_bg_dark, font=custom_font)
        self.output.pack(fill=tk.BOTH, expand=True)

        self.compile_button = ctk.CTkButton(root, text='Compile', text_color="#FFFFFF", command=self.compile_code, fg_color="#08b6d9",
                                            hover_color="#087bb8", width=100, height=25, font=("Arial", 12, "bold"), bg_color="transparent")
        # tk.Button(root, text="Compile", command=self.compile_code, font=("Arial", 12, "bold"),
        #                                bg="blue", fg="white")
        self.compile_button.grid(
            row=1, column=1, rowspan=1, padx=5, sticky="n")

        # self.compile_button.bind("<Enter>", lambda e: self.on_enter(e, "darkblue"))
        # self.compile_button.bind("<Leave>", lambda e: self.on_leave(e, "blue"))
        # self.compile_button.bind("<ButtonPress>", self.on_press)
        # self.compile_button.bind("<ButtonRelease>", self.on_release)

        original_image = Image.open("Images/dark_mode2.png")
        resized_image = original_image.resize((30, 30), Image.LANCZOS)
        self.theme_icon = ImageTk.PhotoImage(resized_image)

        self.toggle_theme_button = tk.Button(
            root, image=self.theme_icon, command=self.toggle_theme)
        self.toggle_theme_button.grid(
            row=0, column=1, padx=5, pady=5, sticky="ne")
        self.toggle_theme_button.bind(
            "<Enter>", lambda e: self.on_enter(e, "lightgray"))
        self.toggle_theme_button.bind(
            "<Leave>", lambda e: self.on_leave(e, "white"))

        self.open_file_button = ctk.CTkButton(root, text='Open File', text_color="#FFFFFF", command=self.open_file,
                                              fg_color="#50e650", hover_color="#39a639", width=100, height=25, font=("Arial", 12, "bold"), bg_color="transparent")

        self.open_file_button.grid(
            row=2, column=1, padx=5, pady=5, sticky="se")

    def compile_code(self):
        code = self.editor.get("1.0", tk.END)

        # Ensure the temp directory exists
        os.makedirs(os.path.dirname(temp_path), exist_ok=True)

        # Save the code to a temporary file
        with open(temp_path, "w") as file:
            file.write(code)

        # Run the compiler in a separate thread to avoid blocking the GUI
        threading.Thread(target=self.run_compiler).start()

    def run_compiler(self):
        process = subprocess.Popen(
            ["./parser.exe", temp_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        self.output.config(state='normal')
        self.output.delete("1.0", tk.END)

        # Read the output in real-time
        for line in iter(process.stdout.readline, ''):
            self.output.insert(tk.END, line)
            self.output.see(tk.END)
            self.output.update_idletasks()
            time.sleep(0.01)

        for line in iter(process.stderr.readline, ''):
            self.output.insert(tk.END, line)
            self.output.see(tk.END)
            self.output.update_idletasks()
            time.sleep(0.01)

        process.stdout.close()
        process.stderr.close()
        process.wait()

        self.output.config(state='disabled')

    def toggle_theme(self):
        if self.dark_mode:
            # Switch to light mode
            self.editor.config(bg=self.editor_bg_light, fg=self.editor_fg_light, insertbackground=self.editor_insert_bg_light,
                               selectbackground=self.editor_select_bg_light)
            self.output.config(bg=self.editor_bg_light, fg=self.editor_fg_light, insertbackground=self.editor_insert_bg_light,
                               selectbackground=self.editor_select_bg_light)
            self.root.config(bg=self.root_bg_light)
            self.dark_mode = False
        else:
            # Switch to dark mode
            self.editor.config(bg=self.editor_bg_dark, fg=self.editor_fg_dark, insertbackground=self.editor_insert_bg_dark,
                               selectbackground=self.editor_select_bg_dark)
            self.output.config(bg=self.editor_bg_dark, fg=self.editor_fg_dark, insertbackground=self.editor_insert_bg_dark,
                               selectbackground=self.editor_select_bg_dark)
            self.root.config(bg=self.root_bg_dark)
            self.dark_mode = True

    def on_enter(self, event, color):
        event.widget.config(bg=color)

    def on_leave(self, event, color):
        event.widget.config(bg=color)

    def on_press(self, event):
        event.widget.config(bg="red")

    def on_release(self, event):
        event.widget.config(bg="blue")

    def open_file(self):
        file_path = filedialog.askopenfilename(
            filetypes=[("Text files", "*.txt")])
        if file_path:
            with open(file_path, "r") as file:
                content = file.read()
                self.editor.delete("1.0", tk.END)
                self.editor.insert(tk.END, content)

    def drop(self, event):
        file_path = event.data
        if file_path:
            file_path = file_path.strip('{}')
            with open(file_path, "r") as file:
                content = file.read()
                self.editor.delete("1.0", tk.END)
                self.editor.insert(tk.END, content)


if __name__ == "__main__":
    root = TkinterDnD.Tk()
    gui = CompilerGUI(root)
    root.mainloop()
