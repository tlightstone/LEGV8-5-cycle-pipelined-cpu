


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PipelinedCPU2_tb is

end PipelinedCPU2_tb;

architecture Behavioral of PipelinedCPU2_tb is

component PipelinedCPU2 
    port(
        clk :in std_logic;
        rst :in std_logic;
        --Probe ports used for testing
        DEBUG_IF_FLUSH : out std_logic;
        DEBUG_REG_EQUAL : out std_logic;
        -- Forwarding control signals
        DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
        DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
        --The current address (AddressOut from the PC)
        DEBUG_PC : out std_logic_vector(63 downto 0);
        --Value of PC.write_enable
        DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
        --The current instruction (Instruction output of IMEM)
        DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
        --DEBUG ports from other components
        DEBUG_TMP_REGS : out std_logic_vector(64*4 - 1 downto 0);
        DEBUG_SAVED_REGS : out std_logic_vector(64*4 - 1 downto 0);
        DEBUG_MEM_CONTENTS : out std_logic_vector(64*4 - 1 downto 0)
    );
    end component;

signal clk : STD_LOGIC;
signal rst : STD_LOGIC;
signal DEBUG_FORWARDA : std_logic_vector(1 downto 0):= (others =>'0');
signal DEBUG_FORWARDB : std_logic_vector(1 downto 0):= (others =>'0');

signal DEBUG_PC : STD_LOGIC_VECTOR(63 downto 0):= (others =>'0');
signal DEBUG_PC_WRITE_ENABLE : STD_LOGIC := '0';
 
signal DEBUG_INSTRUCTION :  STD_LOGIC_VECTOR(31 downto 0):= (others =>'0');

signal DEBUG_TMP_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0):= (others =>'0');
signal DEBUG_SAVED_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0):= (others =>'0');
signal DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(64*4 - 1 downto 0):= (others =>'0');


signal DEBUG_IF_FLUSH : std_logic := '0';
signal DEBUG_REG_EQUAL : std_logic := '0';
-- Forwarding control signals
begin

uut : PipelinedCPU2 port map (
clk, rst, debug_if_flush, debug_reg_equal, debug_forwardA, debug_forwardb, DEBUG_PC, debug_pc_write_enable, DEBUG_INSTRUCTION, DEBUG_TMP_REGS, DEBUG_SAVED_REGS, DEBUG_MEM_CONTENTS);

stim_proc : process 
begin
rst <= '1';
wait for 5 ns;
rst <= '0';
wait;
end process;

end;