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
      clk, reset : in  std_logic;

      -- Wishbone interface signals
      wbw        : in  wbws;
      wbr        : out wbrs;

      -- Input from UART
      UART_in    : in  char;      -- From UART_RX
      rd_uart    : out std_logic; -- Data Recieved handshake Flag

      -- Status Flags
      UART_RDY   : in  std_logic; -- Data waiting?
      OVERFLOW   : in  std_logic; -- Buffer overflow?

      -- Data Ready Flag for Arbiter
      DATA_RDY   : out std_logic; -- Relays UART_RDY

      -- Set the baudrate
      baudrate   : out write_chan
    );
end entity;

architecture RTL of WB_UART_RX is
  signal readdata       : read_chan;
  signal addr           : std_logic_vector((botb - 1) downto 0);
  signal rd_ack, wr_ack : std_logic;
  signal brate          : write_chan;
begin
  addr <= wbw.c.address((botb - 1) downto 0);

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
      if check_wb0(wbw) then
        rd_ack <= '1';
        case addr is
          when "000000" =>
            readdata <= (0 => UART_RDY, 1 => OVERFLOW, others => '0');
          when "000001" =>
            readdata <=
              std_logic_vector(resize(unsigned(UART_in), chan_size));
            rd_uart <= '1';
          when "000010" =>
            readdata <= brate;
          when "000011" =>
            readdata <= id;
          when others =>
            readdata <= x"BAD0";
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
      if check_wb1(wbw) then
        wr_ack <= '1';
        case addr is
          when "000010" => brate <= wbw.c.writedata;
          when others   => null;
        end case;
      end if;
    end if;
  end process;

  wbr.ack      <= rd_ack or wr_ack;
  wbr.readdata <= readdata when (check_wb0(wbw))
                  else (others => '0');
  baudrate <= brate;
  DATA_RDY <= UART_RDY;
  
end architecture RTL;


