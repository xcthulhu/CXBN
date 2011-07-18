library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity br8gen_prim is
  generic ( A : integer := 16 );
  port(
    clk, reset    : in  std_logic;
    baudrate : in  std_logic_vector(A-1 downto 0);
    max_tick : out std_logic
    );
end;

architecture arch of br8gen_prim is
  signal r_reg  : unsigned(A-1 downto 0);
  signal r_next : unsigned(A-1 downto 0);
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
