library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity rstgen_syscon is
  port (
    ext_clk   : in  std_logic;
    global_clk : out std_logic;
    global_reset : out std_logic
    );
end entity;

architecture RTL of rstgen_syscon is
  signal dly       : std_logic := '0';
  signal reset       : std_logic := '0';
begin
  process(clk)
  begin
    if(rising_edge(clk)) then
      -- Behavior of this loop: 
      -- (0th cycle) Everything starts off zero
      -- (1st cycle) dly = '0' and reset = '1'
      -- (2nd cycle) dly = '1' and reset = '0'
      -- (forever after) same as 2nd cycle ; it is a fixpoint
      dly <= dly xor reset;
      reset <= dly nor reset;
    end if;
  end process;
  global_clk <= ext_clk;
  global_reset <= reset;
end architecture;
