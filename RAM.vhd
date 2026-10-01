library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    Port ( clk  : in  STD_LOGIC;
           we   : in  STD_LOGIC;
           en   : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           di   : in  STD_LOGIC_VECTOR (31 downto 0);
           do   : out STD_LOGIC_VECTOR (31 downto 0));
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to 63) of STD_LOGIC_VECTOR (31 downto 0);
signal ram : ram_type := (others => X"00000000");

begin

-- Synchronous, write-first block RAM
process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            if we = '1' then
                ram(conv_integer(addr)) <= di;
                do <= di;
            else
                do <= ram(conv_integer(addr));
            end if;
        end if;
    end if;
end process;

end Behavioral;
