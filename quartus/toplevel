-- Synapse -- 
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity toplevel is
	port (ssynapse1_1, ssynapse1_2, ssynapse2_1, ssynapse2_2: in std_logic;
			Iapp1, Iapp2, Iapp3, Iapp4: in fp;
			clk: in std_logic;
			spike_out3, spike_out4: out std_logic
			);
end entity;

architecture behave of toplevel is

component neuron is
    port (
	Iapp,Isyn : in fp;
	clk : in std_logic;
	spike: out std_logic);
end component;

component synapse_w is
generic(delay : natural :=10);
port(spikeSynapse,spikeNeuron,clk : in std_logic;
		W: in fp;
		PSPout : out fp);
end component synapse_w;

signal  Isyn1, Isyn2, Isyn3, Isyn4:  fp;
signal spike1, spike2, spike3, spike4: std_logic;
signal ss1_1, ss1_2, ss2_1, ss2_2, ss3_1, ss3_2, ss4_1, ss4_2: std_logic;
signal sn1_1, sn1_2, sn2_1, sn2_2, sn3_1, sn3_2, sn4_1, sn4_2: std_logic;
signal w1_1, w1_2, w2_1, w2_2, w3_1, w3_2, w4_1, w4_2: fp;
signal psp1_1, psp1_2, psp2_1, psp2_2, psp3_1, psp3_2, psp4_1, psp4_2: fp;
begin
n1: neuron port map (Iapp1, Isyn1, clk, spike1);
n2: neuron port map (Iapp2, Isyn2, clk, spike2);
n3: neuron port map (Iapp3, Isyn3, clk, spike3);
n4: neuron port map (Iapp4, Isyn4, clk, spike4);

spike_out3 <= spike3;
spike_out4 <= spike4;

s1_1: synapse_w port map (ss1_1, sn1_1, clk, w1_1, psp1_1);
s1_2: synapse_w port map (ss1_2, sn1_2, clk, w1_2, psp1_2);
s2_1: synapse_w port map (ss2_1, sn2_1, clk, w2_1, psp2_1);
s2_2: synapse_w port map (ss2_2, sn2_2, clk, w2_2, psp2_2);
s3_1: synapse_w port map (ss3_1, sn3_1, clk, w3_1, psp3_1);
s3_2: synapse_w port map (ss3_2, sn3_2, clk, w3_2, psp3_2);
s4_1: synapse_w port map (ss4_1, sn4_1, clk, w4_1, psp4_1);
s4_2: synapse_w port map (ss4_2, sn4_2, clk, w4_2, psp4_2);

Isyn1 <= resize(psp1_1 + psp1_2, Isyn1);
Isyn2 <= resize(psp2_1 + psp2_2, Isyn2);
Isyn3 <= resize(psp3_1 + psp3_2, Isyn3);
Isyn4 <= resize(psp4_1 + psp4_2, Isyn4);

sn1_1 <= spike1;
sn1_2 <= spike1;
sn2_1 <= spike2;
sn2_2 <= spike2;
sn3_1 <= spike3;
sn3_2 <= spike3;
sn4_1 <= spike4;
sn4_2 <= spike4;

ss1_1 <= ssynapse1_1;
ss1_2 <= ssynapse1_2;
ss2_1 <= ssynapse2_1;
ss2_2 <= ssynapse2_2;
ss3_1 <= spike1;
ss3_2 <= spike2;
ss4_1 <= spike1;
ss4_2 <= spike2;

w1_1 <= to_sfixed(1.0, fp_int, fp_frac);
w1_2 <= to_sfixed(1.0, fp_int, fp_frac);
w2_1 <= to_sfixed(1.0, fp_int, fp_frac);
w2_2 <= to_sfixed(1.0, fp_int, fp_frac);
w3_1 <= to_sfixed(1.0, fp_int, fp_frac);
w3_2 <= to_sfixed(-1.0, fp_int, fp_frac);
w4_1 <= to_sfixed(-1.0, fp_int, fp_frac);
w4_2 <= to_sfixed(1.0, fp_int, fp_frac);


end behave;
