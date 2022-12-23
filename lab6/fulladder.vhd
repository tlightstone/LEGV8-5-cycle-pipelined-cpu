library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity full_adder is
-- Defining the port. Declaring input and outputs of the system
    port(a, b, cin: in std_logic;
         s, cout: out std_logic
         );
end full_adder;
 
architecture Behavioral of full_adder is
-- Defining our signals
    signal p, g: std_logic;
begin -- Logic of the full adder referring to a logic diagram
    p <= a xor b;
    g <= a and b;
    s <= p xor cin;
    cout <= g or (p and cin);
end Behavioral;