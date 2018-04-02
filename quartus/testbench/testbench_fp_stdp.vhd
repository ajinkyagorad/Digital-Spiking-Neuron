
library ieee;
library ieee_proposed;
library work;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;


entity testbench is
end testbench;

architecture test of testbench is

	component wrapper_stdp is
	 	port(spikeSynapse,spikeNeuron,clk : in std_logic;
			 w : out std_logic_vector(7 downto 0)
		);
	end component wrapper_stdp ;
	
	signal clk, ss : std_logic := '0';
	signal result: std_logic_vector(7 downto 0);

begin
	
	clk <= (not clk) after 10 ns;

	dut: wrapper_stdp port map(spikeSynapse=>ss, spikeNeuron=>'0', clk=>clk, w=> result);

	process

		begin
			ss <= '1';			
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '1';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '1';
		wait for 10 ns;
			ss <= '0';
		wait for 10 ns;
			ss <= '0';
		
		wait for 10 ns;
		
		report "Ending test bench" severity NOTE;
		wait; -- end simulation
	
	end process;
	
end test;
