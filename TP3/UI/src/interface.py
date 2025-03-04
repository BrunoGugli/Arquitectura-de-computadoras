import tkinter as tk
from tkinter import ttk, filedialog
from typing import Final
import os
import json
from src.comunicator import Comunicator


class Interface:

    CONFIG_FILE = "config.json"

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("MIPS Simulator")
        self.if_id_data: Final[list[str]] = ["instruction", "PC"]
        self.id_ex_data: Final[list[str]] = ["RA", "RB", "rs", "rt", "rd", "funct", "inmediato", "opcode", "shamt", "mem_to_reg", "mem_read", "mem_write", "reg_write", "unsigned", "data_width", "reg_dest", "alu_op", "alu_src"]
        self.ex_mem_data: Final[list[str]] = ["ALU_result", "data_to_write", "reg_dest", "mem_read", "mem_write", "unsigned", "data_width", "mem_to_reg", "reg_write"]
        self.mem_wb_data: Final[list[str]] = ["ALU_result", "data_from_mem", "reg_dest", "mem_to_reg", "reg_write"]
        self.load_config()
        self.create_widgets()

    def load_config(self):
        if os.path.exists(self.CONFIG_FILE):
            with open(self.CONFIG_FILE, "r") as file:
                config:dict = json.load(file)
                self.port = config.get("port", "")
                self.baudrate = config.get("baudrate", "")
        else:
            self.port = ""
            self.baudrate = ""

    def save_config(self):
        config = {
            "port": self.port,
            "baudrate": self.baudrate
        }
        with open(self.CONFIG_FILE, "w") as file:
            json.dump(config, file)

    def create_widgets(self):
        # Labels
        tk.Label(self.root, text="Port:", padx=10).grid(row=0, column=0, sticky="w")
        tk.Label(self.root, text="Baud Rate:", padx=10).grid(row=2, column=0, sticky="w")
        tk.Label(self.root, text="File for Instructions:", padx=10).grid(row=4, column=0, sticky="w")
        tk.Label(self.root, text="Execution Mode:", padx=10).grid(row=6, column=0, sticky="w")
        
        # Entry fields
        self.port_entry = tk.Entry(self.root)
        self.baud_entry = tk.Entry(self.root)
        self.file_entry = tk.Entry(self.root)
        
        self.port_entry.grid(row=1, column=0, padx=10)
        self.baud_entry.grid(row=3, column=0, padx=10)
        self.file_entry.grid(row=5, column=0, padx=10)

        # Set default values from config
        self.port_entry.insert(0, self.port)
        self.baud_entry.insert(0, self.baudrate)
        
        # Dropdown menu
        self.execution_mode = tk.StringVar()
        self.execution_dropdown = ttk.Combobox(self.root, textvariable=self.execution_mode, values=["Continuous", "Step"], width=18)
        self.execution_dropdown.grid(row=7, column=0)
        
        # Buttons
        self.set_button = tk.Button(self.root, text="Set", command=self.set_baudrate_and_port)
        self.load_file_btn = tk.Button(self.root, text="Load File", command=self.load_file)
        self.compile_btn = tk.Button(self.root, text="Compile Program", command=self.compile_program)
        self.load_program_btn = tk.Button(self.root, text="Load Program", command=self.load_program)
        self.execute_btn = tk.Button(self.root, text="Execute", command=self.execute_program)
        self.next_step_btn = tk.Button(self.root, text="Next Step", command=self.next_step)
        self.cancel_debug_btn = tk.Button(self.root, text="Cancel Debug", command=self.cancel_debug)
        
        # Button grid placement
        self.set_button.grid        (row=2, column=1, padx=5, pady=5)
        self.load_file_btn.grid     (row=5, column=1, padx=5, pady=2)
        self.compile_btn.grid       (row=5, column=2, padx=5, pady=2)
        self.load_program_btn.grid  (row=5, column=3, padx=5, pady=2)
        self.execute_btn.grid       (row=7, column=1, ipadx=5, pady=2)
        self.next_step_btn.grid     (row=7, column=2, ipadx=25, pady=2)
        self.cancel_debug_btn.grid  (row=7, column=3, padx=5, pady=2)

        # Memory Data Display
        self.memory_frame = tk.LabelFrame(self.root, text="Memory Data")
        self.memory_frame.grid(row=0, column=4, columnspan=3, rowspan=16, ipadx=10, ipady=5, padx=15, pady=5)
        self.memory_text = tk.Text(self.memory_frame, width=25)
        self.memory_text.pack()
        
        # Table for Registers
        self.registers_frame = tk.LabelFrame(self.root, text="Registers")
        self.registers_frame.grid(row=0, column=7, columnspan=3, rowspan=16, ipadx=10, ipady=5, padx=15, pady=15)
        self.registers_table = ttk.Treeview(self.registers_frame, columns=("Register", "Value"), show="headings", height=16)
        self.registers_table.heading("Register", text="Register")
        self.registers_table.heading("Value", text="Value")
        self.registers_table.pack()
        
        for i in range(32):
            self.registers_table.insert("", "end", values=(f"R{i}", "0"))
        
        # Table for Latches
        self.latches_frame = tk.LabelFrame(self.root, text="Latches", width=50)
        self.latches_frame.grid(row=32, column=0, columnspan=10, sticky="nsew", padx=15, pady=15, ipady=5)

        # Subframes for each latch
        self.if_id_frame = tk.LabelFrame(self.latches_frame, text="IF / ID")
        self.if_id_frame.grid(row=0, column=0, padx=15, pady=5)
        self.id_ex_frame = tk.LabelFrame(self.latches_frame, text="ID / EX")
        self.id_ex_frame.grid(row=0, column=1, padx=15, pady=5)
        self.ex_mem_frame = tk.LabelFrame(self.latches_frame, text="EX / MEM")
        self.ex_mem_frame.grid(row=0, column=2, padx=15, pady=5)
        self.mem_wb_frame = tk.LabelFrame(self.latches_frame, text="MEM / WB")
        self.mem_wb_frame.grid(row=0, column=3, padx=15, pady=5)

        # Text widgets for each latch
        self.if_id_text = tk.Text(self.if_id_frame, height=20, width=40)
        self.if_id_text.pack()
        self.id_ex_text = tk.Text(self.id_ex_frame, height=20, width=40)
        self.id_ex_text.pack()
        self.ex_mem_text = tk.Text(self.ex_mem_frame, height=20, width=40)
        self.ex_mem_text.pack()
        self.mem_wb_text = tk.Text(self.mem_wb_frame, height=20, width=40)
        self.mem_wb_text.pack()

        for data in self.if_id_data:
            self.if_id_text.insert(tk.END, f"{data}:\n")

        for data in self.id_ex_data:
            self.id_ex_text.insert(tk.END, f"{data}:\n")

        for data in self.ex_mem_data:
            self.ex_mem_text.insert(tk.END, f"{data}:\n")

        for data in self.mem_wb_data:
            self.mem_wb_text.insert(tk.END, f"{data}:\n")


    def load_file(self):
        file_path = filedialog.askopenfilename()
        if file_path:
            self.file_entry.delete(0, tk.END)
            self.file_entry.insert(0, file_path)
            # Aquí se cargaría el archivo en memoria

    def set_baudrate_and_port(self):
        self.baudrate = int(self.baud_entry.get())
        self.port = self.port_entry.get()
        try:
            self.baudrate = int(self.baudrate)
            self.comunicator = Comunicator(self.port, self.baudrate)
            if self.comunicator.serial:
                self.save_config()
                print(f"Baudrate set to: {self.baudrate}, Port set to: {self.port}")
            else:
                print("Failed to open serial port.")
        except ValueError:
            print("Invalid baudrate value. Please enter a valid integer.")

    def compile_program(self):
        # Aquí se llamará al método del compilador
        pass

    def load_program(self):
        # Aquí se llamará al método del comunicador
        pass

    def execute_program(self):
        # Aquí se mandará la señal de ejecución al comunicador
        pass

    def next_step(self):
        # Aquí se enviará la señal de siguiente paso
        pass

    def cancel_debug(self):
        # Aquí se cancelará la depuración
        pass

    def run(self):
        self.root.mainloop()