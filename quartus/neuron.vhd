
-- Neuron --
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;
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
