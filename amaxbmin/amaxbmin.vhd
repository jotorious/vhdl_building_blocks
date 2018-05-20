-- ***************************************************************************
--  Template
-- ***************************************************************************

-- Library *******************************************************************

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_unsigned.all;

-- Entity Declaration ********************************************************

entity amaxbmin is
	port (
		clk		: in std_logic;
        rst     : in std_logic;
		nd		: in std_logic;
		din_i	: in std_logic_vector(15 downto 0);
		din_q	: in std_logic_vector(15 downto 0);
		mag_out	: out std_logic_vector(15 downto 0);
		rdy		: out std_logic
		);
end amaxbmin;

-- Architecture Declaration **************************************************

architecture amaxbmin_arch of amaxbmin is

-- component declarations

-- signal declarations
signal abs_i	: signed(15 downto 0);
signal abs_q	: signed(15 downto 0);
signal max  	: signed(15 downto 0);
signal min  	: signed(15 downto 0);
signal amax  	: signed(15 downto 0);
signal bmin  	: signed(15 downto 0);
signal mag  	: signed(15 downto 0);
signal nd_dly1, nd_dly2, nd_dly3, nd_dly4 : std_logic;


-- Arch begin
begin

main_proc: process(clk, rst)
begin
if rst = '1' then
    abs_i	<= (others => '0');
    abs_q	<= (others => '0');
    max  	<= (others => '0');
    min  	<= (others => '0');
    amax  	<= (others => '0');
    bmin  	<= (others => '0');
    mag  	<= (others => '0');
elsif rising_edge(clk) then
    if nd = '1' then
        if din_i(15) = '0' then
            abs_i <= signed(din_i);
        elsif din_i(15) = '1' then
            abs_i  <= (not(signed(din_i)) + 1);
        end if;
        if din_q(15) = '0' then
            abs_q <= signed(din_q);
        elsif din_q(15) = '1' then
            abs_q  <= (not(signed(din_q)) + 1);
        end if;
        nd_dly1 <= '1';
    else
        nd_dly1 <= '0';
    end if;
    if nd_dly1 = '1' then
        if abs_i < abs_q then
            min	<= abs_i;
            max <= abs_q;
        elsif abs_i > abs_q then
            max	<= abs_i;
            min <= abs_q;
        else
        
        end if;
        nd_dly2 <= '1';
    else
        nd_dly2 <= '0';
    end if;
    if nd_dly2 = '1' then
        -- 15/16 of Max = Max* (1 - 1/16)
        -- (1/16)* Max is Max rigthshifted by 4 bits
        amax <= max - ("0000" & max(15 downto 4));
        -- 13/32 of Min = Min* (1 - 1/2 - 1/32)
        bmin <= min - ("0" & min(15 downto 1)) - ("00000" & min(15 downto 5));
        nd_dly3 <= '1';
    else
        nd_dly3 <= '0';
    end if;
    if nd_dly3 = '1' then
        mag <= amax + bmin;
        nd_dly4 <= '1';
    else
        nd_dly4 <= '0';
    end if;
    if nd_dly4 = '1' then
        mag_out <= std_logic_vector(mag);
        rdy <= '1';
    else
        rdy <= '0';
    end if;
end if;
end process;

end amaxbmin_arch;
