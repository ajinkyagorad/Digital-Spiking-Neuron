library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity patternLearning is
		port ( inputPattern	: in std_logic_vector(4 downto 0);
					clk, initW	: in std_logic;
					Iapp1 		: in fp;
					Iapp2			: in fp;
					s1,s2			: out std_logic
				);
end entity;

architecture behave of patternLearning is

component MasterNeuron is
		port ( inputSpike		: in std_logic_vector(4 downto 0);
					clk, initW	: in std_logic;
					Iapp			: in fp;
				outputSpike		: out std_logic
				);
end component;

begin

	n1 : MasterNeuron port map (inputSpike => inputPattern, clk => clk, initW => initW, Iapp => Iapp1, outputSpike => s1);
	n2 : MasterNeuron port map (inputSpike => inputPattern, clk => clk, initW => initW, Iapp => Iapp2, outputSpike => s2);

end behave;


------------------------------ bigger entity for neuron comprising old neuron block and synapse with stdp ------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity MasterNeuron is
		port ( inputSpike		: in std_logic_vector(4 downto 0);
					clk, initW	: in std_logic;
					Iapp			: in fp;
				outputSpike		: out std_logic
				);
end entity;

architecture behave of MasterNeuron is 

	type fp_array is array(4 downto 0) of fp;
	
	component neuron is
			port (
					Iapp,Isyn 	: in fp;
					clk 			: in std_logic;
					spike			: out std_logic);
	end component;

	component synapse_w is
			generic(delay : natural :=10);
			port(spikeSynapse,clk 	: in std_logic;
					W						: in fp;
					PSPout			 	: out fp);
	end component synapse_w;

	component STDP is
			port(spikeSynapse, spikeNeuron, clk, initW 	: in std_logic;
					w0													: in fp;
					w													: out fp);
	end component STDP;

	signal wStdpSynSig, PSPoutSig : fp_array;  
	signal outputSpikeSig 			: std_logic;
	signal IsynSig 					: fp;
	
begin

	Gen_synapse:
	for I in 4 downto 0 generate
		synapseI: synapse_w port map 
						(spikeSynapse => inputSpike(i), clk => clk, W => wStdpSynSig(i), PSPout => PSPoutSig(i));
	end generate Gen_synapse;
	
	Gen_stdp:
	for I in 4 downto 0 generate
		stdpI: STDP port map 
						(spikeSynapse => inputSpike(i), spikeNeuron => outputSpikeSig, initW => initW , clk => clk, w0 => to_sfixed(0.4, fp_int, fp_frac), w => wStdpSynSig(i));
	end generate Gen_stdp;
	
	Soma: neuron port map (Iapp => Iapp, spike => outputSpikeSig, clk => clk, Isyn => IsynSig);
	
	IsynSig <= resize (PSPoutSig(0)+PSPoutSig(1)+PSPoutSig(2)+PSPoutSig(3)+PSPoutSig(4),IsynSig);
	outputSpike<=outputSpikeSig;
	
end behave;
