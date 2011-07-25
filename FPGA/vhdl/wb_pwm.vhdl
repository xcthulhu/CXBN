library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.common_decs.all;
use work.intercon_decs.all;

--------- WISHBONE PULSE WIDTH MODULATOR ---------

entity WB_PWM is
  generic (
    -- id = Some golden ratio
    id : device_id := x"6180"
    );
  port
    (
      -- Component external signals
      clk, reset : in std_logic;

      -- Wishbone interface signals
      wbw : in  wbws;
      wbr : out wbrs;

      -- Input from PWM (namely, the register reporting the duty cycle)
      DUTY_REPORT : in write_chan;

      -- Set the duty cycle
      DUTY_ASSIGNMENT : out write_chan;
      DUTY_SET_FLAG   : out std_logic
      );
end entity;

architecture RTL of WB_PWM is
  signal readdata       : read_chan;
  signal saddr          : subsys_addr;
  signal rd_ack, wr_ack : std_logic;
  signal flag           : std_logic;
  signal duty           : write_chan;
begin
  saddr <= subsys(wbw.c.address);

  --  Register reading logic
  readdata_logic : process(clk, reset)
  begin
    if(reset = '1') then
      rd_ack   <= '0';
      readdata <= (others => '0');
    elsif(rising_edge(clk)) then
      rd_ack <= '0';
      if master_is_reading(wbw) then
        rd_ack <= '1';
        case saddr is
          -- ALL SUBSYSTEM ADDRESSES MUST BE EVEN!!!!
          -- Explanation:
          -- http://www.armadeus.com/wiki/index.php?title=APF27_FPGA-IMX_interface_description
          when x"0" =>
            readdata <= id;
          when x"2" =>
            readdata <= DUTY_REPORT;
          when others =>
            readdata <= x"BAD3";
        end case;
      end if;
    end if;
  end process;

  -- The only thing that can be written is the duty cycle
  change_baud : process(clk, reset)
  begin
    if(reset = '1') then
      wr_ack <= '0';
      flag   <= '0';
      duty   <= (others => '0');
    elsif(rising_edge(clk)) then
      wr_ack <= '0';
      flag   <= '0';
      duty   <= (others => '0');
      if master_is_writing(wbw) then
        wr_ack <= '1';
        case saddr is
          when x"2" =>
            duty <= wbw.c.writedata;
            flag <= '1';
          when others => null;
        end case;
      end if;
    end if;
  end process;

  wbr.ack      <= rd_ack or wr_ack;
  wbr.readdata <= readdata when  rd_ack = '1'                 
		           else (others => '0');
  DUTY_SET_FLAG   <= flag;
  DUTY_ASSIGNMENT <= duty;
end architecture RTL;
