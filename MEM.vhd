library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( clk       : in  STD_LOGIC;
           enable    : in  STD_LOGIC;
           MemWrite  : in  STD_LOGIC;
           Addr      : in  STD_LOGIC_VECTOR (31 downto 0);
           w_data    : in  STD_LOGIC_VECTOR (31 downto 0);
           r_data    : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResult : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

type mem_type is array (0 to 63) of STD_LOGIC_VECTOR (31 downto 0);

signal mem : mem_type := (
    X"00000000",  -- 0x00: result (expected 3)
    X"00000008",  -- 0x04: N
    X"00000009",  -- 0x08:  9
    X"00000006",  -- 0x0C:  6
    X"0000000E",  -- 0x10: 14
    X"00000019",  -- 0x14: 25
    X"FFFFFFFE",  -- 0x18: -2
    X"00000021",  -- 0x1C: 33
    X"FFFFFFF7",  -- 0x20: -9
    X"00000016",  -- 0x24: 22
    others => X"00000000"
);

begin

process(clk)
begin
    if rising_edge(clk) then
        if enable = '1' and MemWrite = '1' then
            mem(conv_integer(Addr(7 downto 2))) <= w_data;
        end if;
    end if;
end process;

r_data    <= mem(conv_integer(Addr(7 downto 2)));
ALUResult <= Addr;

end Behavioral;
