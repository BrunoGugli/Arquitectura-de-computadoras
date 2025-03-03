import tkinter as tk
from tkinter import ttk
from abc import ABC

class Interface(ABC):
    def __init__(self, title: str):
        self.root = tk.Tk()
        self.root.title(title)
        self.frame = ttk.Frame(self.root, padding="10", width=1290, height=720)
        self.frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        self.root.resizable(True, True)
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)

    def on_closing(self):
        self.root.destroy()

    def set_up(self):
        

    def run(self):
        self.root.mainloop()