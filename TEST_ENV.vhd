library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity test_env is
    Port ( 
           clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0)
         );
end test_env;


architecture Behavioral of test_env is

-- declarari de componente


component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;


component IFetch is

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

end component;



component ID is
    port(
        clk: in std_logic;
        en: in std_logic;
        reg_write: in std_logic;
        instr: in std_logic_vector(25 downto 0);
        ext_op: in std_logic;
        wa: in std_logic_vector(4 downto 0);
        wd: in std_logic_vector(31 downto 0);
        
        
        rd1: out std_logic_vector(31 downto 0);
        rd2: out std_logic_vector(31 downto 0);
        ext_imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0);
        rt: out std_logic_vector(4 downto 0);
        rd: out std_logic_vector(4 downto 0)
    
    );   
end component;




component UC is
     Port ( Instr: in std_logic_vector(5 downto 0);
     
            RegDst: out std_logic;
            ExtOp: out std_logic;            
            ALUSrc: out std_logic; 
            Branch: out std_logic; 
            Brne: out std_logic;
            Brgtz: out std_logic;
            Jump: out std_logic;
            ALUOp: out std_logic_vector(1 downto 0);
            MemWrite: out std_logic;
            MemtoReg: out std_logic;
            RegWrite: out std_logic
        );
end component;

component EX is
  Port (
        ALUSrc: in STD_LOGIC;
        ALUOp: in STD_LOGIC_VECTOR (1 downto 0);
        RD1: in STD_LOGIC_VECTOR (31 downto 0);
        RD2: in STD_LOGIC_VECTOR (31 downto 0);
        Ext_Imm: in STD_LOGIC_VECTOR (31 downto 0);
        sa: in STD_LOGIC_VECTOR(4 downto 0);
        func: in STD_LOGIC_VECTOR (5 downto 0);
        
        PCNext: in STD_LOGIC_VECTOR (31 downto 0);
        RegDst: in std_logic;
        rt: in std_logic_vector(4 downto 0);
        rd: in std_logic_vector(4 downto 0);
        
        Zero: out STD_LOGIC;
        Gtz: out STD_LOGIC;
        ALURes: out STD_LOGIC_VECTOR (31 downto 0);
        BranchAddr: out STD_LOGIC_VECTOR (31 downto 0);
        rWA: out std_logic_vector(4 downto 0)
        
   );
end component;


component MEM is
  Port ( 
        clk :       in STD_LOGIC;
        enable :    in STD_LOGIC;
        MemWrite :  in STD_LOGIC;
        Addr :      in STD_LOGIC_VECTOR (31 downto 0);
        w_data :    in STD_LOGIC_VECTOR (31 downto 0);
        
        r_data :    out STD_LOGIC_VECTOR (31 downto 0);
        ALUResult : out STD_LOGIC_VECTOR (31 downto 0)
  );
end component;



--declarare semnale interne
signal Ext_Imm: std_logic_vector(31 downto 0) := (others => '0');


signal enable: std_logic;

signal BranchAddress: std_logic_vector(31 downto 0);
signal JumpAddr: std_logic_vector(31 downto 0);
signal Instruction: std_logic_vector(31 downto 0);
signal PC4: std_logic_vector(31 downto 0);


signal mux2_out, mux1_out: std_logic_vector(31 downto 0);

signal ExtImm: std_logic_vector(31 downto 0);
signal rd1, rd2: std_logic_vector(31 downto 0);
signal func: std_logic_vector(5 downto 0);
signal sa: std_logic_vector(4 downto 0);

signal Jump, PCSrc, ExtOp,RegDst,RegWrite, ALUSrc, Branch, Brne, Brgtz, MemtoReg, MemWrite : std_logic;
signal ALUOp: std_logic_vector(1 downto 0);
signal gtz,zero: std_logic;

signal ALURes1: std_logic_vector(31 downto 0);

signal MemData: std_logic_vector(31 downto 0);
signal ALUResult: std_logic_vector(31 downto 0);


