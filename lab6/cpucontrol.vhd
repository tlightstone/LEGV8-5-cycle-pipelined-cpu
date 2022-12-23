library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


entity CPUControl is
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 omits the unconditional branch instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	

-- unconditional branch instruction 000101
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     Reg2Loc  : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;


architecture Behavioral of CPUControl is

     begin 
     Reg2Loc <=  '0' when Opcode ?= "1--0101-000" else -- Rtype
                 '-' when Opcode  = "11111000010" else -- ldur
                 '1' when Opcode  = "11111000000" else --stur
                 '1' when Opcode ?= "1011010----" else --cbnz
                 '-' when Opcode ?= "000101-----" else --ubranch
                 '1' when Opcode ?= "1--100--00-" else 
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR 
                 '-' ; -- immediate
     CBranch <=  '0' when Opcode ?= "1--0101-000" else 
                 '0' when Opcode  = "11111000010" else
                 '0' when Opcode  = "11111000000" else
                 '1' when Opcode ?= "1011010----" else -- cbz
                 '-' when Opcode ?= "000101-----" else
                 '0' when Opcode ?= "1--100--00-" else
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR 
                 '-';
     MemRead <=  '0' when Opcode ?= "1--0101-000" else 
                 '1' when Opcode  = "11111000010" else
                 '0' when Opcode  = "11111000000" else
                 '0' when Opcode ?= "1011010----" else 
                 '-' when Opcode ?= "000101-----" else
                 '0' when Opcode ?= "1--100--00-" else
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR ;
                 '-';
     MemtoReg <= '0' when Opcode ?= "1--0101-000" else 
                 '1' when Opcode  = "11111000010" else
                 '-' when Opcode  = "11111000000" else
                 '-' when Opcode ?= "1011010----" else 
                 '-' when Opcode ?= "000101-----" else
                 '0' when Opcode ?= "1--100--00-" else
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR ;
                 '-';
     MemWrite <= '0' when Opcode ?= "1--0101-000" else 
                 '0' when Opcode  = "11111000010" else
                 '1' when Opcode  = "11111000000" else
                 '0' when Opcode ?= "1011010----" else 
                 '0' when Opcode ?= "000101-----" else
                 '0' when Opcode ?= "1--100--00-" else
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR ;
                 '-';
     ALUSrc <=   '0' when Opcode ?= "1--0101-000" else 
                 '1' when Opcode  = "11111000010" else
                 '1' when Opcode  = "11111000000" else
                 '0' when Opcode ?= "1011010----" else 
                 '-' when Opcode ?= "000101-----" else
                 '1' when Opcode ?= "1--100--00-" else
                 '1' when Opcode ?= "1101001101-" else -- LSL/LSR ; -- is this 1 or 0 ? shamt or rm
                 '-';
     RegWrite <= '1' when Opcode ?= "1--0101-000" else 
                 '1' when Opcode  = "11111000010" else
                 '0' when Opcode  = "11111000000" else
                 '0' when Opcode ?= "1011010----" else 
                 '0' when Opcode ?= "000101-----" else
                 '1' when Opcode ?= "1--100--00-" else
                 '1' when Opcode ?= "1101001101-" else -- LSL/LSR ;
                 '-';
     UBranch <=  '0' when Opcode ?= "1--0101-000" else 
                 '0' when Opcode  = "11111000010" else
                 '0' when Opcode  = "11111000000" else
                 '0' when Opcode ?= "1011010----" else
                 '1' when Opcode ?= "000101-----" else -- when branch
                 '0' when Opcode ?= "1--100--00-" else
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR ;
                 '0';

     ALUOp(1) <= '1' when Opcode ?= "1--0101-000" else -- R Format 1--0101-000 -- lsr 11010011010
                 '0' when Opcode  = "11111000010" else -- LDUR     11111000010
                 '0' when Opcode  = "11111000000" else -- STUR     11111000000
                 '0' when Opcode ?= "1011010----" else -- CBZ      1011010----
                 '-' when Opcode ?= "000101-----" else -- B        000101-----
                 '1' when Opcode ?= "1--100--00-" else -- immediate
                 '1' when Opcode ?= "1101001101-" else -- LSL/LSR 
                 '-'; 
     
     ALUOp(0) <= '0' when Opcode ?= "1--0101-000" else -- R Format 1--0101-000
                 '0' when Opcode  = "11111000010" else -- LDUR     11111000010
                 '0' when Opcode  = "11111000000" else -- STUR     11111000000
                 '1' when Opcode ?= "1011010----" else -- CBZ      1011010----
                 '-' when Opcode ?= "000101-----" else -- B        000101-----
                 '0' when Opcode ?= "1--100--00-" else -- immediate
                 '0' when Opcode ?= "1101001101-" else -- LSL/LSR 
                 '0';
         
 
 end Behavioral;