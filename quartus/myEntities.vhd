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

entity register_fp_en is 
	port(clk: in std_logic:='0';
		en : in std_logic:='0';
		dataIn : in fp:=to_sfixed(0.0,fp_int,fp_frac);
		dataOut : out fp:=to_sfixed(0.0,fp_int,fp_frac));
end entity;

architecture behav of register_fp_en is 
signal dataOutsig: fp;
begin
	process(clk)
	begin
	
	if clk'event and clk='1' then
	   if en = '1' then
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
use work.myTypes.all;

entity register_fp_rst_1 is 
	port(clk: in std_logic:='0';
		rst: in std_logic:='0';
		dataIn : in fp:=to_sfixed(0.0,fp_int,fp_frac);
		dataOut : out fp:=to_sfixed(0.0,fp_int,fp_frac));
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
port(clk: in std_logic:='0';
rst: in std_logic:='0';
dataIn : in std_logic_vector(bits-1 downto 0):=(others=>'0');
dataOut : out std_logic_vector(bits-1 downto 0):=(others=>'0'));
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
port( V,Vth : in fp:=to_sfixed(0.0,fp_int,fp_frac);
		clk : in std_logic:='0';
		spike: out std_logic:='0');
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
port(spike_in,clk : in std_logic:='0';
		spike_out : out std_logic:='0');
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
	port(clk: in std_logic:='0';
		rst: in std_logic:='0';
		dataIn : in fp:=to_sfixed(0.0,fp_int,fp_frac);
		dataOut : out fp:=to_sfixed(0.0,fp_int,fp_frac));
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
port (spike,clk : in std_logic:='0';
			alpha  : in fp:=to_sfixed(0.0,fp_int,fp_frac);
			v: out fp:=to_sfixed(0.0,fp_int,fp_frac));
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
	
begin
		spikeSLV(0)<=spike;
		vn<=resize(resize(vsig*alpha,fp_int,fp_frac)+to_sfixed(to_integer(unsigned(spikeSLV)),fp_int,fp_frac),fp_int,fp_frac);
		vReg : register_fp_rst_1 port map(clk=>clk,dataIn=>vn,dataOut=>vsig,rst=>spike);
		v<=vn;
end arch;
---------- no reset decay block (with inp

library ieee;
library ieee_proposed;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity decayBlockwithInput is 
port (clk,rst : in std_logic:='0';
			alpha,input  : in fp:=to_sfixed(0.0,fp_int,fp_frac);
			v: out fp:=to_sfixed(0.0,fp_int,fp_frac));
end entity;
architecture arch of decayBlockwithInput is 

	component register_fp is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp;
		dataOut : out fp);
	end component;
	
	signal vsig,vn: fp:=to_sfixed(0,fp_int,fp_frac);
	
begin
		
		vn<=resize(resize(vsig*alpha,fp_int,fp_frac)+input,fp_int,fp_frac);
		vReg : register_fp port map(clk=>clk,dataIn=>vn,dataOut=>vsig,rst=>rst);
		v<=vn;
end arch;

----------------------------------------------

-- nDelay FF : Synapse Component --
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity nDelayFF is
	generic(n: integer :=2);
	port(spike_in,clk : in std_logic:='0';
			spike_out : out std_logic:='0');
end entity nDelayFF;

architecture behav of nDelayFF is

	component DelayFF is
	port(spike_in,clk : in std_logic;
			spike_out : out std_logic);
	end component;

	signal spikeArrived : std_logic_vector(n downto 1):=(others=>'0');

begin
	
	

	D0 : DelayFF port map(clk=>clk,spike_in=>spike_in,spike_out=>spikeArrived(1));
	DFF_genloop: for i in 2 to n generate 
	D : DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
	end generate DFF_genloop;
	spike_out <= spikeArrived(n);
end behav;


------------------------------------------------------------
