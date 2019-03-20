library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
--use     ieee.numeric_std_unsigned.all;

entity async_fifo is
	generic (
		width : integer := 16;
		depth : integer := 8
		);
	port (
		wr_data	: in std_logic_vector(width-1 downto 0);
		rd_data	: out std_logic_vector(width-1 downto 0);
		wr_clk	: in std_logic;
		wr_en		: in std_logic;
		rd_clk	: in std_logic;
		rd_en		: in std_logic;
		full		: out std_logic;
		empty		: out std_logic;
		wr_rst    : in std_logic;
		rd_rst    : in std_logic
		);
end async_fifo;

architecture beh of async_fifo is

component bin2gray
	generic (
		n : integer := 4;
		dir : std_logic:= '1'
		);
	port (
		data_in : in std_logic_vector(n-1 downto 0);
		data_out : out std_logic_vector(n-1 downto 0)
		);
end component;


type ram_type is array (0 to depth - 1) of std_logic_vector(width -1 downto 0);
signal ram : ram_type;

constant addr_width : integer := 3;

signal wr_addr_wrdo			: std_logic_vector(addr_width -1 downto 0);
signal wr_addr_wrdo_gray	: std_logic_vector(addr_width -1 downto 0);
signal wr_addr_rddo_gray_ms: std_logic_vector(addr_width -1 downto 0);
signal wr_addr_rddo_gray	: std_logic_vector(addr_width -1 downto 0);
signal wr_addr_rddo			: std_logic_vector(addr_width -1 downto 0);
signal count_rddo			: std_logic_vector(addr_width -1 downto 0);

signal rd_addr_rddo			: std_logic_vector(addr_width -1 downto 0);
signal rd_addr_rddo_gray	: std_logic_vector(addr_width -1 downto 0);
signal rd_addr_wrdo_gray_ms: std_logic_vector(addr_width -1 downto 0);
signal rd_addr_wrdo_gray	: std_logic_vector(addr_width -1 downto 0);
signal rd_addr_wrdo			: std_logic_vector(addr_width -1 downto 0);
signal count_wrdo			: std_logic_vector(addr_width -1 downto 0);

signal full_i, empty_i : std_logic;

begin

---------------------------------
-- Write Domain
---------------------------------

-- RAM
write_proc:process(wr_clk)
begin
if rising_edge(wr_clk) then
    if wr_rst = '1' then
	   wr_addr_wrdo <= (others =>'0');
    else
	   if wr_en = '1' and full_i = '0' then
		  ram(to_integer(unsigned(wr_addr_wrdo)))	<= wr_data;
		  wr_addr_wrdo <= std_logic_vector(unsigned(wr_addr_wrdo) + 1);
	   end if;
   end if;
end if;
end process;

-- encode wr_addr to gray for passing to read domain
wr_addr_b2g: bin2gray
	generic map(
		n => 4,
		dir => '1')
	port map(
		data_in => wr_addr_wrdo,
		data_out=> wr_addr_wrdo_gray
		);

-- Synchronize grey encoded rd_addr from read domain
wr_flop_sync_proc:process(wr_clk)
begin
if rising_edge(wr_clk) then
	if wr_rst = '1' then
	   rd_addr_wrdo_gray_ms	<= (others=>'0');
	   rd_addr_wrdo_gray			<= (others=>'0');
    else
        rd_addr_wrdo_gray_ms	<= rd_addr_rddo_gray;
	   rd_addr_wrdo_gray		<= rd_addr_wrdo_gray_ms;
    end if;
end if;
end process;

-- decode rd_addr from grey to binary

rd_addr_g2b: bin2gray
	generic map(
		n => 4,
		dir => '0')
	port map(
		data_in => rd_addr_wrdo_gray,
		data_out=> rd_addr_wrdo
		);

count_wrdo <= std_logic_vector(unsigned(wr_addr_wrdo) - unsigned(rd_addr_wrdo));

full_i <= '1' when unsigned(count_wrdo) = 6 else '0';
full <= full_i;

-------------------------------------
-- Read Domain
------------------------------------

-- RAM
read_proc:process(rd_clk)
begin
if rising_edge(rd_clk) then
	if rd_rst = '1' then
	   rd_addr_rddo <= (others =>'0');
    else
        if rd_en = '1' and empty_i = '0' then
		  rd_data <= ram(to_integer(unsigned(rd_addr_rddo)));
		  rd_addr_rddo <= std_logic_vector(unsigned(rd_addr_rddo) + 1);  
		end if;
	end if;
end if;
end process;

-- encode rd_addr to gray for passing to wr domain
rd_addr_b2g: bin2gray
	generic map(
		n => 4,
		dir => '1')
	port map(
		data_in => rd_addr_rddo,
		data_out=> rd_addr_rddo_gray
		);
		
-- Synchronize grey encoded wr_addr from write domain
rd_flop_sync_proc:process(rd_clk)
begin
if rising_edge(rd_clk) then
    if rd_rst = '1' then
	   wr_addr_rddo_gray_ms	<= (others=>'0');
	   wr_addr_rddo_gray			<= (others=>'0');
    else
	   wr_addr_rddo_gray_ms	<= wr_addr_wrdo_gray;
	   wr_addr_rddo_gray	<= wr_addr_rddo_gray_ms;
    end if;
end if;
end process;

-- encode wr_addr to gray for passing to read domain
wr_addr_g2b: bin2gray
	generic map(
		n => 4,
		dir => '0')
	port map(
		data_in => wr_addr_rddo_gray,
		data_out=> wr_addr_rddo
		);

count_rddo <= std_logic_vector(unsigned(wr_addr_rddo) - unsigned(rd_addr_rddo));

empty_i <= '1' when unsigned(count_rddo) = 0 else '0';
empty <= empty_i;
		
end beh;