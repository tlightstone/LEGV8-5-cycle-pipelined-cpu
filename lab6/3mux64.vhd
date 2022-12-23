library ieee;
use ieee.std_logic_1164.all;

entity MUX3_64 is -- Two by one mux with 32 bit inputs/outputs
port(
    in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
    in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
    in2    : in STD_LOGIC_VECTOR(63 downto 0);
    sel    : in STD_LOGIC_vector(1 downto 0); -- selects in0 or in1
    output : out STD_LOGIC_VECTOR(63 downto 0)
);
end MUX3_64;

architecture Behavioral of MUX3_64 is
    begin
        output <= in0 when (sel = "00" or sel = "UU") else 
                  in1 when (sel = "01")               else 
                  in2 when (sel = "10")               else 
                  in0;
    end Behavioral;