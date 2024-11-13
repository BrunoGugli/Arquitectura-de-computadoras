import serial
import tkinter as tk
from tkinter import messagebox
import sys

class UARTInterface:
    def __init__(self, master, port, baud_rate):
        self.master = master
        self.port = port
        self.baud_rate = baud_rate
        self.ser = serial.Serial(port, baud_rate, timeout=1)
        
        # Crear la interfaz gráfica
        self.master.title("Interfaz UART")
        self.master.geometry("300x200")

        # Variables de entrada
        self.operand1 = tk.StringVar()
        self.operand2 = tk.StringVar()
        self.opcode = tk.StringVar()
        
        # Pedir operandos y opcode
        tk.Label(master, text="Ingrese primer operando (8 bits binarios):").pack()
        self.operand1_entry = tk.Entry(master, textvariable=self.operand1)
        self.operand1_entry.pack()
        tk.Button(master, text="Enviar Operando 1", command=self.send_operand1).pack()

        tk.Label(master, text="Ingrese segundo operando (8 bits binarios):").pack()
        self.operand2_entry = tk.Entry(master, textvariable=self.operand2)
        self.operand2_entry.pack()
        tk.Button(master, text="Enviar Operando 2", command=self.send_operand2).pack()

        tk.Label(master, text="Ingrese opcode (8 bits binarios):").pack()
        self.opcode_entry = tk.Entry(master, textvariable=self.opcode)
        self.opcode_entry.pack()
        tk.Button(master, text="Enviar Opcode", command=self.send_opcode).pack()

    def send_operand1(self):
        value = self.operand1.get()
        if self.validate_binary(value, 8):
            self.send_data(value, "Operando 1")
        else:
            messagebox.showerror("Error", "El operando 1 debe ser un valor binario de 8 bits.")

    def send_operand2(self):
        value = self.operand2.get()
        if self.validate_binary(value, 8):
            self.send_data(value, "Operando 2")
        else:
            messagebox.showerror("Error", "El operando 2 debe ser un valor binario de 8 bits.")

    def send_opcode(self):
        value = self.opcode.get()
        if self.validate_binary(value, 8):
            self.send_data(value, "Opcode")
            messagebox.showinfo("Éxito", "Opcode enviado. Esperando respuesta...")
            self.receive_result()
        else:
            messagebox.showerror("Error", "El opcode debe ser un valor binario de 8 bits.")

    def send_data(self, value, label):
        data_byte = int(value, 2).to_bytes(1, byteorder='big')
        self.ser.write(data_byte)
        bits_sent = len(data_byte) * 8
        print(f"{label} enviado ({bits_sent} bits): {value}")
        messagebox.showinfo("Éxito", f"{label} enviado.")

    def receive_result(self):
        # Esperar el resultado de 16 bits (2 bytes)
        response = self.ser.read(2)
        if len(response) == 2:
            result = int.from_bytes(response, byteorder='big')
            messagebox.showinfo("Resultado", f"Resultado recibido: {result}")
        else:
            messagebox.showerror("Error", "No se recibió respuesta o la respuesta fue incompleta.")

    @staticmethod
    def validate_binary(value, length):
        return len(value) == length and all(c in '01' for c in value)

    def __del__(self):
        # Cerrar el puerto serial cuando el programa termine
        if self.ser.is_open:
            self.ser.close()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python3 uart_gui.py <puerto_usb> <baud_rate>")
        sys.exit(1)
    port = sys.argv[1]
    baud_rate = int(sys.argv[2])

    root = tk.Tk()
    app = UARTInterface(root, port, baud_rate)
    root.mainloop()
