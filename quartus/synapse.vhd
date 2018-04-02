-- synapse wrapper
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity wrapper_synapse is
		generic(delay : natural :=10);
		port(spikeSynapse,spikeNeuron,clk : in std_logic;
		PSPout : out std_logic_vector(fp_bits-1 downto 0));
	end entity wrapper_synapse;

architecture behave of wrapper_synapse is 

	component synapse is
		generic(delay : natural :=10);
		port(spikeSynapse,spikeNeuron,clk : in std_logic;
		PSPout : out fp);
	end component synapse;


	--signal PSPout_fp: sfixed(4 downto -3):=(others => '0');
	signal PSPout_fp: fp:=(others => '0');
	
begin
	
	synapse_instance: synapse port map(spikeSynapse => spikeSynapse, spikeNeuron => spikeNeuron, clk => clk, PSPout => PSPout_fp);
	PSPout <= to_slv(PSPout_fp);

end behave;

-- Synapse -- 
library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.all;
use work.myTypes.all;

entity synapse is
generic(delay : natural :=10);
port(spikeSynapse,spikeNeuron,clk : in std_logic;
		PSPout : out fp);
end entity synapse;

architecture behav of synapse is
component DelayFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end component;
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0));
end component;
component STDP is
port(spikeSynapse, spikeNeuron, clk : in std_logic;
		w: out fp);
end component;

signal spikeArrived : std_logic_vector(delay downto 1);
signal v1,v2,av1,av2,v1n,v2n,W : fp := to_sfixed(0,fp_int,fp_frac); 
constant alpha1 : fp:=to_sfixed(0.9,fp_int,fp_frac);
constant alpha2 : fp:=to_sfixed(0.8,fp_int,fp_frac);
signal spikeArrivedSLV : std_logic_vector(0 downto 0);
signal v1nSLV, v1SLV, v2nSLV, v2SLV: std_logic_vector(fp_bits-1 downto 0);
begin

	D0 : DelayFF port map(clk=>clk,spike_in=>spikeSynapse,spike_out=>spikeArrived(1));
	DFF_genloop: for i in 2 to delay generate 
	D : DelayFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
	end generate DFF_genloop;
	spikeArrivedSLV(0) <= spikeArrived(delay); 
	v1n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV1, fp_int, fp_frac);
	v2n<=resize(to_sfixed(to_integer(unsigned(spikeArrivedSLV)),fp_int,fp_frac)+aV2, fp_int, fp_frac);
	av1<=resize(alpha1*v1, fp_int, fp_frac);
	av2<=resize(alpha2*v2, fp_int, fp_frac);
	
	v1nSLV <= to_slv(v1n);

	v2nSLV <= to_slv(v2n);
	v1 <= to_sfixed(v1SLV,v1);
   v2 <= to_sfixed(v2SLV,v2);
	v1Reg : register_n  generic map(bits=>fp_bits) port map (clk=>clk,dataIn=>v1nSLV,dataOut=>v1SLV,rst=>'0');
	v2Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v2nSLV,dataOut=>v2SLV,rst=>'0');
	STDP1 : STDP port map(clk=>clk,spikeSynapse=>spikeSynapse,spikeNeuron=>spikeNeuron,W=>W);
	
	PSPout<= resize((v1-v2)*W, fp_int, fp_frac);
end behav;
