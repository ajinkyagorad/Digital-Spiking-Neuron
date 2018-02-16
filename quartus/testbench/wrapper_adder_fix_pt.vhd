------------------------------------------------
library ieee;
library ieee_proposed;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;

package myTypes is
	constant fp_int : natural :=4;
	constant fp_frac : natural :=3;
	type add_array is array(integer range <>) of sfixed(fp_int downto -fp_frac);  -- pg 2-6 VHDL-Codebook
	type std_add_array is array(integer range <>) of std_logic_vector(fp_int + fp_frac downto 0);  
end package myTypes;

----------------------------------------------------
library ieee;
library ieee_proposed;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.fixed_pkg.all;
use work.myTypes.all;

-- this is actually a wrapper for fix_pt_adder
entity wrapper_adder_fix_pt is
	 port(inp : in std_add_array(1 to 2);
          result : out std_logic_vector(8 downto 0)
			);
end wrapper_adder_fix_pt ;

architecture myarch of wrapper_adder_fix_pt is

	component adder_fix_pt is
	    generic ( p : integer;
					n : integer;
					m : integer);
	    port ( a : in add_array(1 to p);
				b : out sfixed( n+1 downto -m )
			 );
	end component adder_fix_pt ;

	signal z: sfixed(5 downto -3):=(others => '0');
	signal w: add_array(1 to 2);
	
begin

	adder_wrap: adder_fix_pt generic map(p=>2, n=>4, m=>3) port map(a=>w,b=>z);

	w(1)<=to_sfixed(inp(1),w(1));
	w(2)<=to_sfixed(inp(2),w(2));

	result<=to_slv(z);	

end myarch ;


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
