import tkinter as tk
from tkinter import ttk
import serial
import time

# Configurar la comunicación serial
ser = serial.Serial('/dev/usb/hiddev0', 9600)  # Cambia '/dev/ttyUSB0' por el puerto serial correcto

def send_data():
    try:
        num1 = int(entry1.get())
        num2 = int(entry2.get())
        operation = combo.get()

        if 0 <= num1 <= 255 and 0 <= num2 <= 255:
            # Enviar el primer número con 2 bits MSB 00
            ser.write(bytes([num1 & 0x3F]))
            time.sleep(0.001)

            # Enviar el segundo número con 2 bits MSB 01
            ser.write(bytes([0x40 | (num2 & 0x3F)]))
            time.sleep(0.001)

            # Enviar el código de operación
            operations = {
                "ADD": "1000100000",
                "SUB": "1000100010",
                "AND": "1000100100",
                "OR": "1000100101",
                "XOR": "1000100110",
                "SRA": "1000000011",
                "SRL": "1000000010",
                "NOR": "1000100111"
            }
            ser.write(bytes([int(operations[operation], 2)]))
        else:
            print("Los números deben estar entre 0 y 255")
    except ValueError:
        print("Por favor, ingrese números válidos")

# Crear la ventana principal
root = tk.Tk()
root.title("Serial Sender")

# Campo de entrada para el primer número
tk.Label(root, text="Número 1 (0-255):").grid(row=0, column=0)
entry1 = tk.Entry(root)
entry1.grid(row=0, column=1)

# Campo de entrada para el segundo número
tk.Label(root, text="Número 2 (0-255):").grid(row=1, column=0)
entry2 = tk.Entry(root)
entry2.grid(row=1, column=1)

# Menú desplegable para seleccionar la operación
tk.Label(root, text="Operación:").grid(row=2, column=0)
combo = ttk.Combobox(root, values=["ADD", "SUB", "AND", "OR", "XOR", "SRA", "SRL", "NOR"])
combo.grid(row=2, column=1)
combo.current(0)

# Botón "Set"
button = tk.Button(root, text="Set", command=send_data)
button.grid(row=3, columnspan=2)

# Iniciar el bucle principal de la interfaz gráfica
root.mainloop()
