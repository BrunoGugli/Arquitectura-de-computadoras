import serial


class Comunicator:
    def __init__(self, port:str, baudrate:int):
        try:
            self.serial = serial.Serial(port, baudrate, timeout=1)
        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
            self.serial = None

    def send_data(self, msg: bytes):
        self.serial.write(msg)

    def receive_data(self) -> bytes:
        if self.serial.in_waiting > 0:
            return self.serial.read()
