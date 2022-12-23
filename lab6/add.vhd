library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ADD is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
port(
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0)
);
end ADD;

architecture Behavioral of ADD is

     component RCA is 
     port(
     a,b    : in  STD_LOGIC_VECTOR(63 downto 0);
     cin    : in  STD_LOGIC;
     s      : out STD_LOGIC_vector(63 downto 0);
     cout : out STD_LOGIC;
     vout : out std_logic; -- Overflow bit
     z    : out std_logic -- Zero bit 
);
     end component;

     signal cin,cout : std_logic;

     begin
          RCAI: RCA port map ( a=>in0, b=>in1, cin=>'0',s=>output);

          
     

end Behavioral; 
