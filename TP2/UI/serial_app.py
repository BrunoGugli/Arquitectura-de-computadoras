import tkinter as tk
from tkinter import ttk
import serial
import time
import argparse
import threading

# Configurar los argumentos de línea de comandos
parser = argparse.ArgumentParser(description="Serial Communication App")
parser.add_argument("port", help="Path al puerto USB (e.g., /dev/ttyUSB0)")
parser.add_argument("baud_rate", type=int, help="Baud rate (e.g., 9600)")
args = parser.parse_args()

ser = serial.Serial(args.port, args.baud_rate, timeout=1)

def send_data():
    try:
        num1 = int(entry1.get())
        num2 = int(entry2.get())
        operation = combo.get()

        if 0 <= num1 <= 255 and 0 <= num2 <= 255:
            # Preparar el primer numero de 8 bits
            ser.write(bytes([num1]))
            time.sleep(0.001)

            # Preparar el segundo número de 8 bits
            ser.write(bytes([num2]))
            time.sleep(0.001)

            print(f"Número 1: {num1} - Número 2: {num2}")

            # Preparar el operador con 2 bits MSB 10
            operations = {
                "ADD": 0b100000,
                "SUB": 0b100010,
                "AND": 0b100100,
                "OR": 0b100101,
                "XOR": 0b100110,
                "SRA": 0b000011,
                "SRL": 0b000010,
                "NOR": 0b100111
            }
            op_code = operations[operation]
            print(f"Operación: {operation} - Código de operación: {op_code}")
            ser.write(bytes([op_code]))
            time.sleep(0.001)

            receive_data()
        else:
            print("Por favor, ingrese números entre 0 y 255.")
    except ValueError as e:
        print("Por favor, ingrese números válidos.")
        print(e)

def receive_data():
    while True:
        if ser.in_waiting > 0:
            received_data = ser.read(2)
            received_number = int.from_bytes(received_data, byteorder='big', signed = True)
            result_var.set(received_number)
            print(f"Resultado recibido: {received_number}")
            break

# Configuración de la interfaz gráfica
root = tk.Tk()
root.title("Serial Communication")

frame = ttk.Frame(root, padding="10")
frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

ttk.Label(frame, text="Número 1:").grid(column=0, row=0, sticky=tk.W)
entry1 = ttk.Entry(frame)
entry1.grid(column=1, row=0, sticky=(tk.W, tk.E))

ttk.Label(frame, text="Número 2:").grid(column=0, row=1, sticky=tk.W)
entry2 = ttk.Entry(frame)
entry2.grid(column=1, row=1, sticky=(tk.W, tk.E))

ttk.Label(frame, text="Operación:").grid(column=0, row=2, sticky=tk.W)
combo = ttk.Combobox(frame, values=["ADD", "SUB", "AND", "OR", "XOR", "SRA", "SRL", "NOR"])
combo.grid(column=1, row=2, sticky=(tk.W, tk.E))

ttk.Button(frame, text="Enviar", command=send_data).grid(column=0, row=3, columnspan=2)

ttk.Label(frame, text="Resultado recibido:").grid(column=0, row=4, sticky=tk.W)
result_var = tk.StringVar()
result_label = ttk.Label(frame, textvariable=result_var)
result_label.grid(column=1, row=4, sticky=(tk.W, tk.E))

root.mainloop()

