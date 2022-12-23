library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.13 in the textbook.
-- Check table on page2 of Green Card.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
--  To ensure proper functionality, you must implement the "don't-care" values in the funct field,
-- for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;


architecture Behavioral of ALUControl is
    begin
        Operation <=  "0010" when ALUOp = "00" else -- add
                     -- setting a new operation for when it is CBNZ
                     "1110" when (ALUop = "01" and Opcode(10 downto 3) = "10110101") else
                    
                     "0111" when ALUOp = "01" else -- pass input b
                     "0010" when ALUOp = "10" and 
				(Opcode = "10001011000" or Opcode(10 downto 1) = "1001000100") else -- addition
                     "0110" when ALUOp = "10" and 
				(Opcode = "11001011000" or Opcode(10 downto 1) = "1101000100") else -- subtraction
                     "0000" when ALUOp = "10" and 
				(Opcode = "10001010000" or Opcode(10 downto 1) = "1001001000")else -- and
                     "0001" when ALUOp = "10" and 
				(Opcode = "10101010000" or Opcode(10 downto 1) = "1011001000")else -- or
                -- for lab3 we implement lsl and lsr and we have the freedom
                -- to choose the op codes for those commands 
                -- I collaborated with Henry Ammirato to choose the op codes :) 
                -- LSL opcode = 1010
                -- LSR opcode = 1001
                "1010" when (ALUop = "10" and  Opcode = "11010011011") else --LSL
                "1001" when (ALUop = "10" and  Opcode = "11010011010") else --LSR

                     "----"; 


end Behavioral;
