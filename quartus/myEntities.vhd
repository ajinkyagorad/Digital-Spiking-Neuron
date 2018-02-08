
package myEntities is


-- N Bit generic register--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;
entity register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0);
end entity register_n;


architecture behav of register_n is 
begin
	process(clk,rst)
	begin

	if rst= '1' then
		dataOut<='0';
	elsif clk'event and clk='1' then
		dataOut<=dataIn;
	end if;
		
	end process;
end behav;


-- Threshold Comparator : Neuron Component--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;
entity VthComparator is
generic(bits: natural:=8);
port( V,Vth : in fp;
	spike: out std_logic);
end VthComparator

architecture behav of VthComparator is
begin
process(V)
if V>Vth then
spike<='1';
else
spike<='0';
end if;
end process;
end behav;


-- Delay FF : Synapse Component --
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;
entity DFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end entity DFF;
architecture behav of DFF is
begin
process(clk)
if clk'event and clk='1' then
	spike_out<=spike_in;
end if;
end process;
end behav;
		
