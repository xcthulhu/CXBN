library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
  generic (A : integer := 16);
  port (
    -- Inputs
    ---- Global signals
    reset : in std_logic;

    ---- Seperate clock from logic
    pwm_clk : in std_logic;

    ---- Set and retrieve the duty cycle
    assign_duty : in  std_logic_vector(A-1 downto 0);  -- Assigns the duty cycle; needs set to activate
    S           : in  std_logic;                       -- Make high to set the duty cycle
    report_duty : out std_logic_vector(A-1 downto 0);  -- Reports the duty cycle

    ---- Output signal
    pulse : out std_logic;  -- The pulse because this is a "pulse width modulator"
    sign  : out std_logic   -- The sign to indicate negative/positive
    );
end entity;

architecture modulator of pwm is
  signal duty,counter  : unsigned(A-2 downto 0);
  signal sgn           : std_logic;
begin
  process (reset,s,pwm_clk)
  begin
    if reset = '1' then
      duty    <= (others => '0');
      counter <= (others => '0');
      sgn     <= '0';
      pulse   <= '0';
    elsif s = '1' then
        sgn <= assign_duty(A-1);
        duty <= unsigned(assign_duty(A-2 downto 0));
        counter <= (others => '0');
    elsif rising_edge(pwm_clk) then
        if (counter < duty) then
         pulse <= '1';
        else
         pulse <= '0';
        end if;
	counter <= counter + 1;
    end if;
  end process;

  sign <= sgn;
  report_duty <= sgn & std_logic_vector(duty);
	-- All of the real work is below
	-- We pulse as long as the counter is less than the duty cycle.
	-- Make sure sign is hooked up to other end of H-bridge,
	-- to get correct behavior when low
  pulse <= 'H' when counter(1) = '1' else
           'L';

end architecture;
