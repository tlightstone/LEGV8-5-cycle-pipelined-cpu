library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity RCA is
-- Ripple carry adder and subtractor
port(
     a,b    : in  STD_LOGIC_VECTOR(63 downto 0);
     cin    : in  STD_LOGIC;
     s      : out STD_LOGIC_vector(63 downto 0);
     cout : out STD_LOGIC;
     vout : out std_logic; -- Overflow bit
     z    : out std_logic -- Zero bit 
);
end RCA;

architecture Behavioral of RCA is

     component full_adder is 

     port (a,b,cin: in std_logic;
           s,cout : out std_logic);
     end component;

     signal c : std_logic_vector(64 downto 0);
     signal temp: std_logic_vector(63 downto 0);
     signal sum : std_logic_vector(63 downto 0);

     begin

     c(0) <= cin;
     cout <= c(64);
     FA: for i in 0 to 63 generate
          temp(i) <= b(i) xor cin; -- for subtraction
          FAI : full_adder port map ( a(i), temp(i), c(i), sum(i), c(i+1));
          s(i) <= sum(i);
     end generate FA;
     z <= '1' when sum = x"0000000000000000" else '0'; -- zero flag
     vout <= c(63) xor c(64); 

          
     

end Behavioral; 
