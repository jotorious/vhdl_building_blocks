-- Library *******************************************************************

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_textio.all;
use     ieee.math_real.all;

library std;
use STD.textio.all;

-- Entity Declaration ********************************************************

entity amaxbmin_tb is

end amaxbmin_tb;

-- Architecture Declaration **************************************************

architecture amaxbmin_tb_arch of amaxbmin_tb is

component amaxbmin
	port (
		clk		: in std_logic;
        rst     : in std_logic;
		nd		: in std_logic;
		din_i	: in std_logic_vector(15 downto 0);
		din_q	: in std_logic_vector(15 downto 0);
		mag_out	: out std_logic_vector(15 downto 0);
		rdy		: out std_logic
		);
end component;


--file infile : text open read_mode is "pll_16apsk_lf_enable.txt";
--file outfile : text open write_mode is "pll_qpsk_op.txt";
--file phasefile : text open read_mode is "pll_carrier_phase.txt";

signal tb_clk		    : std_logic;
signal tb_rst            : std_logic;
signal tb_en            : std_logic;

-- signal tb_i_in	        : std_logic_vector(15 downto 0);
-- signal tb_q_in	        : std_logic_vector(15 downto 0);

-- signal tb_mod_type	    : std_logic_vector(3 downto 0);

-- signal tb_phase_in	        : std_logic_vector(15 downto 0);

-- signal tb_i_out	        : std_logic_vector(15 downto 0);
-- signal tb_q_out	        : std_logic_vector(15 downto 0);
 
-- signal tb_bits_out	    : std_logic_vector(3 downto 0);
-- signal eof_signal       : std_logic; 

signal timebase : real := 0.0;
signal cosine :    real;
signal sine : real;

begin

clk_proc: process
	begin
        tb_clk <= '1';
		wait for 1.5875 ns;
		tb_clk <= '0';
		wait for 1.5875 ns;
end process;

rst_proc: process
	begin
        tb_rst <= '1';
        tb_en <= '1';
		wait for 6 ns;
		tb_rst <= '0';
		wait ;
end process;


real_proc: process
begin
    wait for 1 us;
    timebase <= timebase + 1.0 ;
    cosine <= cos(2.0*MATH_PI*1000.0*timebase);
    sine <= sin(2.0*MATH_PI*1000.0*timebase);
end process;
    
end amaxbmin_tb_arch;
