

class Compiler():
    
    def __init__(self):
        pass

    def compile(self, instructions: list[str]) -> list[int]:
        compiled_instructions: list[int] = []
        for instruction in instructions:
            compiled_instruction = self._translate(instruction)
            compiled_instructions.append(compiled_instruction)
        return compiled_instructions
    
    def _translate(self, instruction: str) -> bytearray:
        pass

