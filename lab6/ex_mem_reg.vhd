
--  register 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ex_mem_reg is

port(   
    WB : in std_logic_vector (1 downto 0);
    M : in std_logic_vector(3 downto 0);
    add_result : in std_logic_vector( 63 downto 0);
    zero       : in std_logic;
    alu_result : in std_logic_vector(63 downto 0);
    RD2        : in std_logic_vector(63 downto 0);
    WR         : in std_logic_vector(4 downto 0);

    clock      : in std_logic;

    WB_out     : out std_logic_vector (1 downto 0);
    Cbranch    : out std_logic;
    MemRead    : out std_logic;
    Memwrite   : out std_logic;
    ubranch    : out std_logic; 
    add_out    : out std_logic_vector(63 downto 0);
    zero_out       : out std_logic;
    alu_result_out : out std_logic_vector (63 downto 0);
    RD2_out    : out std_logic_vector (63 downto 0);
    WR_out     : out std_logic_vector (4 downto 0)
);
end ex_mem_reg;

architecture behaveioral of ex_mem_reg is

signal reg_bits : std_logic_vector (203 downto 0);

begin

    reg_bits(1 downto 0) <= WB;
    reg_bits(2) <= M(0); -- Cbranch 
    reg_bits(3) <= M(1); -- Memread
    reg_bits(4) <= M(2); -- Memwrite
    reg_bits(5) <= M(3); -- Ubranch
    reg_bits(69 downto 6) <= add_result;
    reg_bits (70) <= zero;
    reg_bits(134 downto 71) <= alu_result;
    reg_bits(198 downto 135) <= RD2;
    reg_bits(203 downto 199) <= WR;



   process(all)

        variable first:boolean:=true;
        begin
            -- if (first) then
            --     reg_bits <= (others => '0');
            --     first := false;
            -- end if;
            
            if rising_edge(clock)then
                WB_out <=     reg_bits(1 downto 0) ;
                Cbranch<=     reg_bits(2) ;
                Memread <=    reg_bits(3) ;
                memwrite <=   reg_bits(4) ;
                ubranch <=    reg_bits(5) ;
                add_out <= reg_bits(69 downto 6);
                zero_out <=   reg_bits (70) ;
                alu_result_out <= reg_bits(134 downto 71) ;
                rd2_out <=    reg_bits(198 downto 135);
                wr_out<=      reg_bits(203 downto 199);
            end if;
            

   
   end process;

end behaveioral;

