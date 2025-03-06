import re

class Compiler():
    
    def __init__(self):
        self.type_intructions_dict = self._create_type_instructions_dict()
        self.opcode_instructions_dict = self._create_opcode_instructions_dict()

    def compile(self, instructions: list[str]) -> list[int]:
        compiled_instructions: list[int] = []
        for instruction in instructions:
            compiled_instruction = self._translate(instruction)
            compiled_instructions.append(compiled_instruction)
        return compiled_instructions
    
    def _translate(self, instruction: str) -> int:
        inst_name = self._get_instruction_name(instruction)
        inst_type = self._get_instruction_type(inst_name)
        if inst_type == "tipo_r_sa":
            self._build_r_sa_instruction(instruction)

    def _build_r_sa_instruction(self, instruction: str) -> int:
        pass

    def _build_r_instruction(self, instruction: str) -> int:
        pass

    def _build_i_instruction(self, instruction: str) -> int:
        pass

    def _build_j_instruction(self, instruction: str) -> int:
        pass
    
    def _get_instruction_name(self, instruction: str) -> str:
        return instruction.split(" ")[0]

    def _get_instruction_type(self, instruction_name: str) -> str:
        for type_name, instructions in self.type_intructions_dict.items():
            if instruction_name in instructions:
                return type_name
        return None


    def _create_type_instructions_dict(self) -> dict[str, list[str]]:
        return {
            "tipo_r_sa": [
                "sll", "srl", "sra"
            ],
            "tipo_r":["srlv", "sllv", "srav", "addu", "and", "jalr", "jr", "nor", "or", "subu", "xor", "slt", "sltu", "sub", "add"],
            "tipo_i": ["addi", "addiu", "andi", "beq", "bne", "lb", "lbu", "lh", "lhu", "lui", "lw", "lwu", "ori", "sb", "sh", "sw", "xori", "slti", "sltiu"],
            "tipo_j": ["j", "jal"]
        }
    
    def _create_opcode_instructions_dict(self) -> dict[str, int]:
        return {
            "sll": 0b000000,
            "srl": 0b000010,
            "sra": 0b000011,
            "sllv": 0b000100,
            "srlv": 0b000110,
            "srav": 0b000111,
            "addu": 0b100001,
            "and": 0b100100,
            "jalr": 0b001001,
            "jr": 0b001000,
            "nor": 0b100111,
            "or": 0b100101,
            "subu": 0b100011,
            "xor": 0b100110,
            "slt": 0b101010,
            "sltu": 0b101011,
            "sub": 0b100010,
            "add": 0b100000,
            "addi": 0b001000,
            "addiu": 0b001001,
            "andi": 0b001100,
            "beq": 0b000100,
            "bne": 0b000101,
            "lb": 0b100000,
            "lbu": 0b100100,
            "lh": 0b100001,
            "lhu": 0b100101,
            "lui": 0b001111,
            "lw": 0b100011,
            "lwu": 0b100111,
            "ori": 0b001101,
            "sb": 0b101000,
            "sh": 0b101001,
            "sw": 0b101011,
            "xori": 0b001110,
            "slti": 0b001010,
            "sltiu": 0b001011,
            "j": 0b000010,
            "jal": 0b000011
        }

