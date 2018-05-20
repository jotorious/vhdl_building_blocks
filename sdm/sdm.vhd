-- ***************************************************************************
--  Template
-- ***************************************************************************

-- Library *******************************************************************

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;

-- Entity Declaration ********************************************************

entity sdm is
	port (
		clk		: in std_logic;
		reset	: in std_logic;
		d_in	: in signed(11 downto 0);
		d_out	: out std_logic
		);
end sdm;

-- Architecture Declaration **************************************************

architecture behavioral of sdm is

-- signal declarations
signal delta		: unsigned(13 downto 0);
signal sigma		: unsigned(13 downto 0);
signal s_latched	: unsigned(13 downto 0);
signal s_quantized	: unsigned(13 downto 0);
signal seo_d_in		: unsigned(11 downto 0);
signal int_d_out	: std_logic;
-- Arch begin
begin
seo_d_in <= unsigned(not(d_in(11)) & d_in(10 downto 0));
s_quantized <= s_latched(13)  & s_latched(13) & x"000" ;
delta <= seo_d_in + s_quantized;
sigma <= delta + s_latched;

latch_proc: process(clk, reset)
	--body
	begin
	if reset = '1' then
		s_latched <= (others => '0');
		int_d_out <= '0';
	elsif rising_edge(clk) then
		s_latched <= sigma;
		int_d_out <= s_latched(13);
	end if;
end process;

d_out   <= int_d_out;

end behavioral;
