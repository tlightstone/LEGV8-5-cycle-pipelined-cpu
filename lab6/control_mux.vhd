
library ieee;
use ieee.std_logic_1164.all;

entity control_mux is -- Two by one mux with 32 bit inputs/outputs
port(
    cpu_control    : in STD_LOGIC_VECTOR(8 downto 0); 
    in1    : in STD_LOGIC_vector(8 downto 0); 
    sel    : in STD_LOGIC; -- selects in0 or in1
    output : out STD_LOGIC_VECTOR(8 downto 0)
);
end control_mux;

architecture Behavioral of control_mux is
    
    begin
        -- in1 should just be a vector of 0s for the purpose of stalling
        output <= in1 when (sel = '0' or sel = 'U') else cpu_control;
    end Behavioral;