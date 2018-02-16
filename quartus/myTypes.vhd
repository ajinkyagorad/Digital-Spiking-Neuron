library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.all;

package myTypes is
constant fp_int : natural :=4;
constant fp_frac : natural := -3;
constant fp_bits : natural :=fp_int-fp_frac+1;
type fp sfixed (fp_int downto fp_frac);
end package myTypes;
