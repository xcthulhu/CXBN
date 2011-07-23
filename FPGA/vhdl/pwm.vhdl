library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity pwm is
  generic (A : integer := 16);
  port (
    -- Inputs
    ---- Global signals
    clk, reset : in std_logic;

    ---- Set and retrieve the duty cycle
    assign_duty : in  std_logic_vector(A-1 downto 0);  -- Assigns the duty cycle; needs set to activate
    S           : in  std_logic;        -- Make high to set the duty cycle
    report_duty : out std_logic_vector(A-1 downto 0);  -- Reports the duty cycle

    ---- Output signal
    pulse : out std_logic;  -- The pulse because this is a "pulse width modulator"
    sign  : out std_logic   -- The sign to indicate negative/positive
    );
end entity;

architecture modulator of pwm is
  -- Principle registers of a the pulse width modulator: 
  -- the duty cycle and the counter 
  signal duty, counter : std_logic_vector(A-2 downto 0);
  signal sgn           : std_logic;
begin
  set_logic : process (clk, reset)
  begin  -- process seq
    if reset = '1' then
      duty    <= (others => '0');
      counter <= (others => '0');
      sgn     <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
      if (S = '1') then
        sgn <= assign_duty(A-1);
        duty <= assign_duty(A-2 downto 0);
      end if;
    end if;
  end process set_logic;

  increment : process(clk, reset)
  begin
    if (reset /= '1') and rising_edge(clk) then
      counter <= counter + 1;
    end if;
  end process increment;

  sign        <= sgn;
  report_duty <= sgn & duty;

  -- All of the real work is below
  -- We pulse as long as the counter is less than the duty cycle.
  -- Make sure sign is hooked up to other end of H-bridge,
  -- to get correct behavior when low
  pulse <= '1' when counter < duty else '0';
end architecture;
