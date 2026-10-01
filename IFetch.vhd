

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity IFetch is

 Port ( clk : in STD_LOGIC;
         en : in STD_LOGIC;
         rst : in STD_LOGIC;
         branch_addr : in STD_LOGIC_VECTOR (31 downto 0);
         jmp_addr : in STD_LOGIC_VECTOR (31 downto 0);
         jump : in STD_LOGIC;
         PCSrc : in STD_LOGIC;
         
         current_instr : out STD_LOGIC_VECTOR (31 downto 0);
         next_instr_addr : out STD_LOGIC_VECTOR (31 downto 0)
         );

end IFetch;



architecture Behavioral of IFetch is

signal pc_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal sum_out : STD_LOGIC_VECTOR (31 downto 0);
signal mux1_out : STD_LOGIC_VECTOR (31 downto 0);
signal mux2_out : STD_LOGIC_VECTOR (31 downto 0);


--in memoria ROM punem instructiunile pe care le impelemteaza programul nostru
type mem_type is array(0 to 63) of std_logic_vector(31 downto 0);

signal mem: mem_type:=  (

--se pune in registrul 1 valoarea lui N
B"100011_00000_00001_0000000000000100", --Lw $1, 4($0)      #8C010004

--se initializeaza registrele 2,3,4 cu valoarea 0
--2 folosit drept iterator (i)
--3 folosit pentru a retine pozitia in memorie
--4 folosit pt a numara cate elemente sunt pozitive si impare (contor)


B"000000_00000_00000_00010_00000_100000", --Add $2, $0, $0  #00001020
B"000000_00000_00000_00011_00000_100000", --Add $3, $0, $0  #00001820
B"000000_00000_00000_00100_00000_100000", --Add $4, $0, $0  #00002020

B"000100_00001_00010_0000000000011110", --Beq $1, $2, 30    #1022000E

B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 

B"100011_00011_00101_0000000000001000", --Lw $5, 8($3)      #8C650008

B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 

B"000111_00101_00000_0000000000000111", --Bgtz $5, 7        #1CA00003

B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 

B"001000_00010_00010_0000000000000001", --Addi $2, $2, 1    #20420001
B"001000_00011_00011_0000000000000100", --Addi $3, $3, 4    #20630004
B"000010_00000000000000000000000100", --J 4                 #08000004

B"000000_00000_00000_00000_00000_000000", --NoOp 

B"001100_00101_00110_0000000000000001", --Andi $6, $5, 1    #30A60001

B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 

B"000101_00110_00000_0000000000000111", --Bne $6, $0, 7     #14C00002

B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 
B"000000_00000_00000_00000_00000_000000", --NoOp 

B"001000_00010_00010_0000000000000001", --Addi $2, $2, 1    #20420001
B"001000_00011_00011_0000000000000100", --Addi $3, $3, 4    #20630004
B"000010_00000000000000000000000100", --J 4                 #08000004

B"000000_00000_00000_00000_00000_000000", --NoOp 

B"001000_00100_00100_0000000000000001", --Addi $4, $4, 1    #20840001

B"001000_00010_00010_0000000000000001", --Addi $2, $2, 1    #20420001
B"001000_00011_00011_0000000000000100", --Addi $3, $3, 4    #20630004
B"000010_00000000000000000000000100", --J 4                 #08000004

B"000000_00000_00000_00000_00000_000000", --NoOp 

--se scrie rezultatul la adresa 0
B"101011_00000_00100_0000000000000000", --Sw $4, 0($0)      #AC040000
others => X"00000000");


begin

 -- PC
    process(clk, en, rst)
    begin
        if rst = '1' then
            pc_out <= x"00000000";
        else
            if rising_edge(clk) then
                if en = '1' then
                    pc_out <= mux2_out;
                end if;
            end if;
        end if;
    end process;
    
    -- sumator 
    sum_out <= pc_out + 4;
    
    -- memoria de instructiuni
    current_instr <= mem(conv_integer(pc_out(6 downto 2)));
    
    next_instr_addr <= sum_out;
    
    -- mux1
    mux1_out <= sum_out when PCSrc = '0' else branch_addr;
    
    -- mux2
    mux2_out <= mux1_out when jump = '0' else jmp_addr;
    

end Behavioral;
