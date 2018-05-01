library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;

package myTypes is
	constant fp_int : integer :=4;
	constant fp_frac : integer := -10;
	constant fp_bits : integer := fp_int-fp_frac+1;
	subtype fp is sfixed (fp_int downto fp_frac);

	type fp_array is array(natural range <>) of fp;
	type realArray is array(natural range <>) of real;
	type integerArray is array(natural range <>) of integer;
end package myTypes;
