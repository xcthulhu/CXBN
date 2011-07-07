-- Listing 7.2
library ieee;
use ieee.std_logic_1164.all, work.common_decs.all;

entity flag_buf is
   port(
      clk, reset: in std_logic;
      clr_flag, set_flag: in std_logic;
      din: in char;
      dout: out char;
      flag: out std_logic
   );
end flag_buf;

architecture arch of flag_buf is
   signal buf_reg, buf_next: char; 
   signal flag_reg, flag_next: std_logic;
begin
   -- FF & register
   process(clk,reset)
   begin
      if reset='1' then
         buf_reg <= (others=>'0');
         flag_reg <= '0';
      elsif (clk'event and clk='1') then
         buf_reg <= buf_next;
         flag_reg <= flag_next;
      end if;
   end process;
   -- next-state logic
   process(buf_reg,flag_reg,set_flag,clr_flag,din)
   begin
      buf_next <= buf_reg;
      flag_next <= flag_reg;
      if (set_flag='1') then
         buf_next <= din;
         flag_next <= '1';
      elsif (clr_flag='1') then
         flag_next <= '0';
      end if;
   end process;
   -- output logic
   dout <= buf_reg;
   flag <= flag_reg;
end arch;
