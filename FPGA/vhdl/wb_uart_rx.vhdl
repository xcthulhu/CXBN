library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.common_decs.all;
use work.intercon_decs.all;

--------- UART READER ---------

entity WB_UART_RX is
  generic (
    -- id = Right Ascension of Canopus
    id : device_id := x"0623"
    );
  port
    (
      -- Component external signals
      clk, reset : in std_logic;

      -- Wishbone interface signals
      wbw : in  wbws;
      wbr : out wbrs;

      -- Input from UART
      UART_in : in  char;               -- From UART_RX
      rd_uart : out std_logic;          -- Data Recieved handshake Flag

      -- Status Flags
      RX_RDY : in std_logic;          -- Data waiting?
      RX_OVERFLOW : in std_logic;          -- Buffer overflow?

      -- Data Ready Flag for Arbiter
      DATA_RDY : out std_logic;         -- Relays UART_RDY

      -- Set the baudrate
      baudrate : out write_chan
      );
end entity;

architecture RTL of WB_UART_RX is
  signal readdata       : read_chan;
  signal saddr          : subsys_addr;
  signal rd_ack, wr_ack : std_logic;
  signal brate          : write_chan;
begin
  saddr <= subsys(wbw.c.address);

  --  Register reading logic
  readdata_logic : process(clk, reset)
  begin
    if(reset = '1') then
      rd_ack   <= '0';
      readdata <= (others => '0');
      rd_uart  <= '0';
    elsif(rising_edge(clk)) then
      rd_ack  <= '0';
      rd_uart <= '0';
      if master_is_reading(wbw) then
        rd_ack <= '1';
        case saddr is
          -- ALL SUBSYSTEM ADDRESSES MUST BE EVEN!!!! 
          -- Explanation: 
          -- http://www.armadeus.com/wiki/index.php?title=APF27_FPGA-IMX_interface_description

          -- Report ID
          when x"0" =>
            readdata <= id;
          -- Report Baudrate
          when x"2" =>
            readdata <= brate;
          -- Read UART
          when x"4" =>
            if (RX_RDY = '1') then
              readdata <= std_logic_vector(resize(unsigned(UART_in), readdata'length));
              rd_uart  <= '1';
            else
              readdata <= x"EEEE";
            end if;
          -- Get status
          when x"C" =>
            readdata <= (0 => RX_RDY, 1 => RX_OVERFLOW, others => '0');
          when others =>
            readdata <= x"BAD1";
        end case;
      end if;
    end if;
  end process;

  -- The only thing that can be written is the baud rate
  change_baud : process(clk, reset)
  begin
    if(reset = '1') then
      wr_ack <= '0';
      brate  <= (others => '0');
    elsif(rising_edge(clk)) then
      wr_ack <= '0';
      if master_is_writing(wbw) then
        wr_ack <= '1';
        case saddr is
          -- Write the baudrate
          when x"2"   => brate <= wbw.c.writedata;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  wbr.ack      <= rd_ack or wr_ack;
  wbr.readdata <= readdata when rd_ack = '1'
                  else (others => '0');
  baudrate <= brate;
  DATA_RDY <= RX_RDY;
  
end architecture RTL;
