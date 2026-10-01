library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( clk             : in  STD_LOGIC;
           en              : in  STD_LOGIC;
           rst             : in  STD_LOGIC;
           branch_addr     : in  STD_LOGIC_VECTOR (31 downto 0);
           jmp_addr        : in  STD_LOGIC_VECTOR (31 downto 0);
           jump            : in  STD_LOGIC;
           PCSrc           : in  STD_LOGIC;
           current_instr   : out STD_LOGIC_VECTOR (31 downto 0);
           next_instr_addr : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal pc_out  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal sum_out : STD_LOGIC_VECTOR (31 downto 0);
signal next_pc : STD_LOGIC_VECTOR (31 downto 0);

type rom_type is array (0 to 63) of STD_LOGIC_VECTOR (31 downto 0);

-- Counts the positive odd elements of an array of N words.
-- $1 = N, $2 = i, $3 = byte offset, $4 = counter, $5 = element, $6 = element & 1
-- Delay slots: 3 noops after branches (resolved in MEM), 1 noop after jumps (resolved in ID)
constant rom : rom_type := (
    B"100011_00000_00001_0000000000000100",  -- 0:  lw   $1, 4($0)      8C010004
    B"000000_00000_00000_00010_00000_100000", -- 1:  add  $2, $0, $0     00001020
    B"000000_00000_00000_00011_00000_100000", -- 2:  add  $3, $0, $0     00001820
    B"000000_00000_00000_00100_00000_100000", -- 3:  add  $4, $0, $0     00002020
    B"000100_00001_00010_0000000000011110",  -- 4:  beq  $1, $2, 30     1022001E  (loop)
    X"00000000",                             -- 5:  noop
    X"00000000",                             -- 6:  noop
    X"00000000",                             -- 7:  noop
    B"100011_00011_00101_0000000000001000",  -- 8:  lw   $5, 8($3)      8C650008
    X"00000000",                             -- 9:  noop
    X"00000000",                             -- 10: noop
    B"000111_00101_00000_0000000000000111",  -- 11: bgtz $5, 7          1CA00007
    X"00000000",                             -- 12: noop
    X"00000000",                             -- 13: noop
    X"00000000",                             -- 14: noop
    B"001000_00010_00010_0000000000000001",  -- 15: addi $2, $2, 1      20420001
    B"001000_00011_00011_0000000000000100",  -- 16: addi $3, $3, 4      20630004
    B"000010_00000000000000000000000100",    -- 17: j    4              08000004
    X"00000000",                             -- 18: noop
    B"001100_00101_00110_0000000000000001",  -- 19: andi $6, $5, 1      30A60001
    X"00000000",                             -- 20: noop
    X"00000000",                             -- 21: noop
    B"000101_00110_00000_0000000000000111",  -- 22: bne  $6, $0, 7      14C00007
    X"00000000",                             -- 23: noop
    X"00000000",                             -- 24: noop
    X"00000000",                             -- 25: noop
    B"001000_00010_00010_0000000000000001",  -- 26: addi $2, $2, 1      20420001
    B"001000_00011_00011_0000000000000100",  -- 27: addi $3, $3, 4      20630004
    B"000010_00000000000000000000000100",    -- 28: j    4              08000004
    X"00000000",                             -- 29: noop
    B"001000_00100_00100_0000000000000001",  -- 30: addi $4, $4, 1      20840001
    B"001000_00010_00010_0000000000000001",  -- 31: addi $2, $2, 1      20420001
    B"001000_00011_00011_0000000000000100",  -- 32: addi $3, $3, 4      20630004
    B"000010_00000000000000000000000100",    -- 33: j    4              08000004
    X"00000000",                             -- 34: noop
    B"101011_00000_00100_0000000000000000",  -- 35: sw   $4, 0($0)      AC040000
    B"000010_00000000000000000000100100",    -- 36: j    36 (halt)      08000024
    X"00000000",                             -- 37: noop
    others => X"00000000"
);

begin

process(clk, rst)
begin
    if rst = '1' then
        pc_out <= (others => '0');
    elsif rising_edge(clk) then
        if en = '1' then
            pc_out <= next_pc;
        end if;
    end if;
end process;

sum_out <= pc_out + 4;

current_instr   <= rom(conv_integer(pc_out(7 downto 2)));
next_instr_addr <= sum_out;

next_pc <= branch_addr when PCSrc = '1' else
           jmp_addr    when jump  = '1' else
           sum_out;

end Behavioral;
