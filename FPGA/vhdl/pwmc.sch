v 20110619 2
C 40100 40900 1 0 1 IPAD-STD_LOGIC.sym
{
T 40000 41700 5 10 0 0 0 6 1
device=IPAD
T 39550 41350 5 10 1 1 0 6 1
refdes=reset
}
T 43384 45200 8 10 1 1 0 0 1
entity=PWMC
T 47884 40600 8 10 1 0 0 0 1
architecture=arc
C 39600 42400 1 0 0 write_chani_arc.sym
{
T 41800 44320 5 10 1 1 0 6 1
refdes=INPUT_CONVERTER
T 40200 44300 5 10 0 0 0 0 1
device=write_chani
}
N 42100 43500 43000 43500 4
N 39900 41200 42400 41200 4
N 42400 41200 42400 42700 4
N 42400 42700 43000 42700 4
C 47500 41300 1 0 0 OPAD-STD_LOGIC.sym
{
T 47600 42100 5 10 0 0 0 0 1
device=OPAD
T 47950 41850 5 10 1 1 0 0 1
refdes=sign
}
C 40100 43200 1 0 1 IPAD-WRITE_CHAN.sym
{
T 40000 44000 5 10 0 0 0 6 1
device=IPAD
T 39550 43650 5 10 1 1 0 6 1
refdes=assign_duty
}
C 42700 42000 1 0 0 pwm_modulator.sym
{
T 44100 44320 5 10 1 1 0 6 1
refdes=DAC
T 43300 44300 5 10 0 0 0 0 1
device=pwm
T 43300 42300 5 10 1 0 0 0 1
a : integer=write_chan'length
}
C 47500 44600 1 0 0 OPAD-STD_LOGIC.sym
{
T 47600 45400 5 10 0 0 0 0 1
device=OPAD
T 48050 45050 5 10 1 1 0 0 1
refdes=pulse
}
N 39900 42300 42100 42300 4
N 42100 42300 42100 43100 4
N 42100 43100 43000 43100 4
C 40100 42000 1 0 1 IPAD-STD_LOGIC.sym
{
T 40000 42800 5 10 0 0 0 6 1
device=IPAD
T 39550 42450 5 10 1 1 0 6 1
refdes=S
}
C 44700 42200 1 0 0 write_chano_arc.sym
{
T 46900 44120 5 10 1 1 0 6 1
refdes=OUTPUT_CONVERTER
T 45300 44100 5 10 0 0 0 0 1
device=write_chano
}
N 45000 43300 44400 43300 4
N 44400 43700 44800 43700 4
N 44800 43700 44800 44900 4
N 44800 44900 47700 44900 4
N 44400 42900 44800 42900 4
N 44800 42900 44800 41600 4
N 44800 41600 47700 41600 4
C 47500 43000 1 0 0 OPAD-WRITE_CHAN.sym
{
T 47600 43800 5 10 0 0 0 0 1
device=OPAD
T 48050 43450 5 10 1 1 0 0 1
refdes=report_duty
}
N 47700 43300 47200 43300 4
C 40100 44700 1 0 1 IPAD-STD_LOGIC.sym
{
T 40000 45500 5 10 0 0 0 6 1
device=IPAD
T 39550 45150 5 10 1 1 0 6 1
refdes=pwm_clk
}
N 39900 45000 42200 45000 4
N 42200 45000 42200 43900 4
N 42200 43900 43000 43900 4
