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
		port ( input_pattern	: in std_logic_vector(4 downto 0);
					clk			: in std_logic;
					n1,n2			: out std_logic
				);
end entity;

architecture behave of patternLearning is

begin

end behave;


------------------------------ bigger entity for neuron comprising old neuron block and synapse with stdp ------------------------

entity MasterNeuron is
		port ( input_synapse	: in std_logic_vector(4 downto 0);
					clk			: in std_logic;
					Iapp			: in fp;
					n				: out std_logic
				);
end entity;

architecture behave of MasterNeuron is 

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

begin

end behave;
