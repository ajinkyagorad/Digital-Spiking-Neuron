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
		w: out std_logic_vector(fp_bits-1 downto 0));
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

entity STDP_old is
port(spikeSynapse, spikeNeuron,clk : in std_logic;
		w: out fp);
end entity STDP_old;

architecture behav of STDP_old is

	component register_fp is 
		port(clk: in std_logic;
			rst: in std_logic;
			dataIn : in fp;
			dataOut : out fp);
	end component;

	component register_fp_rst_1 is 
		port(clk: in std_logic;
			rst: in std_logic;
			dataIn : in fp;
			dataOut : out fp);
	end component;

	signal v3,v3n,av3,v4,v4n,av4,avn3,avn4,deltaW,Wn,Wsig : fp:=to_sfixed(0,fp_int,fp_frac);
	signal spikeSynapseSLV: std_logic_vector(0 downto 0);
	signal spikeNeuronSLV : std_logic_vector(0 downto 0);
	signal alpha1 : fp :=to_sfixed(1,fp_int,fp_frac);
	signal alpha2 : fp :=to_sfixed(-1,fp_int,fp_frac);
	signal alpha3 : fp :=to_sfixed(0.4,fp_int,fp_frac);
	signal alpha4 : fp :=to_sfixed(0.4,fp_int,fp_frac);

begin 

	alpha1<= to_sfixed(1,alpha1);
	alpha2<= to_sfixed(-1,alpha2);
	alpha3<= to_sfixed(0.4, alpha3);
	alpha4<= to_sfixed(0.4, alpha4);
	spikeSynapseSLV(0)<=spikeSynapse;
	spikeNeuronSLV(0)<= spikeNeuron;
	v3n<=resize(resize(v3*alpha3,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeSynapseSLV)),fp_int,fp_frac),fp_int,fp_frac);
	v4n<=resize(resize(v4*alpha4,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeNeuronSLV)),fp_int,fp_frac),fp_int,fp_frac);
	
	v3Reg : register_fp_rst_1  port map(clk=>clk,dataIn=>v3n,dataOut=>v3,rst=>spikeSynapse);
	v4Reg : register_fp_rst_1  port map(clk=>clk,dataIn=>v4n,dataOut=>v4,rst=>spikeNeuron);
	W<=Wsig;
	deltaW<=resize(alpha1*v3+alpha2*v4,fp_int,fp_frac);
	Wn <=resize(Wsig+deltaW,fp_int,fp_frac);

	WReg : register_fp  port map(clk=>clk,dataIn=>Wn,dataOut=>Wsig,rst=>'0');

end behav;


--------------------------- new stdp ----------------------

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
port(spikeSynapse, spikeNeuron, clk, initW : in std_logic;
		w0: in fp;
		w: out fp);
end entity STDP;

architecture behav of STDP is

	component register_fp_en is 
		port(clk: in std_logic;
			en : in std_logic;
			dataIn : in fp;
			dataOut : out fp);
	end component;

	component register_fp_rst_1 is 
		port(clk: in std_logic;
			rst: in std_logic;
			dataIn : in fp;
			dataOut : out fp);
	end component;

	component decayBlock is 
		port (spike,clk : in std_logic;
				alpha : in fp;
				v: out fp);
	end component;
	
	signal v3,v3n,av3,v4,v4n,av4,avn3,avn4,deltaW,Wn,Wsig : fp:=to_sfixed(0,fp_int,fp_frac);
	signal alpha1 : fp :=to_sfixed(1,fp_int,fp_frac);
	signal alpha2 : fp :=to_sfixed(-1,fp_int,fp_frac);
	signal alpha3 : fp :=to_sfixed(0.4,fp_int,fp_frac);
	signal alpha4 : fp :=to_sfixed(0.4,fp_int,fp_frac);
	signal ensig : std_logic;

begin 

	decay_blk_1: decayBlock port map(spike => spikeSynapse, alpha => alpha3, clk => clk, v => v3);
	decay_blk_2: decayBlock port map(spike => spikeNeuron, alpha => alpha4, clk => clk, v => v4);
	
	alpha1<= to_sfixed(1,alpha1);
	alpha2<= to_sfixed(-1,alpha2);
	alpha3<= to_sfixed(0.4, alpha3);
	alpha4<= to_sfixed(0.4, alpha4);
	
   deltaW <= resize(alpha1*v3,fp_int,fp_frac) when spikeNeuron = '1' else resize(alpha2*v4,fp_int,fp_frac);
		
--	v3n<=resize(resize(v3*alpha3,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeSynapseSLV)),fp_int,fp_frac),fp_int,fp_frac);
--	v4n<=resize(resize(v4*alpha4,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeNeuronSLV)),fp_int,fp_frac),fp_int,fp_frac);
	
--	v3Reg : register_fp_rst_1  port map(clk=>clk,dataIn=>v3n,dataOut=>v3,rst=>spikeSynapse);
--	v4Reg : register_fp_rst_1  port map(clk=>clk,dataIn=>v4n,dataOut=>v4,rst=>spikeNeuron);
	
	W<=Wsig;
--	deltaW<=resize(alpha1*v3+alpha2*v4,fp_int,fp_frac);
	ensig <= (spikeNeuron xor spikeSynapse)or initW;
	
	Wn <=resize(Wsig+deltaW,fp_int,fp_frac) when initW = '0' else w0;
	WReg : register_fp_en  port map(clk=>clk, en => ensig, dataIn=>Wn,dataOut=>Wsig);

end behav;
