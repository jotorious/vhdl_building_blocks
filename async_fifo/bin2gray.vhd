-- Bit Systems
-- Joseph McKinney
-- 10/25/2016
--

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity bin2gray is
	generic (
		n : integer := 4;
		dir : std_logic:= '1'
		);
	port (
		data_in : in std_logic_vector(n-1 downto 0);
		data_out : out std_logic_vector(n-1 downto 0)
		);
end bin2gray;

architecture beh of bin2gray is

signal i_data_out : std_logic_vector(n-1 downto 0);

begin

--	if dir = '1' generate
--	begin
--		i_data_out(n-1) <= data_in(n-1);
--		i_data_out(n-2) <= data_in(n-2) xor data_in(n-1);
--		i_data_out(n-3) <= data_in(n-3) xor data_in(n-2);
--		i_data_out(n-4) <= data_in(n-4) xor data_in(n-3);
--	end generate;

--	if dir = '0' generate
--	begin
--		i_data_out(n-1) <= data_in(n-1);
--		i_data_out(n-2) <= data_in(n-2) xor i_data_out(n-1);
--		i_data_out(n-3) <= data_in(n-3) xor i_data_out(n-2);
--		i_data_out(n-4) <= data_in(n-4) xor i_data_out(n-3);
--	end generate;

--	data_out <= i_data_out;

	gen_b2g:if dir = '1' generate
	begin
		
		i_data_out(n-1) <= data_in(n-1);
		b2g_bits:for i in n-2 downto 0 generate
		begin
			i_data_out(i) <= data_in(i) xor data_in(i+1);
		end generate;
	end generate;

	gen_g2b:if dir = '0' generate
	begin
		i_data_out(n-1) <= data_in(n-1);
		g2b_bits:for i in n-2 downto 0 generate
		begin
			i_data_out(i) <= data_in(i) xor i_data_out(i+1);
		end generate;
	end generate;

	data_out <= i_data_out;

end architecture beh;



