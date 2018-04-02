-- stdp wrapper
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity wrapper_stdp is
port(spikeSynapse, spikeNeuron,clk : in std_logic;
		w: out std_logic_vector(7 downto 0));
end entity wrapper_stdp;

architecture behave of wrapper_stdp is 

	component STDP is
	port(spikeSynapse, spikeNeuron,clk : in std_logic;
		w: out fp);
	end component;

	--signal PSPout_fp: sfixed(4 downto -3):=(others => '0');
	signal w_fp: fp:=(others => '0');
	
begin
	
	stdp_instance: stdp port map(spikeSynapse=>spikeSynapse, spikeNeuron=>spikeNeuron, clk=>clk, w=>w_fp);
	w <= to_slv(w_fp);

end behave;
 	
-- STDP component
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.myTypes.all;
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
dataOut : out std_logic_vector(bits-1 downto 0));
end component;

signal v3,v3n,av3,v4,v4n,av4,avn3,avn4,deltaW,Wn,Wsig : fp:=(others=>'0');
signal spikeSynapseSLV: std_logic_vector(0 downto 0);
signal spikeNeuronSLV : std_logic_vector(0 downto 0);
signal v3slv,v3nslv,v4slv,v4nslv,wnslv,WsigSLV : std_logic_vector(fp_bits-1 downto 0);
signal alpha1 : fp ;--:=to_sfixed(1,alpha1);
signal alpha2 : fp ;--:=to_sfixed(-1,fp_int,fp_frac);
signal alpha3 : fp ;--:=to_sfixed(0.9,fp_int,fp_frac);
signal alpha4 : fp ;--:=to_sfixed(0.9,fp_int,fp_frac);
begin 
	alpha1<= to_sfixed(1,alpha1);
	alpha2<= to_sfixed(-1,alpha2);
	alpha3<= to_sfixed(0.9, alpha3);
	alpha4<= to_sfixed(0.9, alpha4);
	spikeSynapseSLV(0)<=spikeSynapse;
	spikeNeuronSLV(0)<= spikeNeuron;
	v3n<=resize(resize(v3*alpha3,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeSynapseSLV)),fp_int,fp_frac),fp_int,fp_frac);
	v4n<=resize(resize(v4*alpha4,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeNeuronSLV)),fp_int,fp_frac),fp_int,fp_frac);
	v3nslv<=to_slv(v3n);
	v3slv<=to_slv(v3);
	v4nslv<=to_slv(v4n);
	v4slv<=to_slv(v4);
	v3Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v3nslv,dataOut=>v3slv,rst=>spikeSynapse);
	v4Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v4nslv,dataOut=>v4slv,rst=>spikeNeuron);
	W<=Wsig;
	deltaW<=resize(alpha1*v3+alpha2*v4,fp_int,fp_frac);
	Wn <=resize(Wsig+deltaW,fp_int,fp_frac);
	WnSLV<=to_slv(Wn);
	WsigSLV<=to_slv(Wsig);
	WReg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>WnSLV,dataOut=>WsigSLV,rst=>'0');
	
end behav;
