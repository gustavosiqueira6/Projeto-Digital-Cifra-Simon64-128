
-- Testbench funcional da arquitetura iterativa SIMON-64/128
-- Vetores gerados pelo modelo de referencia em C (Apendice B):
-- 0 = vetor oficial do SIMON; 1 = tudo zero; 2 = padroes alternados; 3 = tudo um; 4 = arbitrario

library ieee;
use ieee.std_logic_1164.all;

entity tb_Simon_Iter is
end entity;

architecture sim of tb_Simon_Iter is

constant PERIODO : time := 20 ns;

signal clk_top, reset_top, start_top, done_top : std_logic := '0';
signal x_top, y_top, x_out_top, y_out_top : std_logic_vector (31 downto 0) := (others=>'0');
signal key_top : std_logic_vector (127 downto 0) := (others=>'0');

signal state_view : std_logic_vector (2 downto 0);
signal ctrl_load_view, en_state_view, flag_last_view, zBit_view : std_logic;
signal outRegX_view, outRegY_view : std_logic_vector (31 downto 0);
signal outRegKey_view : std_logic_vector (127 downto 0);
signal outRegCnt_view : std_logic_vector (5 downto 0);

component Simon_Iter is
	port 
	(
		clk_top	  : in std_logic;
		reset_top  : in std_logic;
		start_top  : in std_logic;
		x_top	     : in std_logic_vector  (31 downto 0);
		y_top	     : in std_logic_vector  (31 downto 0);
		key_top    : in std_logic_vector  (127 downto 0);
		x_out_top  : out std_logic_vector (31 downto 0);
		y_out_top  : out std_logic_vector (31 downto 0);
		done_top   : out std_logic;
		state_view       : out std_logic_vector (2 downto 0);
		ctrl_load_view   : out std_logic;
		en_state_view    : out std_logic;
		flag_last_view   : out std_logic;
		outRegX_view     : out std_logic_vector (31 downto 0);
		outRegY_view     : out std_logic_vector (31 downto 0);
		outRegKey_view   : out std_logic_vector (127 downto 0);
		outRegCnt_view   : out std_logic_vector (5 downto 0);
		zBit_view        : out std_logic
	);
end component;

type vetor_t is record
	key   : std_logic_vector (127 downto 0);
	x, y  : std_logic_vector (31 downto 0);
	ex, ey: std_logic_vector (31 downto 0);
end record;
type vetores_t is array (natural range <>) of vetor_t;

constant VETORES : vetores_t (0 to 4) := (
		(x"1b1a1918131211100b0a090803020100", x"656b696c", x"20646e75", x"44c8fc20", x"b9dfa07a"),
		(x"00000000000000000000000000000000", x"00000000", x"00000000", x"edf1be0a", x"54d9bf51"),
		(x"55555555aaaaaaaa55555555aaaaaaaa", x"aaaaaaaa", x"55555555", x"53e8b277", x"f12b8b24"),
		(x"ffffffffffffffffffffffffffffffff", x"ffffffff", x"ffffffff", x"db15e84a", x"8daff32a"),
		(x"876543210fedcba99abcdef012345678", x"deadbeef", x"cafebabe", x"91a4ca92", x"3a578498")
);

begin

clk_top <= not clk_top after PERIODO/2;

DUT: 	Simon_Iter
		 port map (clk_top => clk_top, reset_top => reset_top, start_top => start_top,
					  x_top => x_top, y_top => y_top, key_top => key_top,
					  x_out_top => x_out_top, y_out_top => y_out_top, done_top => done_top,
					  state_view => state_view, ctrl_load_view => ctrl_load_view,
					  en_state_view => en_state_view, flag_last_view => flag_last_view,
					  outRegX_view => outRegX_view, outRegY_view => outRegY_view,
					  outRegKey_view => outRegKey_view, outRegCnt_view => outRegCnt_view,
					  zBit_view => zBit_view);

process
	variable erros  : natural := 0;
begin
	reset_top <= '1';
	wait for 2*PERIODO;
	reset_top <= '0';
	wait until rising_edge(clk_top);

	for n in VETORES'range loop
		key_top <= VETORES(n).key;
		x_top   <= VETORES(n).x;
		y_top   <= VETORES(n).y;
		start_top <= '1';
		wait until rising_edge(clk_top);
		start_top <= '0';

		-- espera o fim da cifragem
		while (done_top /= '1') loop
			wait until rising_edge(clk_top);
		end loop;

		if (x_out_top = VETORES(n).ex and y_out_top = VETORES(n).ey) then
			report "Vetor " & integer'image(n) & ": APROVADO";
		else
			report "Vetor " & integer'image(n) & ": REPROVADO" severity error;
			erros := erros + 1;
		end if;
		wait until rising_edge(clk_top);
		wait until rising_edge(clk_top);
	end loop;

	if (erros = 0) then
		report "TODOS OS VETORES APROVADOS";
	else
		report integer'image(erros) & " VETOR(ES) REPROVADO(S)" severity error;
	end if;
	wait;
end process;

end sim;
