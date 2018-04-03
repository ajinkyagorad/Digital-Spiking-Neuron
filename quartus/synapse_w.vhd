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

entity synapse_w is
generic(delay : natural :=10);
port(spikeSynapse,spikeNeuron,clk : in std_logic;
		W: in fp;
		PSPout : out fp);
end entity synapse_w;

architecture behav of synapse_w is
component DelayFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end component;
component register_fp is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp;
		dataOut : out fp);
	end component;
component STDP is
port(spikeSynapse, spikeNeuron, clk : in std_logic;
		w: out fp);
end component;

signal spikeArrived : std_logic_vector(delay downto 1);
signal v1,v2,av1,av2,v1n,v2n, saint1, saint2 : fp := to_sfixed(0,fp_int,fp_frac); 
constant alpha1 : fp:=to_sfixed(0.9,fp_int,fp_frac);
constant alpha2 : fp:=to_sfixed(0.8,fp_int,fp_frac);
signal spikeArrivedSLV : std_logic_vector(0 downto 0);
signal saint:integer := 0;
begin

	D0 : DelayFF port map(clk=>clk,spike_in=>spikeSynapse,spike_out=>spikeArrived(1));
	DFF_genloop: for i in 2 to delay generate 
	D : DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
	end generate DFF_genloop;
	spikeArrivedSLV(0) <= spikeArrived(delay); 
	v1n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV1, fp_int, fp_frac);
	v2n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV2, fp_int, fp_frac);
	av1<=resize(alpha1*v1, fp_int, fp_frac);
	av2<=resize(alpha2*v2, fp_int, fp_frac);
	
--	saint <= to_integer(unsigned(spikeArrivedSLV));
--	saint1 <= to_sfixed(saint, fp_int, fp_frac) + av1;
--	saint2 <= to_sfixed(saint, fp_int, fp_frac) + av2;
	
	v1Reg : register_fp   port map (clk=>clk,dataIn=>v1n,dataOut=>v1,rst=>'0');
	v2Reg : register_fp  port map(clk=>clk,dataIn=>v2n,dataOut=>v2,rst=>'0');
	--STDP1 : STDP port map(clk=>clk,spikeSynapse=>spikeSynapse,spikeNeuron=>spikeNeuron,W=>W);
	
	PSPout<= resize((v1-v2)*W, fp_int, fp_frac);
end behav;
