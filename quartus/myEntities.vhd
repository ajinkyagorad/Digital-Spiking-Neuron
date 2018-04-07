
--
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity register_fp_rst_1 is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp;
		dataOut : out fp);
	end entity;

architecture behav of register_fp_rst_1 is 
signal dataOutsig: fp;
begin
	process(clk,rst)
	begin
	
	
	if clk'event and clk='1' then
		if rst= '1' then
		dataOut <= to_sfixed(1.0,fp_int,fp_frac);
		else
		dataOut <= dataIn;
		end if;
	end if;
	end process;
end behav;
--
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
entity register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0));
end entity register_n;

architecture behav of register_n is 
begin
	process(clk,rst)
	begin

	if rst= '1' then
		dataOut<= (others=>'0');
	elsif clk'event and clk='1' then
		dataOut<=dataIn;
	end if;
		
	end process;
end behav;

--

library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity VthComparator is
generic(bits: natural:=8);
port( V,Vth : in fp;
		clk : in std_logic;
		spike: out std_logic);
end VthComparator;

architecture behav of VthComparator is
begin
process(V, clk)
begin
	if (clk'event and (clk='1')) then
		if (V>=Vth) then
			spike<='1';
		else
			spike<='0';
		end if;
	end if;
end process;
end behav;

--

-- Delay FF : Synapse Component --
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity DelayFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end entity DelayFF;
architecture behav of DelayFF is
begin
process(clk)
begin
if clk'event and clk='1' then
	spike_out<=spike_in;
end if;
end process;
end behav;

-----------------

library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity register_fp is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp;
		dataOut : out fp);
	end entity;

architecture behav of register_fp is 
begin
	process(clk,rst)
	begin

	if rst= '1' then
		dataOut <= to_sfixed(0.0,fp_int,fp_frac);
	elsif clk'event and clk='1' then
		dataOut <= dataIn;
	end if;
		
	end process;
end behav;

-- THESE ARE DEBUG ENTITIES

library ieee;
library ieee_proposed;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity decayBlock is 
port (spike,clk : in std_logic;
			v: out fp);
end entity;
architecture arch of decayBlock is 

	component register_fp_rst_1 is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp;
		dataOut : out fp);
	end component;
	signal spikeSLV: std_logic_vector(0 downto 0);
	signal vsig,vn: fp:=to_sfixed(0,fp_int,fp_frac);
	signal alpha : fp :=to_sfixed(0.8,fp_int,fp_frac);
begin
		alpha<= to_sfixed(0.8,alpha);
		spikeSLV(0)<=spike;
		vn<=resize(resize(vsig*alpha,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeSLV)),fp_int,fp_frac),fp_int,fp_frac);
		vReg : register_fp_rst_1 port map(clk=>clk,dataIn=>vn,dataOut=>vsig,rst=>spike);
		v<=vn;
end arch;
