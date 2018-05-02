--this is the file that contains the types and subtypes that are used in the project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;

package myTypes is
	constant fp_int : integer :=4; --fp_int is the number of integer bits in the fixed point representation
	constant fp_frac : integer := -10; --fp_frac is the number of fractional bits in the fixed point representation
	constant fp_bits : integer := fp_int-fp_frac+1; --fp_bits is the total number of bits in the fixed point representation
	subtype fp is sfixed (fp_int downto fp_frac); --fp is the fixed point number implemented using the ieee_proposed library sfixed

	type fp_array is array(natural range <>) of fp;
	type realArray is array(natural range <>) of real;
	type integerArray is array(natural range <>) of integer;
end package myTypes;
