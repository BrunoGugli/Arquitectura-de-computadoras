import serial
import binascii

class Comunicator:
    def __init__(self, port:str, baudrate:int):
        try:
            self.serial = serial.Serial(port=port, baudrate=baudrate, timeout=1)
        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
            self.serial = None

    def send_data(self, msg: bytes):
        if len(msg) != 4:
            raise ValueError("Data must be exactly 4 bytes long")
        # Print the message as bits
        print(f"Sending: {binascii.hexlify(msg)}. Bin: {bin(int.from_bytes(msg, byteorder='big'))}, Raw: {msg}")
        self.serial.write(msg)

    def receive_data(self) -> bytes:
        while True:
            if self.serial.in_waiting >= 4:
                return self.serial.read(4) # Lee 32 bits
