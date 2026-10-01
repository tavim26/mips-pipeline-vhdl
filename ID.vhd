library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ID is
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
end ID;

architecture Behavioral of ID is

component REG_FILE is
    Port ( clk   : in  STD_LOGIC;
           en    : in  STD_LOGIC;
           ra1   : in  STD_LOGIC_VECTOR (4 downto 0);
           ra2   : in  STD_LOGIC_VECTOR (4 downto 0);
           wa    : in  STD_LOGIC_VECTOR (4 downto 0);
           wd    : in  STD_LOGIC_VECTOR (31 downto 0);
           regwr : in  STD_LOGIC;
           rd1   : out STD_LOGIC_VECTOR (31 downto 0);
           rd2   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

begin

RF_inst: REG_FILE port map (
    clk   => clk,
    en    => en,
    ra1   => instr(25 downto 21),
    ra2   => instr(20 downto 16),
    wa    => wa,
    wd    => wd,
    regwr => reg_write,
    rd1   => rd1,
    rd2   => rd2
);

ext_imm(15 downto 0)  <= instr(15 downto 0);
ext_imm(31 downto 16) <= X"FFFF" when (ext_op = '1' and instr(15) = '1') else X"0000";

rt   <= instr(20 downto 16);
rd   <= instr(15 downto 11);
sa   <= instr(10 downto 6);
func <= instr(5 downto 0);

end Behavioral;
