--
-------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
--
--library ieee_proposed;
--use ieee_proposed.fixed_pkg.all;
--use ieee_proposed.math_utility_pkg.all;
--
--library work;
--use work.myTypes.all;
--use work.all;
--
--entity neuron is
--		-- neuron parameters
--		generic( Nsyn : natural :=3;
--		D : integerArray:=(2,3,4);
--		W : realArray:=(0.5, 0.2, 0.3);
--		alpha_w : real :=1.0;
--		beta_w : real :=0.98;
--		alpha_v1 :real :=0.98;
--		alpha_v2:real :=0.9333;
--		alpha_V :real :=0.98;
--		alpha_A:real :=0.98;
--		beta_1 :real :=0.0286;
--		beta_2 :real :=1.0;
--		beta_A :real :=1.0;
--		V_th :real :=1.0);
--		
--		port ( inputSpikes : in std_logic_vector(Nsyn downto 1):=(others=>'0');
--				 outputSpike : out std_logic:='0';
--				 globalRst,clk: in std_logic:='0';
--				 Iapp : in fp:=to_sfixed(0,fp_int,fp_frac));
--end entity;
--
--architecture behave of neuron is
--
--	component W_STDP is
--	generic(beta_w : real :=1.0;
--			alpha_w : real:=0.98;
--			w_0 : real:=0.5);
--	port(spikeSynapse, spikeNeuron, clk, initW : in std_logic;
--			neuronActivity: in fp;
--			w: out fp);
--	end component W_STDP;
--
--	component decayBlock is 
--		port (spike,clk : in std_logic;
--					alpha  : in fp;
--					v: out fp);
--	end component;
--	
--	component register_fp is 
--	port(clk: in std_logic;
--		rst: in std_logic;
--		dataIn : in fp;
--		dataOut : out fp);
--	end component;
--		
--	component decayBlockwithInput is 
--	port (clk,rst : in std_logic;
--				alpha,input  : in fp;
--				v: out fp);
--	end component;	
--	
--	component VthComparator is
--		port( V,Vth : in fp;
--				clk : in std_logic;
--				spike: out std_logic);
--	end component;
--	
--	component DelayFF is
--	port(spike_in,clk : in std_logic;
--			spike_out : out std_logic);
--	end component;
--
--	
--	component nDelayFF is
--		generic(n: integer :=1);
--		port(spike_in,clk : in std_logic;
--				spike_out : out std_logic);
--	end component nDelayFF;
--
--	
--	-- following should be in generics
--	--signal 	W0   : fp_array(Nsyn downto 1):=(others=>to_sfixed(1,fp_int,fp_frac)); -- XXX : find wahy to give default value in array (type fp)
--		
--	signal	alpha1	: fp :=to_sfixed(alpha_v1,fp_int,fp_frac);
--	signal	alpha2	: fp :=to_sfixed(alpha_v2,fp_int,fp_frac);
--	signal	alphaV	: fp :=to_sfixed(alpha_V,fp_int,fp_frac);
--	signal	alphaA	: fp :=to_sfixed(alpha_A,fp_int,fp_frac);
--	signal	Vth : fp :=to_sfixed(V_th,fp_int,fp_frac);
--	--
--	signal beta1 		: fp :=to_sfixed(beta_1,fp_int,fp_frac);
--	signal beta2		: fp :=to_sfixed(beta_2,fp_int,fp_frac);
--	signal betaA 		: fp :=to_sfixed(beta_A,fp_int,fp_frac);
--	
--	signal spikeOutSig, spikeOutSigDelayed, rstVsig : std_logic:='0';
--	--signal alpha1, alpha2, alphaV, alphaA,Vth :fp; -- Constants (could use from generic
--	signal v1, v2, vn1,vn1temp, PSP, V, somaIn ,neuronActivity, neuronActivityWeighted, weightedSpike: fp := to_sfixed(0.0,fp_int,fp_frac);
--	signal wSpike,sumWSpike : fp_array(1 to Nsyn):= (others=>to_sfixed(0,fp_int,fp_frac));
--	signal inputSpikesDelayed: std_logic_vector(Nsyn downto 1):=(others=>'0');
--
--begin
--		
--		
--	DelGen_Loop : for i in 1 to Nsyn generate
--		Del : nDelayFF generic map(n=>D(i-1)) port map (clk=>clk, spike_in=>inputSpikes(i), spike_out=>inputSpikesDelayed(i));
--	end generate DelGen_Loop;
--
--	SynapseGen_Loop : for i in 1 to Nsyn generate
--		Syn : W_STDP generic map(w_0=> W(i-1),beta_w=>beta_w, alpha_w=>alpha_w) port map(spikeSynapse=> inputSpikesDelayed(i) ,
--		spikeNeuron => spikeOutSig,clk=> clk,initW=>globalRst, neuronActivity=>neuronActivityWeighted, w=>wSpike(i));
--	end generate SynapseGen_Loop;
--	
--	-- Sum all spikes
--	sumWSpike(1)<=wSpike(1);
--	SynapseSum_Loop : for i in 2 to Nsyn generate
--		sumWSpike(i) <= resize(sumWSpike(i-1)+wSpike(i),fp_int,fp_frac);
--	end generate SynapseSum_Loop;
--	weightedSpike <= sumWSpike(Nsyn);
--	-- all spikes summed--
--		
--	DB1: decayBlockwithInput port map (input=> weightedSpike, clk=>clk, alpha=> alpha1, v=>v1,rst=>globalRst); --XXX: decay blocks are wrong  : corrected
--	DB2: decayBlockwithInput port map (input=> weightedSpike, clk=>clk, alpha=> alpha2, v=>v2,rst=>globalRst); --XXX: decay blocks are wrong  : corrected
--	
--	somaIn <= resize(Iapp*beta2 + resize((v1-v2),fp_int,fp_frac)*beta1, fp_int, fp_frac); -- caution here (might need resize if different lengths)
--	
--	
--	-- DBV: 
--	rstVsig <= spikeOutSigDelayed or spikeOutSig;
--	
--	regV : register_fp port map (clk=>clk,rst=> rstVsig, dataIn=> Vn1, dataOut=>V); -- for refractory period of additional one clock cycle
--	
--	CPR: VthComparator port map( V=> V, Vth=>Vth, clk=>clk, spike=>spikeOutSig);  -- comparator
--	Vn1temp <= resize(alphaV*V+somaIn,fp_int,fp_frac);
--	process(Vn1temp)
--	begin
--		if(Vn1temp<0) then
--		Vn1<=to_sfixed(0.0,fp_int,fp_frac);
--		else
--		Vn1<=Vn1temp;
--		end if;
--	end process;
--	
--	----------
--	
--	RFP: DelayFF port map(spike_in=>spikeOutSig, clk=>clk, spike_out=> spikeOutSigDelayed); -- refractory period
--	
--	DBA: decayBlock port map (spike=> spikeOutSig, clk=>clk, alpha=> alphaA, v=>neuronActivity);
--	neuronActivityWeighted <= resize(neuronActivity*betaA,fp_int,fp_frac);
--	outputSpike<=spikeOutSig;
--	
--	
--	
--end behave;
--
-------------------------------------------------------------------------------------------------------------


-----------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity neuron is
		-- neuron parameters
		generic( Nsyn : natural :=3;
		D : integerArray:=(2,3,4);
		W : realArray:=(0.5, 0.2, 0.3);
		alpha_w : real :=1.0;
		beta_w : real :=0.98;
		alpha_v1 :real :=0.98;
		alpha_v2:real :=0.9333;
		alpha_V :real :=0.98;
		alpha_A:real :=0.98;
		beta_1 :real :=0.0286;
		beta_2 :real :=1.0;
		beta_A :real :=1.0;
		V_th :real :=1.0);
		
		port ( inputSpikes : in std_logic_vector(Nsyn downto 1):=(others=>'0');
				 outputSpike : out std_logic:='0';
				 globalRst,clk,initW : in std_logic:='0';
				 Iapp : in fp:=to_sfixed(5,fp_int,fp_frac));
end entity;

architecture behave of neuron is

	component W_STDP is
	generic(beta_w : real :=1.0;
			alpha_w : real:=0.98;
			w_0 : real:=0.5);
	port(spikeSynapse, spikeNeuron, clk, initW : in std_logic;
			neuronActivity: in fp;
			w: out fp);
	end component W_STDP;

	component decayBlock is 
		port (spike,clk : in std_logic;
					alpha  : in fp;
					v: out fp);
	end component;
	
	component register_fp is 
	port(clk: in std_logic;
		rst: in std_logic;
		dataIn : in fp:=to_sfixed(0.0,fp_int,fp_frac);
		dataOut : out fp:=to_sfixed(0.0,fp_int,fp_frac));
	end component;
		
	component decayBlockwithInput is 
	port (clk,rst : in std_logic;
				alpha,input  : in fp;
				v: out fp);
	end component;	
	
	component VthComparator is
		port( V,Vth : in fp;
				clk : in std_logic;
				spike: out std_logic);
	end component;
	
	component DelayFF is
	port(spike_in,clk : in std_logic;
			spike_out : out std_logic);
	end component;

	
	component nDelayFF is
		generic(n: integer :=1);
		port(spike_in,clk : in std_logic;
				spike_out : out std_logic);
	end component nDelayFF;

	
	-- following should be in generics
	--signal 	W0   : fp_array(Nsyn downto 1):=(others=>to_sfixed(1,fp_int,fp_frac)); -- XXX : find wahy to give default value in array (type fp)
		
	signal	alpha1	: fp :=to_sfixed(alpha_v1,fp_int,fp_frac);
	signal	alpha2	: fp :=to_sfixed(alpha_v2,fp_int,fp_frac);
	signal	alphaV	: fp :=to_sfixed(alpha_V,fp_int,fp_frac);
	signal	alphaA	: fp :=to_sfixed(alpha_A,fp_int,fp_frac);
	signal	Vth 		: fp :=to_sfixed(V_th,fp_int,fp_frac);
	--
	signal beta1 		: fp :=to_sfixed(beta_1,fp_int,fp_frac);
	signal beta2		: fp :=to_sfixed(beta_2,fp_int,fp_frac);
	signal betaA 		: fp :=to_sfixed(beta_A,fp_int,fp_frac);
	
	signal spikeOutSig, spikeOutSigDelayed, rstVsig : std_logic:='0';
	--signal alpha1, alpha2, alphaV, alphaA,Vth :fp; -- Constants (could use from generic
	signal v1, v2, vn1, PSP, V, somaIn ,neuronActivity, neuronActivityWeighted, weightedSpike: fp := to_sfixed(0.0,fp_int,fp_frac);
	signal wSpike,sumWSpike : fp_array(1 to Nsyn):= (others=>to_sfixed(0,fp_int,fp_frac));
	signal inputSpikesDelayed: std_logic_vector(Nsyn downto 1):=(others=>'0');

begin
		
		
	DelGen_Loop : for i in 1 to Nsyn generate
		Del : nDelayFF generic map(n=>D(i-1)) port map (clk=>clk, spike_in=>inputSpikes(i), spike_out=>inputSpikesDelayed(i));
	end generate DelGen_Loop;

	SynapseGen_Loop : for i in 1 to Nsyn generate
		Syn : W_STDP generic map(w_0=> W(i-1),beta_w=>beta_w, alpha_w=>alpha_w) port map(spikeSynapse=> inputSpikesDelayed(i) ,
		spikeNeuron => spikeOutSig,clk=> clk,initW=>initW, neuronActivity=>neuronActivityWeighted, w=>wSpike(i));
	end generate SynapseGen_Loop;
	
	-- Sum all spikes
	sumWSpike(1)<=wSpike(1);
	SynapseSum_Loop : for i in 2 to Nsyn generate
		sumWSpike(i) <= resize(sumWSpike(i-1)+wSpike(i),fp_int,fp_frac);
	end generate SynapseSum_Loop;
	weightedSpike <= sumWSpike(Nsyn);
	-- all spikes summed--
		
	DB1: decayBlockwithInput port map (input=> weightedSpike, clk=>clk, alpha=> alpha1, v=>v1,rst=>globalRst); 
	DB2: decayBlockwithInput port map (input=> weightedSpike, clk=>clk, alpha=> alpha2, v=>v2,rst=>globalRst); 
	
	somaIn <= resize(Iapp*beta2 + resize((v1-v2),fp_int,fp_frac)*beta1, fp_int, fp_frac); -- caution here (might need resize if different lengths)
	
	
	-- DBV: 
	rstVsig <= spikeOutSigDelayed or spikeOutSig;
	
	regV : register_fp port map (clk=>clk,rst=> rstVsig, dataIn=> Vn1, dataOut=>V); -- for refractory period of additional one clock cycle
	
	CPR: VthComparator port map( V=> V, Vth=>Vth, clk=>clk, spike=>spikeOutSig);  -- comparator
	Vn1 <= resize(alphaV*V+somaIn,fp_int,fp_frac);
	----------
	
	RFP: DelayFF port map(spike_in=>spikeOutSig, clk=>clk, spike_out=> spikeOutSigDelayed); -- refractory period
	
	DBA: decayBlock port map (spike=> spikeOutSig, clk=>clk, alpha=> alphaA, v=>neuronActivity);
	neuronActivityWeighted <= resize(neuronActivity*betaA,fp_int,fp_frac);
	outputSpike<=spikeOutSig;
	
	
	
end behave;

-----------------------------------------------------------------------------------------------------------
