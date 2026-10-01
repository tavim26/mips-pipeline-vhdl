library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port (
        clk : in  STD_LOGIC;
        btn : in  STD_LOGIC_VECTOR (4 downto 0);
        sw  : in  STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an  : out STD_LOGIC_VECTOR (7 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn    : in  STD_LOGIC;
           clk    : in  STD_LOGIC);
end component;

component SSD is
    Port ( clk    : in  STD_LOGIC;
           digits : in  STD_LOGIC_VECTOR(31 downto 0);
           an     : out STD_LOGIC_VECTOR(7 downto 0);
           cat    : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch is
    Port ( clk             : in  STD_LOGIC;
           en              : in  STD_LOGIC;
           rst             : in  STD_LOGIC;
           branch_addr     : in  STD_LOGIC_VECTOR (31 downto 0);
           jmp_addr        : in  STD_LOGIC_VECTOR (31 downto 0);
           jump            : in  STD_LOGIC;
           PCSrc           : in  STD_LOGIC;
           current_instr   : out STD_LOGIC_VECTOR (31 downto 0);
           next_instr_addr : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component ID is
    Port ( clk       : in  STD_LOGIC;
           en        : in  STD_LOGIC;
           reg_write : in  STD_LOGIC;
           instr     : in  STD_LOGIC_VECTOR (25 downto 0);
           ext_op    : in  STD_LOGIC;
           wa        : in  STD_LOGIC_VECTOR (4 downto 0);
           wd        : in  STD_LOGIC_VECTOR (31 downto 0);
           rd1       : out STD_LOGIC_VECTOR (31 downto 0);
           rd2       : out STD_LOGIC_VECTOR (31 downto 0);
           ext_imm   : out STD_LOGIC_VECTOR (31 downto 0);
           func      : out STD_LOGIC_VECTOR (5 downto 0);
           sa        : out STD_LOGIC_VECTOR (4 downto 0);
           rt        : out STD_LOGIC_VECTOR (4 downto 0);
           rd        : out STD_LOGIC_VECTOR (4 downto 0));
end component;

component UC is
    Port ( Instr    : in  STD_LOGIC_VECTOR (5 downto 0);
           RegDst   : out STD_LOGIC;
           ExtOp    : out STD_LOGIC;
           ALUSrc   : out STD_LOGIC;
           Branch   : out STD_LOGIC;
           Brne     : out STD_LOGIC;
           Brgtz    : out STD_LOGIC;
           Jump     : out STD_LOGIC;
           ALUOp    : out STD_LOGIC_VECTOR (1 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component EX is
    Port ( ALUSrc     : in  STD_LOGIC;
           ALUOp      : in  STD_LOGIC_VECTOR (1 downto 0);
           RD1        : in  STD_LOGIC_VECTOR (31 downto 0);
           RD2        : in  STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm    : in  STD_LOGIC_VECTOR (31 downto 0);
           sa         : in  STD_LOGIC_VECTOR (4 downto 0);
           func       : in  STD_LOGIC_VECTOR (5 downto 0);
           PCNext     : in  STD_LOGIC_VECTOR (31 downto 0);
           RegDst     : in  STD_LOGIC;
           rt         : in  STD_LOGIC_VECTOR (4 downto 0);
           rd         : in  STD_LOGIC_VECTOR (4 downto 0);
           Zero       : out STD_LOGIC;
           Gtz        : out STD_LOGIC;
           ALURes     : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddr : out STD_LOGIC_VECTOR (31 downto 0);
           rWA        : out STD_LOGIC_VECTOR (4 downto 0));
end component;

component MEM is
    Port ( clk       : in  STD_LOGIC;
           enable    : in  STD_LOGIC;
           MemWrite  : in  STD_LOGIC;
           Addr      : in  STD_LOGIC_VECTOR (31 downto 0);
           w_data    : in  STD_LOGIC_VECTOR (31 downto 0);
           r_data    : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResult : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal enable, rst : STD_LOGIC;

-- IF
signal Instruction, PC4, JumpAddr : STD_LOGIC_VECTOR (31 downto 0);
signal PCSrc : STD_LOGIC;

-- ID
signal rd1, rd2, Ext_Imm : STD_LOGIC_VECTOR (31 downto 0);
signal func : STD_LOGIC_VECTOR (5 downto 0);
signal sa, rt, rd : STD_LOGIC_VECTOR (4 downto 0);
signal RegDst, ExtOp, ALUSrc, Branch, Brne, Brgtz, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);

-- EX
signal Zero, Gtz : STD_LOGIC;
signal ALUResult, BranchAddress : STD_LOGIC_VECTOR (31 downto 0);
signal rWA : STD_LOGIC_VECTOR (4 downto 0);

-- MEM / WB
signal MemData, ALURes1, WriteData : STD_LOGIC_VECTOR (31 downto 0);
signal digits : STD_LOGIC_VECTOR (31 downto 0);

-- IF/ID
signal PC4_IF_ID         : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal Instruction_IF_ID : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

-- ID/EX
signal PC4_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal func_ID_EX : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
signal sa_ID_EX, rt_ID_EX, rd_ID_EX : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
signal ALUOp_ID_EX : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
signal MemtoReg_ID_EX, RegWrite_ID_EX, MemWrite_ID_EX, Branch_ID_EX, Brne_ID_EX,
       Brgtz_ID_EX, ALUSrc_ID_EX, RegDst_ID_EX : STD_LOGIC := '0';

-- EX/MEM
signal BranchAddress_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal wa_EX_MEM : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
signal Zero_EX_MEM, Gtz_EX_MEM, RegWrite_EX_MEM, MemWrite_EX_MEM, MemtoReg_EX_MEM,
       Branch_EX_MEM, Brne_EX_MEM, Brgtz_EX_MEM : STD_LOGIC := '0';

-- MEM/WB
signal MemData_MEM_WB, ALURes_MEM_WB : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal wa_MEM_WB : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
signal MemtoReg_MEM_WB, RegWrite_MEM_WB : STD_LOGIC := '0';

begin

rst <= btn(1);

MPG_inst: MPG port map (
    enable => enable,
    btn    => btn(0),
    clk    => clk
);

IF_inst: IFetch port map (
    clk             => clk,
    en              => enable,
    rst             => rst,
    branch_addr     => BranchAddress_EX_MEM,
    jmp_addr        => JumpAddr,
    jump            => Jump,
    PCSrc           => PCSrc,
    current_instr   => Instruction,
    next_instr_addr => PC4
);

ID_inst: ID port map (
    clk       => clk,
    en        => enable,
    reg_write => RegWrite_MEM_WB,
    instr     => Instruction_IF_ID(25 downto 0),
    ext_op    => ExtOp,
    wa        => wa_MEM_WB,
    wd        => WriteData,
    rd1       => rd1,
    rd2       => rd2,
    ext_imm   => Ext_Imm,
    func      => func,
    sa        => sa,
    rt        => rt,
    rd        => rd
);

UC_inst: UC port map (
    Instr    => Instruction_IF_ID(31 downto 26),
    RegDst   => RegDst,
    ExtOp    => ExtOp,
    ALUSrc   => ALUSrc,
    Branch   => Branch,
    Brne     => Brne,
    Brgtz    => Brgtz,
    Jump     => Jump,
    ALUOp    => ALUOp,
    MemWrite => MemWrite,
    MemtoReg => MemtoReg,
    RegWrite => RegWrite
);

EX_inst: EX port map (
    ALUSrc     => ALUSrc_ID_EX,
    ALUOp      => ALUOp_ID_EX,
    RD1        => RD1_ID_EX,
    RD2        => RD2_ID_EX,
    Ext_Imm    => Ext_Imm_ID_EX,
    sa         => sa_ID_EX,
    func       => func_ID_EX,
    PCNext     => PC4_ID_EX,
    RegDst     => RegDst_ID_EX,
    rt         => rt_ID_EX,
    rd         => rd_ID_EX,
    Zero       => Zero,
    Gtz        => Gtz,
    ALURes     => ALUResult,
    BranchAddr => BranchAddress,
    rWA        => rWA
);

MEM_inst: MEM port map (
    clk       => clk,
    enable    => enable,
    MemWrite  => MemWrite_EX_MEM,
    Addr      => ALURes_EX_MEM,
    w_data    => RD2_EX_MEM,
    r_data    => MemData,
    ALUResult => ALURes1
);

-- Branches are resolved in MEM, jumps in ID
PCSrc <= (Zero_EX_MEM and Branch_EX_MEM)
      or ((not Zero_EX_MEM) and Brne_EX_MEM)
      or (Gtz_EX_MEM and Brgtz_EX_MEM);

JumpAddr <= PC4_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";

WriteData <= MemData_MEM_WB when MemtoReg_MEM_WB = '1' else ALURes_MEM_WB;

Pipeline_Registers: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            -- Flush: clearing the control signals turns every stage into a noop
            Instruction_IF_ID <= (others => '0');
            RegWrite_ID_EX  <= '0';
            MemWrite_ID_EX  <= '0';
            Branch_ID_EX    <= '0';
            Brne_ID_EX      <= '0';
            Brgtz_ID_EX     <= '0';
            RegWrite_EX_MEM <= '0';
            MemWrite_EX_MEM <= '0';
            Branch_EX_MEM   <= '0';
            Brne_EX_MEM     <= '0';
            Brgtz_EX_MEM    <= '0';
            RegWrite_MEM_WB <= '0';
        elsif enable = '1' then
            -- IF/ID
            PC4_IF_ID         <= PC4;
            Instruction_IF_ID <= Instruction;

            -- ID/EX
            PC4_ID_EX      <= PC4_IF_ID;
            RD1_ID_EX      <= rd1;
            RD2_ID_EX      <= rd2;
            Ext_Imm_ID_EX  <= Ext_Imm;
            sa_ID_EX       <= sa;
            func_ID_EX     <= func;
            rt_ID_EX       <= rt;
            rd_ID_EX       <= rd;
            MemtoReg_ID_EX <= MemtoReg;
            RegWrite_ID_EX <= RegWrite;
            MemWrite_ID_EX <= MemWrite;
            Branch_ID_EX   <= Branch;
            Brne_ID_EX     <= Brne;
            Brgtz_ID_EX    <= Brgtz;
            ALUSrc_ID_EX   <= ALUSrc;
            ALUOp_ID_EX    <= ALUOp;
            RegDst_ID_EX   <= RegDst;

            -- EX/MEM
            BranchAddress_EX_MEM <= BranchAddress;
            Zero_EX_MEM          <= Zero;
            Gtz_EX_MEM           <= Gtz;
            ALURes_EX_MEM        <= ALUResult;
            RD2_EX_MEM           <= RD2_ID_EX;
            wa_EX_MEM            <= rWA;
            MemtoReg_EX_MEM      <= MemtoReg_ID_EX;
            RegWrite_EX_MEM      <= RegWrite_ID_EX;
            MemWrite_EX_MEM      <= MemWrite_ID_EX;
            Branch_EX_MEM        <= Branch_ID_EX;
            Brne_EX_MEM          <= Brne_ID_EX;
            Brgtz_EX_MEM         <= Brgtz_ID_EX;

            -- MEM/WB
            MemData_MEM_WB  <= MemData;
            ALURes_MEM_WB   <= ALURes1;
            wa_MEM_WB       <= wa_EX_MEM;
            MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
            RegWrite_MEM_WB <= RegWrite_EX_MEM;
        end if;
    end if;
end process;

with sw(7 downto 5) select
    digits <= Instruction   when "000",
              PC4           when "001",
              RD1_ID_EX     when "010",
              RD2_ID_EX     when "011",
              Ext_Imm_ID_EX when "100",
              ALUResult     when "101",
              MemData       when "110",
              WriteData     when others;

SSD_inst: SSD port map (
    clk    => clk,
    digits => digits,
    an     => an,
    cat    => cat
);

led(15 downto 12) <= "0000";
led(11 downto 0)  <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Brne & Brgtz
                   & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;
