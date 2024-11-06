import tkinter as tk
from tkinter import ttk
import serial
import time
import threading

# Configurar la comunicación serial
port = input("Ingrese el path al puerto USB (e.g., /dev/ttyUSB0): ")
baud_rate = int(input("Ingrese el baud rate (e.g., 9600): "))
ser = serial.Serial(port, baud_rate)

def send_data():
    try:
        num1 = int(entry1.get())
        num2 = int(entry2.get())
        operation = combo.get()

        if 0 <= num1 <= 255 and 0 <= num2 <= 255:
            # Preparar el primer número con 2 bits MSB 00
            num1_10bit = (0b00 << 8) | num1
            num1_high = (num1_10bit >> 8) & 0xFF
            num1_low = num1_10bit & 0xFF
            ser.write(bytes([num1_high, num1_low]))
            time.sleep(0.001)

            # Preparar el segundo número con 2 bits MSB 01
            num2_10bit = (0b01 << 8) | num2
            num2_high = (num2_10bit >> 8) & 0xFF
            num2_low = num2_10bit & 0xFF
            ser.write(bytes([num2_high, num2_low]))
            time.sleep(0.001)

            # Preparar el operador con 2 bits MSB 10
            operations = {
                "ADD": 0b1000000000,
                "SUB": 0b1000000001,
                "AND": 0b1000000010,
                "OR": 0b1000000011,
                "XOR": 0b1000000100,
                "SRA": 0b1000000101,
                "SRL": 0b1000000110,
                "NOR": 0b1000000111
            }
            op_10bit = operations[operation]
            op_high = (op_10bit >> 8) & 0xFF
            op_low = op_10bit & 0xFF
            ser.write(bytes([op_high, op_low]))
            time.sleep(0.001)

            # Iniciar el hilo para recibir datos
            threading.Thread(target=receive_data).start()

    except ValueError as e:
        print("Por favor, ingrese números válidos.")
        print(e)

def receive_data():
    while True:
        if ser.in_waiting > 0:
            received_data = ser.read(2)
            received_number = int.from_bytes(received_data, byteorder='big')
            result_var.set(received_number)
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
