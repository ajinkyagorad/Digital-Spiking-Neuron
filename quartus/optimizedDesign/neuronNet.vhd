library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.math_utility_pkg.all;

library work;
use work.myTypes.all;
use work.all;

entity neuronNet is
port (clk,globalRst : in std_logic);
end entity;
architecture arch of neuronNet is

component neuron is
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
				 Iapp : in fp:=to_sfixed(0,fp_int,fp_frac));
end component;

	signal pattern : std_logic_vector(3 downto 1):=(others=>'0');
	signal out1,out2,initw:std_logic:='0';
	signal Iapp1,Iapp2: fp:=to_sfixed(0,fp_int,fp_frac);
begin

	N1 :  neuron generic map(Nsyn=>3,D=>(2,2,2)) port map(Iapp=>Iapp1,inputSpikes=>pattern,outputSpike=>out1,globalRst=>globalRst,clk=>clk,initW=>initW);
	N2 : 	neuron generic map(Nsyn=>3,D=>(2,2,2)) port map(Iapp=>Iapp2,inputSpikes=>pattern,outputSpike=>out2,globalRst=>globalRst,clk=>clk,initW=>initW);

end arch;

