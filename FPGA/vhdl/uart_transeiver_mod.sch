v 20110619 2
N 42600 46500 42300 46500 4
{
T 42100 46600 5 10 1 1 0 0 1
netname=clk
}
N 44600 48300 45400 48300 4
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
N 45400 49100 45000 49100 4
{
T 44800 49200 5 10 1 1 0 0 1
netname=clk
}
N 45400 47900 45000 47900 4
{
T 44800 47600 5 10 1 1 0 0 1
netname=reset
}
N 47500 49300 49300 49300 4
N 49300 49300 49300 50000 4
N 49300 50000 41900 50000 4
N 41900 48300 41900 50000 4
N 41900 48300 42600 48300 4
N 45300 46500 45000 46500 4
{
T 44800 46600 5 10 1 1 0 0 1
netname=clk
}
N 45300 44900 45000 44900 4
{
T 44800 44600 5 10 1 1 0 0 1
netname=reset
}
N 44400 46100 45300 46100 4
N 44400 45700 45300 45700 4
N 46800 46100 46800 47100 4
N 44500 47100 44500 48700 4
N 44500 48700 45400 48700 4
N 44500 47100 46800 47100 4
N 47500 48900 48400 48900 4
N 48400 48900 48400 44300 4
N 48400 44300 44500 44300 4
N 44500 44300 44500 45300 4
N 44500 45300 45300 45300 4
N 44600 47200 44600 48300 4
N 44600 47200 48200 47200 4
N 48200 47200 48200 45300 4
N 48200 45300 47900 45300 4
N 47500 47700 49600 47700 4
T 44415 50295 8 10 1 1 0 0 1
entity=UART_TRANSEIVER_MOD
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
refdes=UART_IN
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
N 47500 48500 50400 48500 4
N 47500 48100 50000 48100 4
N 50000 48100 50000 47200 4
N 50000 47200 50400 47200 4
N 49600 45700 49600 47700 4
N 49600 45700 50400 45700 4
C 40900 48300 1 0 1 IPAD-STD_LOGIC.sym
{
T 40450 48750 5 10 1 1 0 6 1
refdes=CLK
}
C 50200 45400 1 0 0 IPAD-WBWS.sym
{
T 50550 45850 5 10 1 1 0 0 1
refdes=WBW
}
C 50200 46900 1 0 0 OPAD-WBRS.sym
{
T 50550 47350 5 10 1 1 0 0 1
refdes=WBR
}
C 50200 48200 1 0 0 OPAD-STD_LOGIC.sym
{
T 50550 48750 5 10 1 1 0 0 1
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
T 48884 44395 8 10 1 0 0 0 1
id:device_id=?x"DEAD"
T 48884 44095 8 10 0 0 0 0 1
generics=id:device_id
C 45100 47000 1 0 0 wb_uart_rx_rtl.sym
{
T 47200 49720 5 10 1 1 0 6 1
refdes=WISHBONE
T 45700 49700 5 10 0 0 0 0 1
device=wb_uart_rx
T 45700 47300 5 10 1 0 0 0 1
id : device_id=id
}
C 45000 44200 1 0 0 fifo_arch.sym
{
T 46500 46920 5 10 1 1 0 6 1
refdes=BUF
T 45600 46900 5 10 0 0 0 0 1
device=fifo
T 45600 44500 5 10 1 0 0 0 1
b : natural=?8
T 45600 44800 5 10 1 0 0 0 1
w : natural=?4    
}
C 46100 44600 1 0 0 inv_inv_v.sym
{
T 47800 45495 5 10 1 1 0 6 1
refdes=NEG1
T 46700 45700 5 10 0 0 0 0 1
device=inv
}
