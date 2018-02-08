library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
package myTypes is
constant fp_int : natural :=4;
constant fp_frac : natural := -3;
constant fp_bits : natural :=fp_int-fp_frac+1;
type fp sfixed (fp_int downto fp_frac);
end package myTypes;


-- N Bit generic register--
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


-- N Bit generic register--
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

-- Threshold Comparator --

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
		

-- Neuron --

entity neuron is
port(Iapp,Isyn : in fp;
		clk : in std_logic;
		spike: out std_logic);
end entity neuron;

architecture behav of neuron is
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0);
end;

signal Vn,aVn,Iapp_b1,Isyn_b1,sum_I,Vn1: fp;
signal b1,b2,alpha: fp:=to_sfixed(1.0,4,-3);
constant Vth : sfixed = to_sfixed(1.0,4,-3);
begin 
	regV : register_n generic map(bits=>fp_bits) port map (clk=>clk,rst=>spike,dataIn=>Vn1,dataOut=>Vn);
	compV : VthComparator port map(V=>Vn1,Vth=>Vth,spike=>spike);
	Vn1<=Iapp*b1+Isyn*b2+alpha*Vn;
end behav;

-- Synapse Components --
-- Delay FF
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

-- STDP component
entity STDP is
port(spikeSynapse, spikeNeuron,clk : in std_logic;
		w: out fp);
end entity STDP;

architecture behav of STDP is
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0);
end;

signal v3,v3n,av3,v4,v4n,av4,avn3,avn4,deltaW,Wn: fp:=to_sfixed(0,fp_int,fp_frac);

signal alpha1 : fp :=to_sfixed(1,fp_int,fp_frac);
signal alpha2 : fp :=to_sfixed(-1,fp_int,fp_frac);
signal alpha3 : fp :=to_sfixed(0.9,fp_int,fp_frac);
signal alpha4 : fp :=to_sfixed(0.9,fp_int,fp_frac);
begin
	v3n<=v3*alpha3+to_sfixed(spikeSynapse,fp_int,fp_frac);
	v4n<=v4*alpha4+to_sfixed(spikeNeuron,fp_int,fp_frac);
	
	v3Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v3n,dataOut=>v3,rst=>spikeSynapse);
	v4Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v4n,dataOut=>v4,rst=>spikeNeuron);
	
	deltaW<=alpha1*v3+alpha2*v4;
	Wn <=W+deltaW;
	WReg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>Wn,dataOut=>W,rst=>'0');
	
end behav;

-- Synapse -- 
entity synapse is
generic(delay : natural =10);
port(spikeSynapse,spikeNeuron,clk : in std_logic;
		PSPout : out fp);
end entity synapse;

architecture behav of synapse is
component DFF is
port(spike_in,clk : in std_logic;
		spike_out : out std_logic);
end;
component register_n is 
generic(bits:natural:=4);
port(clk: in std_logic;
rst: in std_logic;
dataIn : in std_logic_vector(bits-1 downto 0);
dataOut : out std_logic_vector(bits-1 downto 0);
end;
component STDP is
port(spikeSynapse, spikeNeuron : in std_logic;
		w: out fp);
end;

signal spikeArrived : std_logic_vector(delay downto 1);
signal v1,v2,av1,av2,v1n,v2n,W : fp; 
constant alpha1 : fp<=to_sfixed(0.9,fp_int,fp_frac);
constant alpha2 : fp<=to_sfixed(0.8,fp_int,fp_frac);
begin

	D0 : DFF port map(clk=>clk,spike_in=>spike,spike_out=>spikeArrived(1));
	DFF_genloop: for i in 2 to delay generate 
	D : DFF port map(clk=>clk,spike_in=>spikeArrived(i-1),spike_out=>spikeArrived(i));
	end generate DFF_genloop;
	v1n<=to_sfixed(spikeArrived(delay),fp_int,fp_frac)+aV1;
	v2n<=to_sfixed(spikeArrived(delay),fp_int,fp_frac)+aV2;
	av1<=alpha1*v1;
	av2<=alpha2*v2;
	
	v1Reg : register_n  generic map(bits=>fp_bits) generic map (bitsport map(clk=>clk,dataIn=>v1n,dataOut=>v1,rst=>'0');
	v2Reg : register_n  generic map(bits=>fp_bits) port map(clk=>clk,dataIn=>v2n,dataOut=>v2,rst=>'0');
	STDP1 : STDP port map(clk=>clk,spikeSynapse=>spikeSynapse,spikeNeuron=>spikeNeuron,W=>W);
	
	PSPout<= (v1-v2)*W;
end behav;


-- Simple Network --
--entity network is 
--port(spike_in : in std_logic_vector(10 downto 1); -- Neurons input
--		spike_out : out std_logic_vector(10 downto 1)); -- Spiking of neurons
--end entity netowork;
--
--architecture arch of network is
--
--component neuron is
--port(Iapp,Isyn : in fp;
--		clk : in std_logic;
--		spike: out std_logic);
--end ;
--component synapse is
--generic(delay : natural =10);
--port(spikeSynapse,spikeNeuron,clk : in std_logic;
--		PSPout : out fp);
--end ;
--signal Isyn, Iapp: fp(10 downto 1):= to_sfixed(0,fp_int,fp_frac); -- Each Neuron
--signal PSP : fp(100 downto 1):=to_sfixed(0,fp_int,fp_frac); -- PSP for each synapse
--const Nsyn: integer:=6;
--const N: integer:=4;
--constant X: is array of integer(Nsyn downto 1):=(1,1,1,2,2,2);
--constant Xn: is array of integer(Nsyn downto 1):=(2,3,4,1,1,2);
--
--begin 
--	NeuronGenLoop : for i in 1 to N generate
--	N : Neuron portmap(Iapp=>Iapp(i),Isyn=>Isyn(i),clk=>clk,spike=>spike_out);
--	end generate NeuronGenLoop;
--	
--	SynapseLoop : for i in 1 to generate
--	Syn : synapse generic map (delay = Tau(i)) port map (clk=>clk,spikeSynapse=>spike(X(i)),spikeNeuron=>spike(Xn(i)),PSPout=>PSP());
--	end PostNeuronLoop;
--	end PreNeuronLoop;
--		
--
--	