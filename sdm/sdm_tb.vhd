
-- Library *******************************************************************

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_textio.all;

library std;
use STD.textio.all;

-- Entity Declaration ********************************************************

entity sdm_tb is
end sdm_tb;

architecture tb of sdm_tb is

component sdm
	port (
		clk		: in std_logic;
		reset	: in std_logic;
		d_in	: in signed(11 downto 0);
		d_out	: out std_logic
		);
end component;

file infile : text open read_mode is "sdm_stim.txt";


signal signal_in : std_logic_vector(15 downto 0);
signal tb_in_data : signed(11 downto 0);
signal tb_out_data : std_logic;

signal tb_clk : std_logic;
signal tb_rst : std_logic;

constant clkperiod: time := 76 ns;

begin



clk_proc: process
	begin
		wait for clkperiod/2;
		tb_clk <= '1';
		wait for clkperiod/2;
		tb_clk <= '0';
end process;

rst_proc: process
	begin
		wait for 4* clkperiod;
		tb_rst <= '1';
		wait for clkperiod;
		tb_rst <= '0';
		wait;
end process;


dut: sdm
	port map (
		clk		=> tb_clk,
		reset	=> tb_rst,
		d_in	=> tb_in_data,
		d_out	=> tb_out_data
		);

readVec: process (tb_clk)
	variable inline: line;
	variable vvalid: boolean;
	-- 
	variable indata: std_logic_vector(15 downto 0);
	
	begin
	if falling_edge(tb_clk) then
		if not endfile(infile) then
			readline(infile,inline);
			hread(inline,indata);
			signal_in <= indata;
			tb_in_data <= signed(signal_in(11 downto 0));
		end if;
	end if;
end process;


end tb;
		
		

