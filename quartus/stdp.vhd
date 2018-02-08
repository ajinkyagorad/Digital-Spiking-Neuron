-- STDP component
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;
entity STDP is
port(spikeSynapse, spikeNeuron,clk : in std_logic;
		w: out fp);
end entity STDP;

architecture behav of STDP is
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0);
end;

signal v3,v3n,av3,v4,v4n,av4,avn3,avn4,deltaW,Wn: fp:=to_sfixed(0,fp_int,fp_frac);

signal alpha1 : fp :=to_sfixed(1,fp_int,fp_frac);
signal alpha2 : fp :=to_sfixed(-1,fp_int,fp_frac);
signal alpha3 : fp :=to_sfixed(0.9,fp_int,fp_frac);
signal alpha4 : fp :=to_sfixed(0.9,fp_int,fp_frac);
begin
	v3n<=v3*alpha3+to_sfixed(spikeSynapse,fp_int,fp_frac);
	v4n<=v4*alpha4+to_sfixed(spikeNeuron,fp_int,fp_frac);
	
	v3Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v3n,dataOut=>v3,rst=>spikeSynapse);
	v4Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v4n,dataOut=>v4,rst=>spikeNeuron);
	
	deltaW<=alpha1*v3+alpha2*v4;
	Wn <=W+deltaW;
	WReg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>Wn,dataOut=>W,rst=>'0');
	
end behav;