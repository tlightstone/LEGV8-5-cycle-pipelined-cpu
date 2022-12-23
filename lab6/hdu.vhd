-- hazard detection unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdu is 
port (
    idex_rd : in std_logic_vector(4 downto 0);
    instruction : in std_logic_vector (31 downto 0);
    idex_memread : in std_logic;

    pcwrite : out std_logic;
    muxselect : out std_logic;
    ifd_write : out std_logic

);
end hdu;

architecture bev1 of hdu is 

signal ifidregrn1 : std_logic_vector(4 downto 0);
signal ifidregrm2 : std_logic_vector (4 downto 0);
signal opcode : std_logic_vector (10 downto 0);

begin 

    ifidregrn1 <= instruction(9 downto 5); -- part of the instrution
    ifidregrm2 <= instruction (20 downto 16); -- part of the instruction
    opcode <= instruction(31 downto 21);

process (all)
begin 

    -- no stalling
    pcwrite <= '1';
    muxselect <= '1';
    ifd_write <= '1';


if (idex_memread = '1' and (( idex_rd = ifidregrn1 ) 
or (idex_rd = ifidregrm2))) then 
-- stall the pipeline
    if opcode ?= "1--0101-000" then 
        pcwrite <= '0';
        muxselect <= '0';
        ifd_write <= '0';
    end if;
end if;

end process;
end;