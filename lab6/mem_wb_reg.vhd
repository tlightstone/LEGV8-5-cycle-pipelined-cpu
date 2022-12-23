

--  register 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mem_wb_reg is

port(   
    WB : in std_logic_vector (1 downto 0);
    RD : in std_logic_vector (63 downto 0);
    alu_result : in std_logic_vector (63 downto 0);
    WR : in std_logic_vector(4 downto 0);

    clock : in std_logic;

    regwrite : out std_logic;
    memtoreg : out std_logic;
    RD_out   : out std_logic_vector (63 downto 0);
    alu_result_out : out std_logic_vector (63 downto 0);
    WR_out   : out std_logic_vector (4 downto 0)

);
end mem_wb_reg;

architecture behaveioral of mem_wb_reg is

signal reg_bits : std_logic_vector (134 downto 0);

begin

    reg_bits(0) <= WB(0); -- regwrite
    reg_bits(1) <= WB(1); -- memtoreg
    reg_bits(65 downto 2) <= RD;
    reg_bits(129 downto 66) <= alu_result;
    reg_bits(134 downto 130) <= WR;



   process(all)

        variable first:boolean:=true;
        begin
            -- if (first) then
            --     reg_bits <= (others => '0');
            --     first := false;
            -- end if;
            
            if rising_edge(clock)then
                regwrite <= reg_bits(0) ;-- regwrite
                memtoreg <= reg_bits(1) ;-- memtoreg
                RD_out <= reg_bits(65 downto 2);
                alu_result_out <= reg_bits(129 downto 66);
                WR_out <= reg_bits(134 downto 130);
            end if;
            

   
   end process;

end behaveioral;

