library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PipelinedCPU2 is
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
end PipelinedCPU2;

architecture Behavioral of PipelinedCPU2 is

     component CPUControl is 
     
     port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
          Reg2Loc  : out STD_LOGIC;
          CBranch  : out STD_LOGIC;  --conditional
          MemRead  : out STD_LOGIC;
          MemtoReg : out STD_LOGIC;
          MemWrite : out STD_LOGIC;
          ALUSrc   : out STD_LOGIC;
          RegWrite : out STD_LOGIC;
          UBranch  : out STD_LOGIC; -- This is unconditional
          ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
     );
     end component;
     
     COMPONENT ALUCONTROL
         port(
             ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
             Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
             Operation : out STD_LOGIC_VECTOR(3 downto 0)
         );
     END COMPONENT;
     
     COMPONENT ALU
     port(
         in0       : in     STD_LOGIC_VECTOR(63 downto 0);
         in1       : in     STD_LOGIC_VECTOR(63 downto 0);
         operation : in     STD_LOGIC_VECTOR(3 downto 0);
         result    : buffer STD_LOGIC_VECTOR(63 downto 0);
         zero      : buffer STD_LOGIC;
         overflow  : buffer STD_LOGIC
        );
     END COMPONENT;
     
         COMPONENT MUX5
         port(
         in0    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
         in1    : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
         sel    : in STD_LOGIC; -- selects in0 or in1
         output : out STD_LOGIC_VECTOR(4 downto 0)
         );
         end COMPONENT;
     
     
         COMPONENT MUX64
         port(
         in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
         in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
         sel    : in STD_LOGIC; -- selects in0 or in1
         output : out STD_LOGIC_VECTOR(63 downto 0)
         );
         end COMPONENT;
     
         COMPONENT pc
         port(
          clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
          write_enable : in  STD_LOGIC; -- Only write if '1'
          rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
          AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
          AddressOut   : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
         );
         end COMPONENT;
     
     component registers is 
         port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
         RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
         WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
         WD       : in  STD_LOGIC_VECTOR (63 downto 0);
         RegWrite : in  STD_LOGIC;
         Clock    : in  STD_LOGIC;
         RD1      : out STD_LOGIC_VECTOR (63 downto 0);
         RD2      : out STD_LOGIC_VECTOR (63 downto 0);
         --Probe ports used for testing.
         -- Notice the width of the port means that you are 
         --      reading only part of the register file. 
         -- This is only for debugging
         -- You are debugging a sebset of registers here
         -- Temp registers: $X9 & $X10 & X11 & X12 
         -- 4 refers to number of registers you are debugging
         DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
         -- Saved Registers X19 & $X20 & X21 & X22 
         DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
         );
     end component;
     
         COMPONENT shiftleft2
         port(
          x : in  STD_LOGIC_VECTOR(63 downto 0);
          y : out STD_LOGIC_VECTOR(63 downto 0) -- x << 2
         );
         end COMPONENT;
     
         COMPONENT SIGNEXTEND
         port(
          x : in  STD_LOGIC_VECTOR(31 downto 0);
          y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
         );
         end COMPONENT;
     
     component imem
     port(
          Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
          ReadData : out STD_LOGIC_VECTOR(31 downto 0)
     );
     end component;
     
     COMPONENT DMEM
         port(
             WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
             Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
             MemRead            : in  STD_LOGIC; -- Indicates a read operation
             MemWrite           : in  STD_LOGIC; -- Indicates a write operation
             Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
             ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
             --Probe ports used for testing
             DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
         );
     END COMPONENT;
     
     component if_id_reg 
          port(PC_Address_in   : in  STD_LOGIC_VECTOR (63 downto 0); 
               Instruction_in  : in  STD_LOGIC_VECTOR (31 downto 0); 
          
               clock            :in std_logic;
               ifid_write        : in std_logic;
               flush            : in std_logic;
          
               PC_Address_out      : out STD_LOGIC_VECTOR (63 downto 0);
               instruction_out      : out STD_LOGIC_VECTOR (31 downto 0)
          );
          end component;
     component id_ex_reg 
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
          end component;
     component ex_mem_reg 
     
          port(   
               WB : in std_logic_vector (1 downto 0);
               M : in std_logic_vector(3 downto 0);
               add_result : in std_logic_vector( 63 downto 0);
               zero       : in std_logic;
               alu_result : in std_logic_vector(63 downto 0);
               RD2        : in std_logic_vector(63 downto 0);
               WR         : in std_logic_vector(4 downto 0);
          
               clock      : in std_logic;
          
               WB_out     : out std_logic_vector (1 downto 0);
               Cbranch    : out std_logic;
               MemRead    : out std_logic;
               Memwrite   : out std_logic;
               ubranch    : out std_logic; 
               add_out    : out std_logic_vector(63 downto 0);
               zero_out       : out std_logic;
               alu_result_out : out std_logic_vector (63 downto 0);
               RD2_out    : out std_logic_vector (63 downto 0);
               WR_out     : out std_logic_vector (4 downto 0)
          );
          end component;
     
     component mem_wb_reg 
     
          port(   
               WB : in std_logic_vector (1 downto 0);
               RD : in std_logic_vector (63 downto 0);
               alu_result : in std_logic_vector (63 downto 0);
               WR : in std_logic_vector(4 downto 0);
          
               clock : in std_logic;
          
               regwrite : out std_logic;
               memtoreg : out std_logic;
               RD_out   : out std_logic_vector (63 downto 0);
               alu_result_out : out std_logic_vector (63 downto 0);
               WR_out   : out std_logic_vector (4 downto 0)
          
          );
          end component;
     
     
     component mux3_64 
          port(
             in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
             in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
             in2    : in STD_LOGIC_VECTOR(63 downto 0);
             sel    : in STD_LOGIC_vector(1 downto 0); -- selects in0 or in1
             output : out STD_LOGIC_VECTOR(63 downto 0)
         );
         end component;
     
     component control_mux -- Two by one mux with 32 bit inputs/outputs
     port(
         cpu_control    : in STD_LOGIC_VECTOR(8 downto 0); 
         in1    : in STD_LOGIC_vector(8 downto 0); -- sel == 1
         sel    : in STD_LOGIC; -- selects in0 or in1
         output : out STD_LOGIC_VECTOR(8 downto 0)
     );
     end component;
     
     component hdu 
     port (
         idex_rd : in std_logic_vector(4 downto 0);
         instruction : in std_logic_vector (31 downto 0);
         idex_memread : in std_logic;
     
         pcwrite : out std_logic;
         muxselect : out std_logic;
         ifd_write : out std_logic
     
     );
     end component;
     
     component forwarding_unit  
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
     end component;


     -- new for lab 6
     component bfdu
     port(

          RD2       : in std_logic_vector (63 downto 0);
          opcode    : in std_logic_vector (10 downto 0);
 
          flush     : out std_logic
     );
     end component;
 
     
     
     
     
          -- *^*^*^*^*^*^*^*^*^*^*^* port mapping ^*^*^*^*^*^*^*^*^*^*^*^*^* -- 
     -- left of if/id
     
     -- pc mux inputs -- 
     signal PCSrc : std_logic;
     signal add_mux : std_logic_vector(63 downto 0);
     signal ex_mem_mux : std_logic_vector(63 downto 0);
     -- pc -- 
     signal mux_pc : std_logic_vector(63 downto 0);
     signal pc_add : std_logic_vector (63 downto 0);
     signal instruction : std_logic_vector(31 downto 0); 
     
     
     -- ************** IF/ID ************** -- 
     signal IDAddress : std_logic_vector(63 downto 0);
     signal instructionID : std_logic_vector (31 downto 0);
     signal ifidWrite : std_logic; -- lab 5
     
     -- registers inputs -- 
     signal mux_reg : std_logic_vector(4 downto 0);
     signal write_register : std_logic_vector (4 downto 0);
     signal write_data : std_logic_vector (63 downto 0);
     
     -- register outputs -- 
     signal RD1 : std_logic_vector(63 downto 0);
     signal RD2 : std_logic_vector(63 downto 0);
     
     signal signextended : std_logic_vector(63 downto 0);
     
     -- cpu control signals -- 
     
     signal Reg2Loc  : STD_LOGIC;
     
     signal CBranch  : STD_LOGIC;  --conditional
     signal MemRead  : STD_LOGIC;
     signal MemtoReg : STD_LOGIC;
     signal MemWrite : STD_LOGIC;
     signal ALUSrc   : STD_LOGIC;
     signal RegWrite : STD_LOGIC;
     signal UBranch  : STD_LOGIC; -- This is unconditional
     signal ALUOp    : STD_LOGIC_VECTOR(1 downto 0);
     
     
     -- *^*^*^**^*^^*^*^*^*^*^* ID/EX *^*^*^*^*^*^*^*^*^* --
     -- from ID/EX -- 
     signal WB_EX : std_logic_vector (1 downto 0);
     signal M_EX : std_logic_vector(3 downto 0);
     signal Aluop_EX : std_logic_vector (1 downto 0);
     signal alusrc_ex :std_logic; 
     signal EXAddress : std_logic_vector(63 downto 0);
     signal EX_shift2 : std_logic_vector(63 downto 0);
     signal rd1_ex    : std_logic_vector(63 downto 0);
     signal RD2_EX : std_logic_vector(63 downto 0);
     signal opcode_EX : std_logic_vector(10 downto 0);
     signal WR_EX : std_logic_vector(4 downto 0);
     
     -- new lab 5
     signal idexrn_out_ex, idexrm_out_ex :std_logic_vector(4 downto 0);
     -- end
     
     
     -- middle EX signals --
     signal shift_add : std_logic_vector(63 downto 0);
     signal mux_alu : std_logic_vector(63 downto 0);
     signal alucontrol1 : std_logic_vector (3 downto 0);
     signal addresult_ex : std_logic_vector(63 downto 0);
     signal zero_ex : std_logic;
     signal aluresult_ex : std_logic_vector(63 downto 0);
     
     -- *^*^*^*^*^*^*^*^*^*^**^^* EX/MEM *^*^*^*^*^*^*^*^^*^*^**
     -- from ex/mem --
     signal WB_mem : std_logic_vector(1 downto 0);
     signal cbranch_mem  :  std_logic;
     signal memread_mem  :  std_logic;
     signal memwrite_mem :  std_logic;
     signal ubranch_mem  : std_logic := '0';
     signal zero_mem     :  std_logic;
     signal address_mem  : std_logic_vector(63 downto 0);
     signal writedata_mem : std_logic_vector(63 downto 0);
     signal wr_mem       : std_logic_vector(4 downto 0);
     -- middle mem signals -- 
     signal readdata_mem :std_logic_vector(63 downto 0);
     
     -- *^*^*^*^*^*^*^*^*^*^*^*^^* MEM/WB *^*^**^*^*^**^*^*
     signal regwrite_wb : std_logic;
     signal memtoreg_wb : std_logic;
     signal readdata_wb : std_logic_vector(63 downto 0);
     signal address_wb  : std_logic_vector(63 downto 0);
     
     
     -- debug signals cant name the same thing
     
     signal DEBUG_TMP_REGS_temp : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     signal DEBUG_SAVED_REGS_temp : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     signal DEBUG_MEM_CONTENTS_temp : STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- lab 5 
     -- hdu signals 
       -- ifidwrite is in ifid stage 
     signal pcwrite : std_logic;
      -- idex mem read is from m_ex 
     signal hdu_mux : std_logic;
     
     -- forwarding unit signals 
     signal forwardA, forwardB : std_logic_vector(1 downto 0);
     
     
     -- control mux
     signal new_control_ID : std_logic_vector(8 downto 0);
     
     -- mux3_64A 
     signal forwardAout : std_logic_vector(63 downto 0);
     
     signal forwardBout : std_logic_vector(63 downto 0);
     
     -- new signal for lab 6
     signal if_flush_pcsrc : std_logic; 

     
     
     
     begin
     
     -- *********** STAGE 1 IF *************--     
     PCMUX: MUX64
          port map(add_mux, addresult_ex, if_flush_pcsrc, mux_pc); -- lab 6
     
     PCI: pc
          port map(clk,pcwrite, rst, mux_pc, pc_add);
     
     -- adder for pc + 4
     ALUIadderadder : ALU
     port map( pc_add, x"0000000000000004", "0010", add_mux, open, open);
     
     imemI: imem
     port map( pc_add, instruction (31 downto 0)); 
     
     if_id : if_id_reg 
     port map( pc_add, instruction(31 downto 0), clk, ifidWrite, if_flush_pcsrc, idaddress, instructionID);
     
     
     -- *********** STAGE 2 IF/ID *************--     
     
     MUX5I: MUX5
         port map( instructionID(20 downto 16), instructionID(4 downto 0), Reg2loc, mux_reg);
     
     CPUcontrolI : CPUControl
          port map (instructionID(31 downto 21), Reg2Loc,CBranch,MemRead,MemtoReg,MemWrite ,ALUSrc,RegWrite,UBranch, ALUOp);
     
     registersI: registers 
          port map(instructionID(9 downto 5), mux_reg, write_register, write_data, regwrite_wb, clk, rd1,rd2,DEBUG_TMP_REGS, DEBUG_SAVED_REGS);
     
     signextednI :  SIGNEXTEND
          port map( instructionID(31 downto 0), signextended);

     -- new lab 6 moving add result alu and shift left into this place
     shiftleftI: shiftleft2
         port map( signextended, shift_add);

     ALUIaddEX : ALU
         port map( idaddress, shift_add, "0010", addresult_ex, open, open);
     
     id_ex : id_ex_reg 
          port map(new_control_ID(8),new_control_ID(7),new_control_ID(6),new_control_ID(5),new_control_ID(4),new_control_ID(3),new_control_ID(2),new_control_ID(1 downto 0),idaddress,rd1,rd2,signextended, instructionid(31 downto 21), instructionid(4 downto 0), instructionid(9 downto 5), instructionid( 20 downto 16), -- new lab 5
                   clk, wb_ex, m_ex, aluop_ex, alusrc_ex, exaddress, rd1_ex, rd2_ex, ex_shift2, opcode_ex,wr_ex, idexrn_out_ex, idexrm_out_ex );
     
     -- *********** STAGE 3 ID/EX *************--  
     
     
     
     MUX64EX: MUX64
         port map( forwardbout, ex_shift2, alusrc_ex, mux_alu);
     
     ALUEX : ALU
         port map( forwardaout, mux_alu, alucontrol1, aluresult_ex, zero_ex, open);
     
     
     ALUControlI : ALUCONTROL
         port map ( aluop_ex, opcode_ex, alucontrol1); 
     
     ex_mem : ex_mem_reg -- before i didnt change forwardbout i had it still rd2 ex from previous lab!!!
          port map( wb_ex, m_ex, addresult_ex, zero_ex, aluresult_ex, forwardbout, wr_ex, clk, 
                wb_mem, cbranch_mem, memread_mem, memwrite_mem, ubranch_mem, ex_mem_mux,
                zero_mem, address_mem, writedata_mem, wr_mem);
     
     -- *********** STAGE 4 EX/MEM *************--  
     
     -- pcsrc <= (cbranch_mem and zero_mem) or ubranch_mem; -- or ubranch_mem must be set to 0
     
     DMEMI: DMEM
         port map( writedata_mem, address_mem, memread_mem, memwrite_mem, clk, readdata_mem, debug_mem_contents);
     
     mem_wb : mem_wb_reg
     port map ( wb_mem, readdata_mem, address_mem, wr_mem, clk, 
               regwrite_wb, memtoreg_wb, readdata_wb, address_wb, write_register);
     
     MUX64wb: MUX64
          port map( address_wb, readdata_wb, memtoreg_wb, write_data);    
     
     -- *********** STAGE 5 MEM/WB *************--  
     
     -- new components for lab 5
     
     -- mux3_64 A and B
     
     mux3_64A: mux3_64 
     port map( RD1_EX, write_data, address_mem, forwarda, 
               forwardAout
     );
     
     
     mux3_64B: mux3_64 
     port map(rd2_ex, write_data ,address_mem, forwardb,
               forwardbout);
     
     
     -- control_mux
     -- CBranch & MemRead & MemtoReg & MemWrite & ALUSrc & RegWrite & UBranch & ALUOp)
     -- ALUOp & UBranch & RegWrite & ALUSrc & MemWrite & MemtoReg & MemRead  CBranch
     controlmuxi: control_mux -- Two by one mux with 32 bit inputs/outputs
     port map(  (CBranch & MemRead & MemtoReg & MemWrite & ALUSrc & RegWrite & UBranch & ALUOp), "000000000", hdu_mux,
                 new_control_ID);
     
     
     -- hdu
     
     hdui : hdu
     port map ( wr_ex, instructionid, m_ex(1), -- m_ex(1) should be memread might want to check later
               pcwrite, hdu_mux, ifidwrite);
     
     
     -- forwarding_unit
     
     fui: forwarding_unit  
     port  map (idexrn_out_ex, idexrm_out_ex, wr_mem, wb_mem(0), regwrite_wb, write_register, 
          forwardA, forwardB);

     bfdui: bfdu
     port map( rd2, instructionid(31 downto 21), if_flush_pcsrc);
     
     
     
     DEBUG_PC <= PC_Add;
          --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION <= instruction;
          --DEBUG ports from other components
     
     DEBUG_FORWARDA <= forwarda;
     DEBUG_FORWARDB <= forwardb;
     
     --Value of PC.write_enable
     DEBUG_PC_WRITE_ENABLE <= pcwrite;


     DEBUG_IF_FLUSH <= if_flush_pcsrc ;
     DEBUG_REG_EQUAL <= '1' when rd2 = x"0000000000000000" else '0';
   
     
     
     
     end Behavioral;