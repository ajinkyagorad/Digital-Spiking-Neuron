--STDP PART IS COMMENTED. MAKE SURE TO REMOVE COMMENT

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

entity synapse is
generic(delay : natural :=10);
port(spikeSynapse,spikeNeuron,clk : in std_logic;
		PSPout : out fp);
end entity synapse;

architecture behav of synapse is
component DelayFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end component;
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0));
end component;
--component STDP is
--port(spikeSynapse, spikeNeuron : in std_logic;
--		w: out fp);
--end;

signal spikeArrived : std_logic_vector(delay downto 1);
signal v1,v2,av1,av2,v1n,v2n,W : fp; 
constant alpha1 : fp:=to_sfixed(0.9,fp_int,fp_frac);
constant alpha2 : fp:=to_sfixed(0.8,fp_int,fp_frac);
signal spikeArrivedSLV : std_logic_vector(0 downto 0);
signal v1nSLV, v1SLV, v2nSLV, v2SLV: std_logic_vector(fp_int downto fp_frac);
begin

	D0 : DelayFF port map(clk=>clk,spike_in=>spikeSynapse,spike_out=>spikeArrived(1));
	DFF_genloop: for i in 2 to delay generate 
	D : DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
	end generate DFF_genloop;
	spikeArrivedSLV(0) <= spikeArrived(delay); 
	v1n<=to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV1;
	v2n<=to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV2;
	av1<=alpha1*v1;
	av2<=alpha2*v2;
	
	v1nSLV <= to_slv(v1n);
	v2nSLV <= to_slv(v2n);
	v1SLV <= to_slv(v1);
	v2SLV <= to_slv(v2);
	v1Reg : register_n  generic map(bits=>fp_bits) port map (clk=>clk,dataIn=>v1nSLV,dataOut=>v1SLV,rst=>'0');
	v2Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v2nSLV,dataOut=>v2SLV,rst=>'0');
	--STDP1 : STDP port map(clk=>clk,spikeSynapse=>spikeSynapse,spikeNeuron=>spikeNeuron,W=>W);
	
	PSPout<= (v1-v2)*W;
end behav;
