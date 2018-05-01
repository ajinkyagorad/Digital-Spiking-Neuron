-- STDP unit merged  at input
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity W_STDP is
port(spikeSynapse, spikeNeuron, clk, initW : in std_logic;
		w0,neuronActivity: in fp;
		w: out fp);
end entity W_STDP;

architecture behav of W_STDP is

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
	signal alpha1 : fp :=to_sfixed(1,fp_int,fp_frac); -- sign of the weight change
	signal alpha3 : fp :=to_sfixed(0.8,fp_int,fp_frac); --  1-dt/tauSTDP+
	signal ensig : std_logic;

begin 

	decay_blk_1: decayBlock port map(spike => spikeSynapse, alpha => alpha3, clk => clk, v => v3);

	--alpha1<= to_sfixed(1,alpha1);
	--alpha3<= to_sfixed(0.4, alpha3);

	
   deltaW <= resize(alpha1*v3,fp_int,fp_frac) when spikeNeuron = '1' else resize(neuronActivity,fp_int,fp_frac);
	ensig <= (spikeNeuron xor spikeSynapse)or initW;
	Wn <=resize(Wsig+deltaW,fp_int,fp_frac) when initW = '0' else w0;
	WReg : register_fp_en  port map(clk=>clk, en => ensig, dataIn=>Wn,dataOut=>Wsig);
	
	process(spikeSynapse)
	begin
		if spikeSynapse = '1' then
			W <= Wsig;
		else
			W <= to_sfixed(0.0,fp_int,fp_frac);
		end if;		
	end process;

end behav;