--semnale pentru varianta pipeline

signal rd: std_logic_vector(4 downto 0);
signal rt: std_logic_vector(4 downto 0);
signal en: std_logic;

signal PC4_IF_ID : std_logic_vector(31 downto 0);
signal Instruction_IF_ID: std_logic_vector(31 downto 0);

signal PC4_ID_EX: std_logic_vector(31 downto 0);
signal RD1_ID_EX: std_logic_vector(31 downto 0);
signal RD2_ID_EX: std_logic_vector(31 downto 0);
signal Ext_Imm_ID_EX: std_logic_vector(31 downto 0);
signal func_ID_EX: std_logic_vector(5 downto 0);
signal sa_ID_EX: std_logic_vector(4 downto 0);
signal rt_ID_EX: std_logic_vector(4 downto 0);
signal rd_ID_EX: std_logic_vector(4 downto 0);
signal MemtoReg_ID_EX: std_logic;
signal RegWrite_ID_EX: std_logic;
signal MemWrite_ID_EX: std_logic;
signal Branch_ID_EX: std_logic;
signal Brne_ID_EX: std_logic;
signal Brgtz_ID_EX: std_logic;
signal ALUSrc_ID_EX: std_logic;
signal ALUOp_ID_EX: std_logic_vector(1 downto 0);
signal RegDst_ID_EX: std_logic;

signal rWA: std_logic_vector(4 downto 0);

signal BranchAddress_EX_MEM: std_logic_vector(31 downto 0);
signal Zero_EX_MEM: std_logic;
signal RD2_EX_MEM: std_logic_vector(31 downto 0);
signal ALURes_EX_MEM: std_logic_vector(31 downto 0);
signal RegWrite_EX_MEM: std_logic;
signal MemWrite_EX_MEM: std_logic;
signal MemtoReg_EX_MEM: std_logic;
signal Branch_EX_MEM: std_logic;
signal Brne_EX_MEM: std_logic;
signal Brgtz_EX_MEM: std_logic;
signal wa_EX_MEM: std_logic_vector(4 downto 0);


signal MemData_MEM_WB: std_logic_vector(31 downto 0);
signal ALURes_MEM_WB: std_logic_vector(31 downto 0);
signal MemtoReg_MEM_WB: std_logic;
signal RegWrite_MEM_WB: std_logic;
signal wa_MEM_WB: std_logic_vector(4 downto 0);





begin


MPG_inst: MPG port map(
    enable => enable,
    btn => btn(0),
    clk => clk
    
);



IF_inst: IFetch port map(
    clk => clk,
    en => enable,
    rst => btn(1),
    branch_addr => BranchAddress_EX_MEM,
    jmp_addr => JumpAddr,
    jump => Jump,
    PCSrc => PCSrc,
    
    current_instr => Instruction,
    next_instr_addr => PC4
   
);




ID_inst: ID port map(
    clk => clk,
    en => enable,
    reg_write => RegWrite_MEM_WB,
    instr => Instruction_IF_ID(25 downto 0),
    ext_op => ExtOp,
    wa => wa_MEM_WB,
    wd => mux2_out,
    
    rd1 => rd1,
    rd2 => rd2,
    ext_imm => Ext_Imm,
    func => func,
    sa => sa,
    rt => rt,
    rd => rd
);




UC_inst: UC port map(
    instr => Instruction_IF_ID(31 downto 26),
    
    RegDst => RegDst,
    ExtOp => ExtOp,
    ALUSrc => ALUSrc,
    Branch => Branch,
    Brne => Brne,
    Brgtz => Brgtz,
    Jump => Jump,
    ALUOp => ALUOp,
    MemWrite => MemWrite,
    MemtoReg => MemtoReg,
    RegWrite => RegWrite
    
);

