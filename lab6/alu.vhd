library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
--    as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the Green Card pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is

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

    component ADD is 
    port(
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0)
);
    end component;

    signal s : STD_LOGIC_vector(63 downto 0);
    signal cin,cout,vout,z : std_logic;
    signal result_t : std_logic_vector(63 downto 0);
    signal sum : STD_Logic_vector(63 downto 0);

    begin
        -- TODO: Use adder to do the addition and then calculate the overflow flags from that 
        RCAI: RCA port map ( a=>in0, b=>in1, cin=>cin,s=>s, cout=>cout,vout=>vout,z=>z);
        ADDI : ADD port map (in0=>in0,in1=>in1,output=>sum);


            result_t <= (in0 and in1) when operation = "0000" else -- AND
                         (in0 or in1) when operation = "0001" else   -- OR
                         in0 nor in1  when operation = "1100" else  -- nor 
                         in1          when operation = "0111" or operation = "1110" else  -- pass input in1
                         sum          when operation = "0010" else -- ADD
                         s            when operation = "0110" else -- SUB 
                         -- for lab3 we implement lsl and lsr and we have the freedom
                         -- to choose the op code
                        -- I collaborated with Henry Ammirato to choose the op codes :) 
                        -- LSL opcode = 1010
                        -- LSR opcode = 1001
                        std_logic_vector(shift_right(unsigned(in0), to_integer(unsigned(in1)))) when operation = "1001" else  -- LSR
                        std_logic_vector(shift_left(unsigned(in0), to_integer(unsigned(in1))))  when operation = "1010" else  -- LSL
                         X"----------------"; -- when others 
            
            cin <= '1' when operation = "0110" else 
                   '0';         
            
            overflow <= '1' when ((operation = "0010") and ((in0(63) = '1' and in1(63) = '1' and result_t(63) = '0') or 
                                                            (in0(63) = '0' and in1(63) = '0' and result_t(63) = '1')))else
                        vout when operation = "0110"  else 
                        '0';
    -- set zero flag when result is zero or when cbnz operation so that the mux selects the correct operation
            -- zero <= '0' when result_t = x"0000000000000000" and operation = "1110" else 
            -- '1' when operation = "1110" else 
            -- '1' when result_t = x"0000000000000000" else 
            -- '0';

             zero <= '1' when result_t = x"0000000000000000" else 
                     '0';
            result <= result_t;

    
end Behavioral;
