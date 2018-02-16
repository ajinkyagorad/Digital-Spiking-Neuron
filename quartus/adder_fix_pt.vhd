-----------------------------------------------------------------------------
-- takes in fixed point numbers of form (n downto -m) in an array of size p
-- and gives a result of another fixed point number of the form (n+1 downto -m)
-----------------------------------------------------------------------------

library ieee;
library ieee_proposed;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.myTypes.all;

entity adder_fix_pt is
  generic ( p : integer;
			n : integer;
			m : integer);
  port ( a : in add_array(1 to p);
         b : out sfixed( n+1 downto -m )
		 );
end adder_fix_pt ;

architecture myarch1 of adder_fix_pt is
begin

	process(a)
		variable temp: sfixed( n+1 downto -m ); 
	begin
		temp:= to_sfixed(0,n+1,-m);
		loop1: for i in 1 to p loop
						temp:= temp(n downto -m) + a(i);
				 end loop;
		b <= temp;
	end process;
	
end myarch1 ;
