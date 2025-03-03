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

# New code
def register_to_binary(register):
    return format(int(register[1:]), '05b')

def immediate_to_binary(immediate):
    return format(int(immediate) & 0xFFFF, '016b')

def parse_instruction(instruction: str):
    parts = instruction.split()
    opcode = parts[0]
    if opcode == "ADDI":
        rt = register_to_binary(parts[1])
        rs = register_to_binary(parts[2])
        immediate = immediate_to_binary(parts[3])
        return f"001000{rs}{rt}{immediate}"
    # Add more instructions here
    return None

def compile_mips_instructions(file_path):
    with open(file_path, 'r') as file:
        instructions = file.readlines()
    
    binary_instructions = []
    for instruction in instructions:
        binary_instruction = parse_instruction(instruction.strip())
        if binary_instruction:
            binary_instructions.append(binary_instruction)
    
    return binary_instructions

# Example usage
file_path = "path_to_your_mips_instructions_file.txt"
binary_instructions = compile_mips_instructions(file_path)
for binary_instruction in binary_instructions:
    print(binary_instruction)