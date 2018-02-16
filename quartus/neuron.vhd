library ieee;
library ieee_proposed;

--use model:
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
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
    signal Vn,aVn,Iapp_b1,Isyn_b1,sum_I,Vn1 : fp;
    signal b1,b2,alpha : fp := to_sfixed(1.0,4,-3);
    signal Vth : fp := to_sfixed(1.0,4,-3);
	
    begin 
		--b1 <= to_sfixed(1.0,fp_int,fp_frac);
		--alpha <= to_sfixed(1.0,fp_int,fp_frac);
		--b2 <= to_sfixed(1.0,fp_int,fp_frac);
		regV : register_fp generic map(bits=>fp_bits) port map (clk=>clk,rst=>spik,dataIn=>Vn1,dataOut=>Vn);
		compV : VthComparator port map(V=>Vn1,Vth=>Vth,spike=>spik);
		Vn1 <= resize(Iapp*b1 + Isyn*b2 + alpha*Vn,fp_int,fp_frac);
		spike <= spik;

end Behave;
