library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity neuron is
		port ( inputPattern	: in std_logic_vector(4 downto 0);
					clk, initW	: in std_logic;
					Iapp1 		: in fp;
					Iapp2			: in fp;
					s1,s2			: out std_logic
				);
end entity;

architecture behave of neuron is

	component DelayFF is
		port(spike_in,clk : in std_logic;
				spike_out 	: out std_logic);
	end component;

	component register_fp is 
		port(clk				: in std_logic;
			  rst				: in std_logic;
			  dataIn 		: in fp;
			  dataOut 		: out fp);
	end component;

	signal spikeArrived : std_logic_vector(delay downto 1);
	signal v1,v2,av1,av2,v1n,v2n, saint1, saint2 : fp := to_sfixed(0,fp_int,fp_frac); 
	constant alpha1 : fp:=to_sfixed(0.9,fp_int,fp_frac);
	constant alpha2 : fp:=to_sfixed(0.8,fp_int,fp_frac);
	signal spikeArrivedSLV : std_logic_vector(0 downto 0);
	signal saint:integer := 0;

begin

	n1 : MasterNeuron port map (inputSpike => inputPattern, clk => clk, initW => initW, Iapp => Iapp1, outputSpike => s1);
	n2 : MasterNeuron port map (inputSpike => inputPattern, clk => clk, initW => initW, Iapp => Iapp2, outputSpike => s2);


	--- first input mux 
	D0 : DelayFF port map(clk=>clk,spike_in=>spikeSynapse,spike_out=>spikeArrived(1));
	
	DFF_genloop1: 	for i in 2 to delay 
						generate 
								D: DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
						end generate DFF_genloop;

	--- second input mux 
	D0 : DelayFF port map(clk=>clk,spike_in=>spikeSynapse,spike_out=>spikeArrived(1));
	
	DFF_genloop1: 	for i in 2 to delay 
						generate 
								D: DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
						end generate DFF_genloop;

						
	--- common synapse computationally


	spikeArrivedSLV(0) <= spikeArrived(delay); 
	v1n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV1, fp_int, fp_frac);
	v2n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV2, fp_int, fp_frac);
	av1<=resize(alpha1*v1, fp_int, fp_frac);
	av2<=resize(alpha2*v2, fp_int, fp_frac);
	
	
	v1Reg : register_fp   port map (clk=>clk,dataIn=>v1n,dataOut=>v1,rst=>'0');
	v2Reg : register_fp  port map(clk=>clk,dataIn=>v2n,dataOut=>v2,rst=>'0');
	
	PSPout<= resize((v1-v2)*W, fp_int, fp_frac);

	
end behave;

-----------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity fpMux is
		port ( 	inputSpike		: in std_logic;
					inputW, inputZ	: in fp;
					output			: out fp;
			  );
end entity;
architecture behave of fpMux is
begin
	process
	begin
		if inputSpike = 1 then
			output <= inputW;
		else
			output <= inputZ;
		end if;
		
	end 
end behave;
