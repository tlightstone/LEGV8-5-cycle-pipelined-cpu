-- IF/ID register 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity if_id_reg is
port(PC_Address_in   : in  STD_LOGIC_VECTOR (63 downto 0); 
     Instruction_in  : in  STD_LOGIC_VECTOR (31 downto 0); 

     clock            :in std_logic;
     ifid_write     : in std_logic;

     flush            : in std_logic;

     PC_Address_out      : out STD_LOGIC_VECTOR (63 downto 0);
     instruction_out      : out STD_LOGIC_VECTOR (31 downto 0)
);
end if_id_reg;

architecture behaveioral of if_id_reg is
type reg is array(0 to 2) of STD_LOGIC_VECTOR(31 downto 0);
signal regFile:reg;

-- Handy constants to index into specific regsiters
constant x0:integer:=0;
constant x1:integer:=1;
constant x2:integer:=2;

begin

   process(all)
        variable pc_add_0, pc_add_1, instruction:integer;
        variable first:boolean:=true;
        begin

            if rising_edge(clock) and ifid_write = '1' then
                PC_Address_out(63 downto 32) <= regFile(x2);
                PC_Address_out(31 downto 0) <= regFile(x1);
                instruction_out(31 downto 0) <= regFile(x0);
            end if;
            

   
   end process;

      regFile(x2) <= PC_Address_in (63 downto 32) when flush /= '1' else 
                     (others => '0');
      regFile(x1) <= PC_Address_in (31 downto 0)  when flush /= '1' else 
                     (others => '0');
      regFile(x0) <= instruction_in(31 downto 0)  when flush /= '1' else 
                     (others => '0');

end behaveioral;
