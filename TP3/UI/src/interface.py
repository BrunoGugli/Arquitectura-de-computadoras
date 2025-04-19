import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from typing import Final
import os
import json
from src.comunicator import Comunicator
from src.compiler import Compiler
from enum import Enum
from serial import SerialException


class ExecutionMode(Enum):
    CONTINUOUS = 1
    STEP = 2

class Interface:

    CONFIG_FILE = "config.json"
    NUMBER_OF_STAGES: Final = 5  # Number of stages in the pipeline

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("MIPS Debugger")
        #self.root.resizable(False, False)

        self.instructions_from_file: list[str] = []
        self.intructions_to_send: list[int] = []
        self.data_received_list: list[int] = []
        self.registers_content_received: list[int] = []
        self.memory_content_received: list[int] = []
        self.latches_content_received: list[int] = []
        self.latches_data_dict = self._create_latches_data_dict()

        self.compiler: Compiler = Compiler()

        self.executing_step: bool = False
        self.program_loaded: bool = False
        self.baudrate_port_setted: bool = False
        self.count_instructions: bool = True
        self.instructions_completed_count: int = 0
        self.instruction_entered_count: int = 0
        self.steps_counter: int = 0
        self.current_execution_mode: ExecutionMode = ExecutionMode.CONTINUOUS
        self.load_config()
        self.create_widgets()
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
    
    def on_closing(self):
        if not messagebox.askokcancel("Exit", "Do you want to close the application?"):
            return
        if hasattr(self, 'comunicator') and self.executing_step:
            self.cancel_debug_act()
        if hasattr(self, 'comunicator') and self.comunicator and hasattr(self.comunicator, 'serial'):
            self.comunicator.get_serial().close()
            print("Puerto serial cerrado correctamente")
        self.root.destroy()
        
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
        
        # Configurar las columnas y filas para que se expandan
        for i in range(10):  # Ajusta el rango según el número de columnas que tengas
            self.root.grid_columnconfigure(i, weight=1)
        for i in range(20):  # Ajusta el rango según el número de filas que tengas
            self.root.grid_rowconfigure(i, weight=1)
        
        # Labels
        tk.Label(self.root, text="Port:", padx=10).grid(row=0, column=0, sticky="nsew")
        tk.Label(self.root, text="Baud Rate:", padx=10).grid(row=2, column=0, sticky="nsew")
        tk.Label(self.root, text="File for Instructions:", padx=10).grid(row=4, column=0, sticky="nsew")
        tk.Label(self.root, text="Execution Mode:", padx=10).grid(row=6, column=0, sticky="nsew")
        
        # Entry fields
        self.port_entry = tk.Entry(self.root)
        self.baud_entry = tk.Entry(self.root)
        self.file_entry = tk.Entry(self.root)
        
        self.port_entry.grid(row=1, column=0, padx=10, sticky="nsew")
        self.baud_entry.grid(row=3, column=0, padx=10, sticky="nsew")
        self.file_entry.grid(row=5, column=0, padx=10, sticky="nsew")

        # Set default values from config
        self.port_entry.insert(0, self.port)
        self.baud_entry.insert(0, self.baudrate)
        
        # Dropdown menu
        self.execution_mode = tk.StringVar()
        self.execution_dropdown = ttk.Combobox(self.root, textvariable=self.execution_mode, values=["Continuous", "Step"], width=18)
        self.execution_dropdown.grid(row=7, column=0, sticky="nsew")
        
        # Buttons
        self.set_button = tk.Button(self.root, text="Set", command=self.set_baudrate_and_port)
        self.load_file_btn = tk.Button(self.root, text="Load File", command=self.load_file)
        self.compile_btn = tk.Button(self.root, text="Compile Program", command=self.compile_program)
        self.load_program_btn = tk.Button(self.root, text="Load Program", command=self.load_program)
        self.execute_btn = tk.Button(self.root, text="Execute", command=self.execute_program)
        self.next_step_btn = tk.Button(self.root, text="Next Step", command=self.next_step)
        self.cancel_debug_btn = tk.Button(self.root, text="Cancel Debug", command=self.cancel_debug)
        
        # Button grid placement
        self.set_button.grid        (row=2, column=1, padx=5, pady=5, sticky="nsew")
        self.load_file_btn.grid     (row=5, column=1, padx=5, pady=2, sticky="nsew")
        self.compile_btn.grid       (row=5, column=2, padx=5, pady=2, sticky="nsew")
        self.load_program_btn.grid  (row=5, column=3, padx=5, pady=2, sticky="nsew")
        self.execute_btn.grid       (row=7, column=1, ipadx=5, pady=2, sticky="nsew")
        self.next_step_btn.grid     (row=7, column=2, ipadx=25, pady=2, sticky="nsew")
        self.cancel_debug_btn.grid  (row=7, column=3, padx=5, pady=2, sticky="nsew")

        # Intructions entered into the pipeline label
        self.instruction_count_label = tk.Label(self.root, text="Number of instructions entered into the pipeline: 0/0")
        self.instruction_count_label.grid(row=8, column=0, columnspan=4, sticky="nsew", padx=10, pady=5)

        # Instructions completely executed label
        self.instructions_completed_label = tk.Label(self.root, text="Instructions completely executed: 0/0")
        self.instructions_completed_label.grid(row=9, column=0, columnspan=4, sticky="nsew", padx=10, pady=5)

        # Debug session in progress label
        self.debug_session_label = tk.Label(self.root, text="Debug session in progress: No")
        self.debug_session_label.grid(row=10, column=0, columnspan=4, sticky="nsew", padx=10, pady=5)

        # Memory Data Display
        self.memory_frame = tk.LabelFrame(self.root, text="Memory Data")
        self.memory_frame.grid(row=0, column=4, columnspan=3, rowspan=16, ipadx=10, ipady=5, padx=15, pady=5, sticky="nsew")
        self.memory_table = ttk.Treeview(self.memory_frame, columns=("Address", "Value"), show="headings", height=16)
        self.memory_table.heading("Address", text="Address")
        self.memory_table.heading("Value", text="Value")
        self.memory_table.pack(expand=True, fill='both')
        
        # Table for Registers
        self.registers_frame = tk.LabelFrame(self.root, text="Registers")
        self.registers_frame.grid(row=0, column=7, columnspan=3, rowspan=16, ipadx=10, ipady=5, padx=15, pady=15, sticky="nsew")
        self.registers_table = ttk.Treeview(self.registers_frame, columns=("Register", "Value"), show="headings", height=16)
        self.registers_table.heading("Register", text="Register")
        self.registers_table.heading("Value", text="Value")
        self.registers_table.pack(expand=True, fill='both')
        
        for i in range(32):
            self.registers_table.insert("", "end", iid=f"R{i}", values=(f"R{i}", "0"))
        
        # Table for Latches
        self.latches_frame = tk.LabelFrame(self.root, text="Latches", width=50)
        self.latches_frame.grid(row=32, column=0, columnspan=10, sticky="nsew", padx=15, pady=15, ipady=5)

        # Configurar las columnas y filas del frame de los latches para que se expandan
        for i in range(4):
            self.latches_frame.grid_columnconfigure(i, weight=1)
        self.latches_frame.grid_rowconfigure(0, weight=1)


        # Subframes for each latch
        self.if_id_frame = tk.LabelFrame(self.latches_frame, text="IF / ID")
        self.if_id_frame.grid(row=0, column=0, padx=15, pady=5, sticky="nsew")
        self.id_ex_frame = tk.LabelFrame(self.latches_frame, text="ID / EX")
        self.id_ex_frame.grid(row=0, column=1, padx=15, pady=5, sticky="nsew")
        self.ex_mem_frame = tk.LabelFrame(self.latches_frame, text="EX / MEM")
        self.ex_mem_frame.grid(row=0, column=2, padx=15, pady=5, sticky="nsew")
        self.mem_wb_frame = tk.LabelFrame(self.latches_frame, text="MEM / WB")
        self.mem_wb_frame.grid(row=0, column=3, padx=15, pady=5, sticky="nsew")

        # Configurar las columnas y filas de los subframes para que se expandan
        for frame in [self.if_id_frame, self.id_ex_frame, self.ex_mem_frame, self.mem_wb_frame]:
            frame.grid_columnconfigure(0, weight=1)
            frame.grid_rowconfigure(0, weight=1)

        # Text widgets for each latch
        self.if_id_text = tk.Text(self.if_id_frame, height=20, width=40)
        self.if_id_text.pack(expand=True, fill='both')
        self.id_ex_text = tk.Text(self.id_ex_frame, height=20, width=40)
        self.id_ex_text.pack(expand=True, fill='both')
        self.ex_mem_text = tk.Text(self.ex_mem_frame, height=20, width=40)
        self.ex_mem_text.pack(expand=True, fill='both')
        self.mem_wb_text = tk.Text(self.mem_wb_frame, height=20, width=40)
        self.mem_wb_text.pack(expand=True, fill='both')

        self._update_latches_text_boxes()

    def load_file(self):
        file_path = filedialog.askopenfilename()
        if file_path:
            self.file_entry.delete(0, tk.END)
            self.file_entry.insert(0, file_path)
            try:
                with open(file_path, "r") as file:
                    self.instructions_from_file = [line for line in file.readlines() if line.strip()]
                    file.close()
                    print(f"File loaded successfully: {len(self.instructions_from_file)} instructions.")
            except Exception as e:
                messagebox.showerror("Error", f"Error loading file: {e}")
                
    def set_baudrate_and_port(self):
        self.baudrate = int(self.baud_entry.get())
        self.port = self.port_entry.get()
        try:
            self.baudrate = int(self.baudrate)
            self.comunicator = Comunicator(self.port, self.baudrate)
            if self.comunicator.serial:
                self.save_config()
                print(f"Baudrate set to: {self.baudrate}, Port set to: {self.port}")
                self.baudrate_port_setted = True
            else:
                messagebox.showerror("Error", "Error opening serial port. Please check the port and baudrate values.")
        except SerialException as e:
            messagebox.showerror("Error", f"Error opening serial port: {e}")
        except ValueError as e:
            messagebox.showerror("Error", f"Invalid value setting serial port: {e}")

    def compile_program(self):
        # Aquí se llamará al método del compilador
        if not self.instructions_from_file:
            messagebox.showerror("Error", "No instructions to compile. Please load a file first.")
            return
        try:
            self.intructions_to_send = self.compiler.compile(self.instructions_from_file)
            print(f"Program compiled successfully: {len(self.intructions_to_send)} instructions.")
        except Exception as e:
            messagebox.showerror("Error", f"Error compiling program: {e}")

    def load_program(self):
        if not self.intructions_to_send:
            messagebox.showerror("Error", "No instructions to load. Please compile a program first.")
            return
        if not self.baudrate_port_setted:
            messagebox.showerror("Error", "No port and baudrate set. Please set the port and baudrate first.")
            return
        try:
            self.comunicator.send_data(b'\0lom')
            for instruction in self.intructions_to_send:
                
                self.comunicator.send_data(instruction.to_bytes(4, byteorder='big'))
            
            self.comunicator.send_data((0xffffffff).to_bytes(4, byteorder='big')) # End instruction
            self.program_loaded = True
            print("Program loaded successfully!")
        except Exception as e:
            messagebox.showerror("Error", f"Error loading program: {e}")

    def execute_program(self):
        # Aquí se mandará la señal de ejecución al comunicador
        if not self.program_loaded:
            messagebox.showerror("Error", "No program loaded. Please compile and load a program first.")
            return
        if self.executing_step:
            messagebox.showerror("Error", "Already executing program in step mode.\nPlease cancel the current debug session to execute the program.")
            return
        try:
            self.current_execution_mode = self._set_exec_mode()
        except Exception as e:
            messagebox.showerror("Error", f"Error setting execution mode: {e}")
            return
        
        if self.current_execution_mode == ExecutionMode.CONTINUOUS:
            self.comunicator.send_data(b'\0com')
            self._receive_data()
            self._update_in_screen_data()
        elif self.current_execution_mode == ExecutionMode.STEP:
            self.comunicator.send_data(b'\0stm')
            self.executing_step = True
            self.instruction_entered_count += 1
            self._update_debug_session_in_progress_label()
            self._update_instruction_count()
            self._update_instructions_completed_count()
            messagebox.showwarning("Warning!", "Executing program in step mode.\nPress 'Next Step' to execute the next instruction.\nPress 'Cancel Debug' to stop the debug session.\nYou can close this window and keep using the interface.")

    def _set_exec_mode(self) -> ExecutionMode:
        mode = self.execution_mode.get()
        if not mode:
            raise Exception("No execution mode selected.")
        if mode == "Continuous":
            return ExecutionMode.CONTINUOUS
        elif mode == "Step":
            return ExecutionMode.STEP
        
        raise Exception("Invalid execution mode selected.")

    def _receive_data(self):
        self.data_received_list.clear()
        while True:
            data = self.comunicator.receive_data()
            if data == b'endd':
                return
            self.data_received_list.append(self._transform_received_data_to_int(data))

    def _transform_received_data_to_int(self, data: bytes) -> int:
        return int.from_bytes(data, byteorder='big')

    def _update_in_screen_data(self):
        self._separate_data()
        self._update_registers_data()
        self._update_latches_data()
        self._update_memory_data()

    def _separate_data(self):
        self.registers_content_received = self.data_received_list[:32]
        self.latches_content_received = self.data_received_list[32:43]
        self.memory_content_received = self.data_received_list[43:]

    def _update_registers_data(self):
        for i, data in enumerate(self.registers_content_received):
            self.registers_table.item(f"R{i}", values=(f"R{i}", data))

    def _update_latches_data(self):
        self._update_if_id_latch()
        self._update_id_ex_latch()
        self._update_ex_mem_latch()
        self._update_mem_wb_latch()
        self._update_latches_text_boxes()

    def _update_if_id_latch(self):
        self.latches_data_dict["IF/ID"]["PC"] = self.latches_content_received[0]
        self.latches_data_dict["IF/ID"]["instruction"] = self.latches_content_received[1]

    def _update_id_ex_latch(self):
        self.latches_data_dict["ID/EX"]["alu_src"] = self.latches_content_received[2] & 0x1
        self.latches_data_dict["ID/EX"]["alu_op"] = (self.latches_content_received[2] >> 1) & 0x3
        self.latches_data_dict["ID/EX"]["reg_dest"] = (self.latches_content_received[2] >> 3) & 0x1
        self.latches_data_dict["ID/EX"]["data_width"] = (self.latches_content_received[2] >> 4) & 0x3
        self.latches_data_dict["ID/EX"]["unsigned"] = (self.latches_content_received[2] >> 6) & 0x1
        self.latches_data_dict["ID/EX"]["mem_write"] = (self.latches_content_received[2] >> 7) & 0x1
        self.latches_data_dict["ID/EX"]["mem_read"] = (self.latches_content_received[2] >> 8) & 0x1
        self.latches_data_dict["ID/EX"]["reg_write"] = (self.latches_content_received[2] >> 9) & 0x1
        self.latches_data_dict["ID/EX"]["mem_to_reg"] = (self.latches_content_received[2] >> 10) & 0x1
        self.latches_data_dict["ID/EX"]["shamt"] = (self.latches_content_received[2] >> 11) & 0x1f
        self.latches_data_dict["ID/EX"]["opcode"] = (self.latches_content_received[2] >> 16) & 0x3f
        self.latches_data_dict["ID/EX"]["inmediato"] = ((self.latches_content_received[2] >> 22) & 0x3ff) | ((self.latches_content_received[3] & 0x3fffff) << 10)
        self.latches_data_dict["ID/EX"]["funct"] = (self.latches_content_received[3] >> 22) & 0x3f
        self.latches_data_dict["ID/EX"]["rd"] = ((self.latches_content_received[3] >> 27) & 0xf) | ((self.latches_content_received[4] & 0x1) << 4)
        self.latches_data_dict["ID/EX"]["rt"] = (self.latches_content_received[4] >> 1) & 0x1f
        self.latches_data_dict["ID/EX"]["rs"] = (self.latches_content_received[4] >> 6) & 0x1f
        self.latches_data_dict["ID/EX"]["RB"] = ((self.latches_content_received[4] >> 11) & 0x1fffff) | ((self.latches_content_received[5] & 0x7ff) << 21)
        self.latches_data_dict["ID/EX"]["RA"] = ((self.latches_content_received[5] >> 11) & 0x1fffff) | ((self.latches_content_received[6] & 0x7ff) << 21)

    def _update_ex_mem_latch(self):
        self.latches_data_dict["EX/MEM"]["reg_write"] = (self.latches_content_received[6] >> 11) & 0x1
        self.latches_data_dict["EX/MEM"]["mem_to_reg"] = (self.latches_content_received[6] >> 12) & 0x1
        self.latches_data_dict["EX/MEM"]["data_width"] = (self.latches_content_received[6] >> 13) & 0x3
        self.latches_data_dict["EX/MEM"]["unsigned"] = (self.latches_content_received[6] >> 15) & 0x1
        self.latches_data_dict["EX/MEM"]["mem_write"] = (self.latches_content_received[6] >> 16) & 0x1
        self.latches_data_dict["EX/MEM"]["mem_read"] = (self.latches_content_received[6] >> 17) & 0x1
        self.latches_data_dict["EX/MEM"]["reg_dest"] = (self.latches_content_received[6] >> 18) & 0x1f
        self.latches_data_dict["EX/MEM"]["data_to_write"] = ((self.latches_content_received[6] >> 23) & 0x1ff) | ((self.latches_content_received[7] & 0x7fffff) << 9)
        self.latches_data_dict["EX/MEM"]["ALU_result"] = ((self.latches_content_received[7] >> 23) & 0x1ff) | ((self.latches_content_received[8] & 0x7fffff) << 9)

    def _update_mem_wb_latch(self):
        # "ALU_result", "data_from_mem", "reg_dest", "mem_to_reg", "reg_write"
        self.latches_data_dict["MEM/WB"]["reg_write"] = (self.latches_content_received[8] >> 23) & 0x1
        self.latches_data_dict["MEM/WB"]["mem_to_reg"] = (self.latches_content_received[8] >> 24) & 0x1
        self.latches_data_dict["MEM/WB"]["reg_dest"] = (self.latches_content_received[8] >> 25) & 0x1f
        self.latches_data_dict["MEM/WB"]["data_from_mem"] = ((self.latches_content_received[8] >> 30) & 0x3) | ((self.latches_content_received[9] & 0x3fffffff) << 2)
        self.latches_data_dict["MEM/WB"]["ALU_result"] = ((self.latches_content_received[9] >> 30) & 0x3) | ((self.latches_content_received[10] & 0x3fffffff) << 2)

    def _update_latches_text_boxes(self):
        # Limpiar los text boxes de los latches
        self.clear_latches_text_boxes()

        # Actualizar los text boxes de los latches
        for data_name, data in self.latches_data_dict["IF/ID"].items():
            if data_name == "instruction":
                data = hex(data)
            self.if_id_text.insert(tk.END, f"{data_name}: {data}\n")

        for data_name, data in self.latches_data_dict["ID/EX"].items():
            self.id_ex_text.insert(tk.END, f"{data_name}: {data}\n")

        for data_name, data in self.latches_data_dict["EX/MEM"].items():
            self.ex_mem_text.insert(tk.END, f"{data_name}: {data}\n")

        for data_name, data in self.latches_data_dict["MEM/WB"].items():
            self.mem_wb_text.insert(tk.END, f"{data_name}: {data}\n")

    def clear_latches_text_boxes(self):
        self.if_id_text.delete(1.0, tk.END)
        self.id_ex_text.delete(1.0, tk.END)
        self.ex_mem_text.delete(1.0, tk.END)
        self.mem_wb_text.delete(1.0, tk.END)

    def _clear_memory_data_table(self):
        self.memory_table.delete(*self.memory_table.get_children())

    def _update_memory_data(self):
        self._clear_memory_data_table()
        # Toma datos de a dos ya que cada dato viene seguido de su dirección
        for i in range(0, len(self.memory_content_received), 2):
            value = self.memory_content_received[i]
            address = self.memory_content_received[i + 1]
            self.memory_table.insert("", "end", values=(f"{hex(address)} ({address})", value))

    def _update_debug_session_in_progress_label(self):
        if self.executing_step:
            self.debug_session_label.config(text="Debug session in progress: Yes")
        else:
            self.debug_session_label.config(text="Debug session in progress: No")

    def next_step(self):
        if not self.executing_step:
            messagebox.showerror("Error", "No debug session in progress.\nPlease execute the program in step mode to debug.")
            return
        self.comunicator.send_data(b'nxst')
        self._receive_data()
        self._update_in_screen_data()
        if self.count_instructions:
            self.instruction_entered_count += 1
        if self.steps_counter >= self.NUMBER_OF_STAGES - 1: # Se termino de ejecutar la primera completamente
            if self.instructions_completed_count < len(self.intructions_to_send):
                self.instructions_completed_count += 1
        if self.instruction_entered_count == len(self.intructions_to_send):
            self.count_instructions = False
            
        self.steps_counter += 1
        self._update_instruction_count()
        self._update_instructions_completed_count()
        if self.steps_counter == len(self.intructions_to_send) + 1: # La instruccion END llego a ID
            messagebox.showwarning("Warning", "End instruction reached the ID stage.")

    def _update_instruction_count(self):
        self.instruction_count_label.config(text=f"Number of instructions entered into the pipeline: {self.instruction_entered_count}/{len(self.intructions_to_send)}")

    def _update_instructions_completed_count(self):
        self.instructions_completed_label.config(text=f"Instructions completely executed: {self.instructions_completed_count}/{len(self.intructions_to_send)}")

    def cancel_debug(self):
        if not self.executing_step:
            messagebox.showerror("Error", "No debug session in progress.\nPlease execute the program in step mode to debug.")
            return
        if not messagebox.askyesno("Cancel Debug", "Are you sure you want to cancel the debug session?"):
            return
        self.cancel_debug_act()
        self._update_instruction_count()
        self._update_instructions_completed_count()
        self._update_debug_session_in_progress_label()
        self._clear_memory_data_table()
        
    def cancel_debug_act(self):
        self.comunicator.send_data(b'clst')
        self.executing_step = False
        self.instruction_entered_count = 0
        self.instructions_completed_count = 0
        self.steps_counter = 0
        self.count_instructions = True
        
    def _create_latches_data_dict(self) -> dict[str, dict[str, int]]:
        if_id_data: list[str] = ["instruction", "PC"]
        id_ex_data: list[str] = ["RA", "RB", "rs", "rt", "rd", "funct", "inmediato", "opcode", "shamt", "mem_to_reg", "mem_read", "mem_write", "reg_write", "unsigned", "data_width", "reg_dest", "alu_op", "alu_src"]
        ex_mem_data: list[str] = ["ALU_result", "data_to_write", "reg_dest", "mem_read", "mem_write", "unsigned", "data_width", "mem_to_reg", "reg_write"]
        mem_wb_data: list[str] = ["ALU_result", "data_from_mem", "reg_dest", "mem_to_reg", "reg_write"]

        return {
            "IF/ID": {data: 0 for data in if_id_data},
            "ID/EX": {data: 0 for data in id_ex_data},
            "EX/MEM": {data: 0 for data in ex_mem_data},
            "MEM/WB": {data: 0 for data in mem_wb_data}
        }

    def run(self):
        self.root.mainloop()
