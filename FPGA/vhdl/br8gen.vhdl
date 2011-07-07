library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_decs.all;

entity br8gen is
  port(
    clk, reset    : in  std_logic;
    baudrate : in  write_chan;
    max_tick : out std_logic
    );
end br8gen;

architecture arch of br8gen is
  signal r_reg  : unsigned(chan_size-1 downto 0);
  signal r_next : unsigned(chan_size-1 downto 0);
begin
  -- register
  process(clk, reset)
  begin
    if (reset = '1') then
      r_reg <= (others => '0');
    elsif (rising_edge(clk)) then
      r_reg <= r_next;
    end if;
  end process;
  
  -- next-state logic
  r_next <= (others => '0') when r_reg = unsigned(baudrate)
            else r_reg + 1;
  -- output logic
  max_tick <= '1' when r_reg = unsigned(baudrate) else '0';
end arch;
