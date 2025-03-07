import re

class Compiler():

    def __init__(self):
        self.type_intructions_dict = self._create_type_instructions_dict()
        self.opcode_instructions_dict = self._create_opcode_instructions_dict()
        self.instruction_builder_dict = {
            "tipo_r_sa": self._build_r_sa_instruction,
            "tipo_r": self._build_r_instruction,
            "tipo_i": self._build_i_instruction,
            "tipo_j": self._build_j_instruction
        }

    def compile(self, instructions: list[str]) -> list[int]:
        compiled_instructions: list[int] = []
        for instruction in instructions:
            compiled_instruction = self._translate(instruction)
            compiled_instructions.append(compiled_instruction)
        return compiled_instructions

    def _translate(self, instruction: str) -> int:
        inst_name = self._get_instruction_name(instruction)
        inst_type = self._get_instruction_type(inst_name)
        inst = self.instruction_builder_dict[inst_type](instruction)
        if not inst:
            raise Exception(f"Instruction {instruction} has an invalid syntax")
        return inst

    def _build_r_sa_instruction(self, instruction: str) -> int:
        type_r_regex = "([\w]+)\s+\$(\d+),\s*\$(\d+),\s*(-?\d*)"
        match = re.match(type_r_regex, instruction)
        if match:
            func = self.opcode_instructions_dict[match.group(1)]
            rd = int(match.group(2))
            rt = int(match.group(3))
            shamt = int(match.group(4))
            self._check_register_boundary(instruction, rd, 0, 31, True, True)
            self._check_register_boundary(instruction, rt, 0, 31, True, True)
            self._check_register_boundary(instruction, shamt, 0, 31, True, True)
            return (0b000000 << 26) | (0b00000 << 21) | (self._mask(rt, 0b11111) << 16) | (self._mask(rd, 0b11111) << 11) | (self._mask(shamt, 0b11111) << 6) | self._mask(func, 0b111111)
        
        return None

    def _build_r_instruction(self, instruction: str) -> int:
        type_r_regex = "([\w]+)\s+\$(\d+),\s*\$(\d+),\s*\$(\d+)"
        match = re.match(type_r_regex, instruction)
        if match:
            func = self.opcode_instructions_dict[match.group(1)]
            rs = int(match.group(3))
            rt = int(match.group(4))
            rd = int(match.group(2))
            self._check_register_boundary(instruction, rs, 0, 31, True, True)
            self._check_register_boundary(instruction, rt, 0, 31, True, True)
            self._check_register_boundary(instruction, rd, 0, 31, True, True)
            return (0b000000 << 26) | (self._mask(rs, 0b11111) << 21) | (self._mask(rt, 0b11111) << 16) | (self._mask(rd, 0b11111) << 11) | 0b00000 | self._mask(func, 0b111111)

        return None

    def _build_i_instruction(self, instruction: str) -> int:
        type_i_regex = "([\w]+)\s+\$(\d+),\s*\$(\d+),\s*\(?(-?\d+)\)?"
        match = re.match(type_i_regex, instruction)
        if match:
            opcode = self.opcode_instructions_dict[match.group(1)]
            rs = int(match.group(3))
            rt = int(match.group(2))
            imm = int(match.group(4))
            self._check_register_boundary(instruction, rs, 0, 31, True, True)
            self._check_register_boundary(instruction, rt, 0, 31, True, True)
            return (self._mask(opcode, 0b111111) << 26) | (self._mask(rs, 0b11111) << 21) | (self._mask(rt, 0b11111) << 16) | self._mask(imm, 0xFFFF)
        
        return None

    def _build_j_instruction(self, instruction: str) -> int:
        type_j_regex = "([\w]+)\s+(\d+)"
        match = re.match(type_j_regex, instruction)
        if match:
            opcode = self.opcode_instructions_dict[match.group(1)]
            instr_index = int(match.group(2))
            return (self._mask(opcode, 0b111111) << 26) | self._mask(instr_index, 0x3FFFFFF)
        
        return None

    def _get_instruction_name(self, instruction: str) -> str:
        return instruction.split(" ")[0]

    def _check_register_boundary(self, instruction: str, register: int, min: int, max: int, include_min: bool, include_max: bool) -> None:
        if include_min and register < min:
            raise Exception(f"Register number must be greater or equal to {min}")
        if include_max and register > max:
            raise Exception(f"Register number must be less or equal to {max}")
        if register < min or register > max:
            raise Exception(f"Registers in instruction {instruction} must be between {min} and {max}")

    def _get_instruction_type(self, instruction_name: str) -> str:
        for type_name, instructions in self.type_intructions_dict.items():
            if instruction_name in instructions:
                return type_name
        return None

    def _mask(self, value: int, mask: int) -> int:
        return value & mask

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
