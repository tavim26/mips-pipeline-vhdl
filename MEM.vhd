
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity MEM is
  Port ( 
        clk :       in STD_LOGIC;
        enable :    in STD_LOGIC;
        MemWrite :  in STD_LOGIC;
        Addr :      in STD_LOGIC_VECTOR (31 downto 0);
        w_data :    in STD_LOGIC_VECTOR (31 downto 0);
        
        r_data :    out STD_LOGIC_VECTOR (31 downto 0);
        ALUResult : out STD_LOGIC_VECTOR (31 downto 0)
  );
end MEM;


architecture Behavioral of MEM is


type mem_type is array (0 to 63) of std_logic_vector(31 downto 0);

signal mem : mem_type := (

X"00000000", --aici se va scrie rezultatul, la adresa 0, rez este 3 in acest caz
X"00001000", --N=8 (numarul de elemente) la adresa 4

--in continuare vor fi elementele, incepand de la adresa 8
X"00001001", --9
X"00000110", --6
X"00001110", --14
X"00011001", --25
X"11111110", -- -2
X"00100001", --33
X"11110111", -- -9
X"00010110", --22

others => X"00000000"
);

begin

 r_data <= mem(conv_integer(Addr(7 downto 2)));
    process (clk) 
    begin
        if enable = '1' then
            if rising_edge(clk) and MemWrite = '1' then
                mem(conv_integer(Addr(7 downto 2))) <= w_data;
            end if;
        end if;
    end process;

    
    
    ALUResult <= Addr;

end Behavioral;
