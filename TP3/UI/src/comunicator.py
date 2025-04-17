import serial
import binascii
from typing import Generator

class Comunicator:
    def __init__(self, port:str, baudrate:int):
        try:
            self.serial = serial.Serial(port=port, baudrate=baudrate, timeout=1, inter_byte_timeout=0.1)
        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
            self.serial = None

    def send_data(self, msg: bytes):
        if len(msg) != 4:
            raise ValueError("Data must be exactly 4 bytes long")
        # Print the message as bits
        print(f"Sending: {binascii.hexlify(msg)}. Bin: {bin(int.from_bytes(msg, byteorder='big'))}, Raw: {msg}")
        reversed_msg = msg[::-1]
        self.serial.write(reversed_msg)
        self.serial.flush()
        

    def receive_data(self) -> bytes:
        while True:
            if self.serial.in_waiting >= 4:
                data = self.serial.read(4) # Lee 32 bits
                self.serial.flush()
                data = data[::-1]
                # Print the message as bits
                # print(f"Received: {binascii.hexlify(data)}. Bin: {bin(int.from_bytes(data, byteorder='big'))}, Raw: {data}")
                return data
            
    def get_serial(self) -> serial.Serial | None:
        return self.serial
