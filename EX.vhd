library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
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
end EX;

architecture Behavioral of EX is

signal ALUCtrl  : STD_LOGIC_VECTOR (2 downto 0);
signal b, c     : STD_LOGIC_VECTOR (31 downto 0);
signal zero_int : STD_LOGIC;

begin

ALU_Control: process(ALUOp, func)
begin
    case ALUOp is
        when "10" =>
            case func is
                when "100000" => ALUCtrl <= "000";  -- add
                when "000000" => ALUCtrl <= "010";  -- sll (noop is sll $0, $0, 0)
                when others   => ALUCtrl <= "000";
            end case;
        when "00"   => ALUCtrl <= "000";  -- addi, lw, sw
        when "01"   => ALUCtrl <= "001";  -- beq, bne, bgtz
        when "11"   => ALUCtrl <= "100";  -- andi
        when others => ALUCtrl <= "000";
    end case;
end process;

b <= RD2 when ALUSrc = '0' else Ext_Imm;

ALU: process(ALUCtrl, RD1, b, sa)
begin
    case ALUCtrl is
        when "000"  => c <= RD1 + b;
        when "001"  => c <= RD1 - b;
        when "010"  => c <= SHL(b, sa);
        when "100"  => c <= RD1 and b;
        when others => c <= (others => '0');
    end case;
end process;

zero_int <= '1' when c = X"00000000" else '0';

Zero <= zero_int;
Gtz  <= (not c(31)) and (not zero_int);

BranchAddr <= PCNext + (Ext_Imm(29 downto 0) & "00");
ALURes     <= c;
rWA        <= rd when RegDst = '1' else rt;

end Behavioral;