EX_inst: EX port map
(
    ALUSrc => ALUSrc_ID_EX,
    ALUOp => ALUOp_ID_EX,
    RD1 => rd1_ID_EX,
    RD2 => rd2_ID_EX,
    Ext_Imm => Ext_Imm_ID_EX,
    sa => sa_ID_EX,
    func => func_ID_EX,
    PCNext => PC4_ID_EX,
    RegDst => RegDst_ID_EX,
    rt => rt_ID_EX,
    rd => rd_ID_EX,
    
    Zero => Zero,
    Gtz => Brgtz,
    ALURes => ALUResult,
    BranchAddr => BranchAddress,
    rWA => rWA
);



--calcularea PCSrc

PCSrc <= (Brgtz and Brgtz_EX_MEM) or ((not zero_EX_MEM) and Brne_EX_MEM) or (zero_EX_MEM and Branch_EX_MEM);


MEM_inst: MEM port map(
    clk => clk,
    enable => enable,
    MemWrite => MemWrite_EX_MEM,
    Addr => ALURes_EX_MEM,
    w_data => RD2_EX_MEM,
    
    r_data => MemData,
    ALUResult => ALURes1
   
);


with MemtoReg_MEM_WB select
    mux2_out <= MemData_MEM_WB when '1',
          ALURes_MEM_WB when '0',
          (others => 'X') when others;


MUX1: process(sw(7 downto 5))
begin

    case sw(7 downto 5) is
        when "000" => mux1_out <= Instruction;
        when "001" => mux1_out <= PC4;
        when "010" => mux1_out <= rd1_ID_EX;
        when "011" => mux1_out <= rd2_ID_EX;
        when "100" => mux1_out <= Ext_Imm_ID_EX;
        when "101" => mux1_out <= ALUResult; 
        when "110" => mux1_out <= MemData;
        when others => mux1_out <= mux2_out;
        
    end case;
end process;



--calcularea adresei de jump
JumpAddr <= PC4_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";



Pipeline_Registers: process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            --IF/ID       
            PC4_IF_ID <= PC4;
            Instruction_IF_ID <= Instruction;
            
            --ID/EX
            PC4_ID_EX <= PC4_IF_ID;
            RD1_ID_EX <= RD1;
            RD2_ID_EX <= RD2;
            Ext_Imm_ID_EX <= ExtImm;
            sa_ID_EX <= sa;
            func_ID_EX <= func;
            rt_ID_EX <= rt;
            rd_ID_EX <= rd;
            MemtoReg_ID_EX <= MemtoReg;
            RegWrite_ID_EX <= RegWrite;
            MemWrite_ID_EX <= MemWrite;
            Branch_ID_EX <= Branch;
            Brne_ID_EX <= Brne;
            Brgtz_ID_EX <= Brgtz;
            ALUSrc_ID_EX <= ALUSrc;
            ALUOp_ID_EX <= ALUOp;
            RegDst_ID_EX <= RegDst;
            
            --EX/MEM
            BranchAddress_EX_MEM <= BranchAddress;
            Zero_EX_MEM <= Zero;
            ALURes_EX_MEM <= ALUResult;
            RD2_EX_MEM <= RD2_ID_EX;
            MemWrite_EX_MEM <= MemWrite_ID_EX;
            Branch_EX_MEM <= Branch_ID_EX;
            RegWrite_EX_MEM <= RegWrite_ID_EX;
            MemtoReg_EX_MEM <= MemtoReg_ID_EX;
            Brne_EX_MEM <= Brne_ID_EX;
            Brgtz_EX_MEM <= Brgtz_ID_EX;
            wa_EX_MEM <= rWA;
            
            --MEM/WB
            MemData_MEM_WB <= MemData;
            ALURes_MEM_WB <= ALURes1;
            MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
            RegWrite_MEM_WB <= RegWrite_EX_MEM;
            wa_MEM_WB <= wa_EX_MEM;
            
        end if;
    end if;
end process;


SSD_inst: SSD port map(
    clk => clk,
    digits => mux1_out,
    an => an,
    cat => cat
);



led(11 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Brne & Brgtz & Jump & MemWrite & MemtoReg & RegWrite;



end Behavioral;
