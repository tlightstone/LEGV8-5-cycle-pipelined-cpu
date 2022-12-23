library ieee;
use ieee.std_logic_1164.all;


entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end SignExtend;



architecture Behavioral of SignExtend is
     begin
          -- y(31 downto 0 ) <= x;
          -- y(63 downto 32) <= x"00000000" when x(31) = '0' else 
          --                    x"FFFFFFFF" when x(31) = '1';

          -- Core Instruction Formats
          -- R opcode(31 downto 21) rm(20 downto 16) shamt(15 downto 10)
          -- I opcode(31 downto 22) aluI(21 downto 10)
          -- D opcode (31 downto 21) DTaddr(20 downto 12)
          -- B opcode (31 downto 26) br(25 downto 0)
          -- cb opcode(31 downto 24) addres(23 downto 5)


          process(x)
          begin
               if   x(31 downto 21) ?= "1----01-0--" then -- R opcode
                    y(5 downto 0) <= x(15 downto 10);
                    y(63 downto 6) <= (others => x(15));
                      
               elsif x(31 downto 21) ?= "1--100--00-" then -- I opcode
                    y(11 downto 0) <= x(21 downto 10);
                    y(63 downto 12) <= (others => x(21));
               elsif x(31 downto 21) ?= "10110100---" then -- CBZ opcode
                    y(18 downto 0) <= x(23 downto 5);
                    y(63 downto 19) <= (others => x(23));  
               elsif x(31 downto 21) ?= "10110101---" then -- CBNZ opcode
                    y(18 downto 0) <= x(23 downto 5);
                    y(63 downto 19) <= (others => x(23));     

               elsif x(31 downto 21)?= "111110000-0" then -- D opcode
                    y(8 downto 0) <= x(20 downto 12);
                    y(63 downto 9) <= (others => x(20));

               elsif x(31 downto 26) ?= "000101" then -- Branch
                    y(25 downto 0) <= x(25 downto 0);
                    y(63 downto 26) <= (others => x(25));
               else -- others case
                    y(63 downto 0) <= (others => '-');
               end if; 

	end process;

                    




     end Behavioral;