-- branch flush detection unit 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bfdu is

    port(

         RD2       : in std_logic_vector (63 downto 0);
         opcode    : in std_logic_vector (10 downto 0);

         flush     : out std_logic
    );


    end bfdu;
    
    architecture Behavioral of bfdu is

        signal equalzero : std_logic; 
        signal condB     : std_logic;
        signal ubranch   : std_logic;
    
         begin
            equalzero <= '1' when rd2 = x"0000000000000000" else '0';
            condB     <= '1' when opcode ?= "1011010----"   else '0';
            ubranch   <= '1' when opcode ?= "000101-----"   else '0';


            flush     <= '1' when (equalzero = '1' and condB = '1') 
                                   or ubranch = '1' else 
                         '0';  
    
    end Behavioral; 
    