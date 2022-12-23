--  register 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity id_ex_reg is
port(   -- cpu controls
        CBranch  : in STD_LOGIC;  --conditional
        MemRead  : in STD_LOGIC;
        MemtoReg : in STD_LOGIC;
        MemWrite : in STD_LOGIC;
        ALUSrc   : in STD_LOGIC;
        RegWrite : in STD_LOGIC;
        UBranch  : in STD_LOGIC; -- This is unconditional
        ALUOp    : in STD_LOGIC_VECTOR(1 downto 0);

        PC_Address_in   : in  STD_LOGIC_VECTOR (63 downto 0); 

        RD1      : in STD_LOGIC_VECTOR (63 downto 0); 
        RD2      : in STD_LOGIC_VECTOR (63 downto 0); 

        signext  : in STD_LOGIC_VECTOR (63 downto 0); 
        opcode   : in STD_LOGIC_VECTOR (10 downto 0); 
        WR       : in STD_LOGIC_VECTOR (4 downto 0);
        
        -- new for lab5
        rn       : in std_logic_vector (4 downto 0);
        rm       : in std_logic_vector (4 downto 0);

        -- end 


     clock            :in std_logic;

     

     WB      : out STD_LOGIC_VECTOR (1 downto 0);
     M       : out std_logic_vector (3 downto 0);
     aluop_out      : out std_logic_vector (1 downto 0);
     ALUsrc_out     : out std_logic;

     PC_Address_out      : out STD_LOGIC_VECTOR (63 downto 0);
     RD1_out             : out STD_LOGIC_VECTOR (63 downto 0); 
     RD2_out             : out STD_LOGIC_VECTOR (63 downto 0); 
     signext_out         : out STD_LOGIC_VECTOR (63 downto 0); 

     opcode_out   : out STD_LOGIC_VECTOR (10 downto 0); 
     WR_out       : out STD_LOGIC_VECTOR (4 downto 0);
     rn_out       : out std_logic_vector (4 downto 0);
     rm_out       : out std_logic_vector (4 downto 0)

);
end id_ex_reg;

architecture behaveioral of id_ex_reg is

signal reg_bits : std_logic_vector (290 downto 0);




begin

    reg_bits(0) <= CBranch ;
    reg_bits(1) <= MemRead ;
    reg_bits(2) <= MemtoReg;
    reg_bits(3) <= MemWrite;
    reg_bits(4) <= ALUSrc  ;
    reg_bits(5) <= RegWrite;
    reg_bits(6) <= UBranch ;
    reg_bits(8 downto 7) <= ALUOp   ;

    reg_bits(72 downto 9) <= Pc_address_in;  
    reg_bits(136 downto 73) <= RD1;        
    reg_bits(200 downto 137) <= RD2;      
    reg_bits(264 downto 201) <= signext;   
    reg_bits(275 downto 265) <= opcode;     
    reg_bits(280 downto 276) <= WR;    
    
    reg_bits(285 downto 281) <= rn;
    reg_bits(290 downto 286) <= rm;


   process(all)

        variable first:boolean:=true;
        begin
            -- if (first) then
            --     reg_bits <= (others => '0');
            --     first := false;
            -- end if;
            
            if rising_edge(clock) then
                WB <= reg_bits(2) & reg_bits(5); --reg_bits(2) <= MemtoReg; reg_bits(5) <= RegWrite;
                M <= reg_bits(6) & reg_bits(3) & reg_bits(1) & reg_bits(0);-- (6) ubranch, (0) cbranch, (1) mem_read, (3) mem write 
                aluop_out     <= reg_bits(8 downto 7);
                ALUsrc_out    <= reg_bits(4);
                PC_Address_out<= reg_bits(72 downto 9);
                RD1_out       <= reg_bits(136 downto 73); 
                RD2_out       <= reg_bits(200 downto 137);
                signext_out  <=  reg_bits(264 downto 201);
                opcode_out   <=  reg_bits(275 downto 265);
                WR_out       <=  reg_bits(280 downto 276);
                rn_out       <=  reg_bits(285 downto 281);
                rm_out       <=  reg_bits (290 downto 286);
            end if;
            

   
   end process;

end behaveioral;

