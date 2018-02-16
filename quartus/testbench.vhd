library ieee;
library ieee_proposed;
library work;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.myTypes.all;

entity testbench is
end testbench;

architecture test of testbench is

	component demo_ieee_proposed is
	 	port(inp : in std_add_array(1 to 2);
        	 result : out std_logic_vector(8 downto 0)
			);
	end component demo_ieee_proposed ;


	signal w: std_add_array(1 to 2);
	signal x,y: std_logic_vector(7 downto 0):=(others => '0');
	signal z: std_logic_vector(8 downto 0):=(others => '0');
	
begin
	
	dut: demo_ieee_proposed port map(inp=>w,result=>z);
	w(1)<=x;
	w(2)<=y;
	
	process
		begin
			x <= "01000100" after 1 ns;
			y <= "01000010" after 1 ns;
		
		wait for 6 ns;
		
			x <= "01001100" after 1 ns;
			y <= "01001010" after 1 ns;
		
		wait for 6 ns;
		report "Ending test bench" severity NOTE;
		wait; -- end simulation
	end process;
	
end test;