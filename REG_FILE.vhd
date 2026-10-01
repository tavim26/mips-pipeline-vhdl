library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity REG_FILE is
    Port ( clk   : in  STD_LOGIC;
           en    : in  STD_LOGIC;
           ra1   : in  STD_LOGIC_VECTOR (4 downto 0);
           ra2   : in  STD_LOGIC_VECTOR (4 downto 0);
           wa    : in  STD_LOGIC_VECTOR (4 downto 0);
           wd    : in  STD_LOGIC_VECTOR (31 downto 0);
           regwr : in  STD_LOGIC;
           rd1   : out STD_LOGIC_VECTOR (31 downto 0);
           rd2   : out STD_LOGIC_VECTOR (31 downto 0));
end REG_FILE;

architecture Behavioral of REG_FILE is

type reg_array is array (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
signal reg_file : reg_array := (others => X"00000000");

begin

-- Write on the falling edge so that ID reads the new value in the same cycle
process(clk)
begin
    if falling_edge(clk) then
        if regwr = '1' and en = '1' and wa /= "00000" then
            reg_file(conv_integer(wa)) <= wd;
        end if;
    end if;
end process;

rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));

end Behavioral;
