library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
library work;
use work.myTypes.all;

entity neuron is
    port (
	Iapp,Isyn : in fp;
	clk : in std_logic;
	spike: out std_logic);
end entity;

architecture Behave of neuron is

   component register_fp
    generic(bits :natural :=4);
    port(
         clk : in std_logic;
			rst : in std_logic;
			dataIn : in fp;
			dataOut : out fp
        );
    end component;
	 
	 component VthComparator is
		generic(bits: natural:=8);
		port( V,Vth : in fp;
				spike: out std_logic);
	 end component;

	 signal spik : std_logic;
	 signal Vn,Vn1 : fp := to_sfixed(0.0,4,-3);
    signal b1,b2,alpha : fp := to_sfixed(1.0,4,-3);
    signal Vth : fp := to_sfixed(3.0,4,-3);
	
    begin 
		regV : register_fp generic map(bits=>fp_bits) port map (clk=>clk,rst=>spik,dataIn=>Vn1,dataOut=>Vn);
		compV : VthComparator port map(V=>Vn,Vth=>Vth,spike=>spik);
		Vn1 <= resize(Iapp*b1 + Isyn*b2 + alpha*Vn,fp_int,fp_frac);
		spike <= spik;

end Behave;

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

entity wrapper_neuron is
    port (
	Iapp,Isyn : in std_logic_vector (7 downto 0);
	clk : in std_logic;
	spike: out std_logic);
end entity;

architecture behave of wrapper_neuron is 

	component neuron is
    	port (
		Iapp,Isyn : in fp;
		clk : in std_logic;
		spike: out std_logic);
	end component;

	signal Iapp_fp, Isyn_fp: fp:=(others => '0');
	
begin
	Iapp_fp <= to_sfixed(Iapp, fp_int, fp_frac);
	Isyn_fp <= to_sfixed(Isyn, fp_int, fp_frac);
	neuron_instance: neuron port map(Iapp_fp, Isyn_fp, clk, spike);

end behave;

