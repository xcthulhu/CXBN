v 20110619 2
N 42600 46500 42300 46500 4
{
T 42100 46600 5 10 1 1 0 0 1
netname=clk
}
N 44300 48300 44300 47200 4
N 42000 47200 44300 47200 4
N 42000 47200 42000 46100 4
N 42000 46100 42600 46100 4
N 42600 47900 42300 47900 4
{
T 42100 47600 5 10 1 1 0 0 1
netname=reset
}
N 42600 48700 42300 48700 4
{
T 42100 48800 5 10 1 1 0 0 1
netname=clk
}
N 42600 45300 42300 45300 4
{
T 42100 45000 5 10 1 1 0 0 1
netname=reset
}
N 50950 46650 50550 46650 4
{
T 50350 46750 5 10 1 1 0 0 1
netname=clk
}
N 53050 46650 53200 46650 4
N 53200 46650 53200 49500 4
N 53200 49500 41900 49500 4
N 41900 48300 41900 49500 4
N 41900 48300 42600 48300 4
N 44400 46100 45000 46100 4
N 53050 46250 53200 46250 4
N 53200 46250 53200 44400 4
N 53200 44400 46700 44400 4
N 46700 44400 46700 45300 4
N 46700 45300 47300 45300 4
N 53050 45050 54300 45050 4
T 47915 48495 8 10 1 1 0 0 1
entity=UART_RX_MOD
T 44115 50195 8 10 0 0 0 0 1
architecture=arc
C 42300 47200 1 0 0 br8gen_arch.sym
{
T 44000 49120 5 10 1 1 0 6 1
refdes=BAUD
}
C 42300 44600 1 0 0 uart_rx_arch.sym
{
T 44100 46920 5 10 1 1 0 6 1
refdes=UART_RDR
}
N 40700 48600 41000 48600 4
{
T 41400 48500 5 10 1 1 0 6 1
netname=clk
}
N 40700 47200 41000 47200 4
{
T 41500 47100 5 10 1 1 0 6 1
netname=reset
}
N 40700 45700 42600 45700 4
N 53050 45450 53750 45450 4
C 40900 48300 1 0 1 IPAD-STD_LOGIC.sym
{
T 40450 48750 5 10 1 1 0 6 1
refdes=CLK
}
C 54100 44750 1 0 0 IPAD-WBWS.sym
{
T 54450 45200 5 10 1 1 0 0 1
refdes=WBW
}
C 54100 45700 1 0 0 OPAD-WBRS.sym
{
T 54450 46150 5 10 1 1 0 0 1
refdes=WBR
}
C 54100 46500 1 0 0 OPAD-STD_LOGIC.sym
{
T 54450 47050 5 10 1 1 0 0 1
refdes=RDY
}
C 40900 46900 1 0 1 IPAD-STD_LOGIC.sym
{
T 40650 47350 5 10 1 1 0 6 1
refdes=RESET
}
C 40900 45400 1 0 1 IPAD-STD_LOGIC.sym
{
T 40450 45950 5 10 1 1 0 6 1
refdes=RX
}
T 53484 44395 8 10 1 0 0 0 1
id : device_id=?x"DEAD"
C 50650 44350 1 0 0 wb_uart_rx_rtl.sym
{
T 52750 47070 5 10 1 1 0 6 1
refdes=WISHBONE
T 51250 47050 5 10 0 0 0 0 1
device=WB_UART_RX
T 51350 44750 5 10 1 0 0 0 1
id : device_id=id
}
C 47000 44200 1 0 0 fifo_arch.sym
{
T 47600 46900 5 10 0 0 0 0 1
device=fifo
T 47600 44500 5 10 1 0 0 0 1
b : natural=?8
T 47600 44800 5 10 1 0 0 0 1
w : natural=?4    
}
C 44700 45250 1 0 0 charci_arc.sym
{
T 46400 46670 5 10 1 1 0 6 1
refdes=CONVERT_CHAR
T 45300 46650 5 10 0 0 0 0 1
device=charci
}
N 46700 46100 47300 46100 4
N 45250 45700 45250 45500 4
N 47300 46500 47000 46500 4
{
T 46800 46600 5 10 1 1 0 0 1
netname=clk
}
N 45250 45500 46450 45500 4
N 46450 45500 46450 45700 4
N 46450 45700 47300 45700 4
N 44400 45700 45250 45700 4
N 47300 44900 47000 44900 4
{
T 46800 44600 5 10 1 1 0 0 1
netname=reset
}
C 48500 45250 1 0 0 charco_arc.sym
{
T 50200 46670 5 10 1 1 0 6 1
refdes=U?
T 49100 46650 5 10 0 0 0 0 1
device=charco
}
N 53750 45450 53750 46000 4
N 53750 46000 54300 46000 4
N 53650 46800 54300 46800 4
N 53650 45850 53650 46800 4
N 53650 45850 53050 45850 4
N 50700 45450 50700 46100 4
N 50700 45450 50950 45450 4
N 48800 45700 49050 45700 4
N 49050 45700 49050 45500 4
N 49050 45500 50600 45500 4
N 50600 45500 50600 46250 4
N 50600 46250 50950 46250 4
C 48400 44250 1 0 0 inv_inv_v.sym
{
T 49800 45145 5 10 1 1 0 6 1
refdes=NEG1
T 49000 45350 5 10 0 0 0 0 1
device=inv
}
N 48800 45300 49000 45300 4
N 49000 45300 49000 44950 4
N 49000 44950 49100 44950 4
N 50650 45850 50950 45850 4
N 50500 46100 50700 46100 4
N 50200 44950 50200 45450 4
N 50200 45450 50650 45450 4
N 50650 45450 50650 45850 4
N 50950 45050 50650 45050 4
{
T 50450 44750 5 10 1 1 0 0 1
netname=reset
}