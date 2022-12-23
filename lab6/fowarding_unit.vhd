
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is 
port (

    Rn : in std_logic_vector(4 downto 0);
    Rm : in std_logic_vector(4 downto 0);
    ExMemRegRd : in std_logic_vector (4 downto 0);
    exmem_regwrite : in std_logic;
    memwb_regwrite : in std_logic; 
    MemWBRegRd : in std_logic_vector (4 downto 0);
    ForwardA : out std_logic_vector (1 downto 0);
    ForwardB : out std_logic_vector (1 downto 0)

);
end forwarding_unit;

architecture bev1 of forwarding_unit is 

begin 
process (all)
begin 
    if (memwb_regwrite = '1' and (memwbregrd /= "11111") 
    and not (exmem_regwrite = '1' and ( exmemregrd /= "11111")
    and (exmemregrd = rn))
    and (memwbregrd = rn)) then 
    forwarda <= "01"; -- forwarding from wb to ex
    elsif (exmem_regwrite = '1'
    and (exmemregrd /= "11111")
    and (exmemregrd = Rn)) then 
        ForwardA <= "10"; -- forwarding from mem to ex

    else forwarda <= "00";
    end if;

    if (memwb_regwrite = '1' and (memwbregrd /= "11111") 
    and not (exmem_regwrite = '1' and ( exmemregrd /= "11111")
    and (exmemregrd = rm))
    and (memwbregrd = rm)) then 
    forwardb <= "01"; -- 

    elsif (exmem_regwrite = '1'
    and (exmemregrd /= "11111")
    and (exmemregrd = Rm)) then
        ForwardB <= "10";

    else 
        forwardb<="00";
    end if;

end process;
end;