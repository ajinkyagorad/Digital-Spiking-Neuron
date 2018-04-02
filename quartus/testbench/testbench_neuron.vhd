
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

	component wrapper_neuron is
	 	port (Iapp,Isyn : in std_logic_vector (7 downto 0);
			  clk : in std_logic;
			  spike: out std_logic);
	end 
	component;
	
	signal clk: std_logic := '0';
	signal Iap : std_logic_vector := "00000000";
	signal result: std_logic;	

begin
	
	clk <= (not clk) after 10 ns;

	process

		begin
			Iap <= "00001000";			
		wait for 10 ns;
			Iap <= "00000000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00000000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00000000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00001000";
		wait for 10 ns;
			Iap <= "00000000";
		wait for 10 ns;
		
		report "Ending test bench" severity NOTE;
		wait; -- end simulation
	
	end process;

	dut: wrapper_neuron port map(Iapp=>Iap, Isyn=>"00000000", clk=>clk, spike=> result);
	
end test;