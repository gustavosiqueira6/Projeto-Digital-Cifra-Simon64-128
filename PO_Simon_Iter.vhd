
-- Quartus II VHDL Template
-- SIMON-64/128 - Parte Operativa da arquitetura iterativa
-- Uma rodada por ciclo, reutilizando o bloco Simon_Rodada

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PO_Simon_Iter is

	port 
	(
	-- Portas principais 
		clk		  : in std_logic;
		x_PO	     : in std_logic_vector  (31 downto 0);
		y_PO	     : in std_logic_vector  (31 downto 0);
		key_PO     : in std_logic_vector  (127 downto 0);
		Ctrl_load  : in std_logic;
		En_state   : in std_logic;
		Flag_last  : out std_logic;
		x_out_PO   : out std_logic_vector (31 downto 0);
		y_out_PO   : out std_logic_vector (31 downto 0);

	-- Portas de depuração
		outRegX_view   : out std_logic_vector (31 downto 0);
		outRegY_view   : out std_logic_vector (31 downto 0);
		outRegKey_view : out std_logic_vector (127 downto 0);
		outRegCnt_view : out std_logic_vector (5 downto 0);
		zBit_view      : out std_logic
	);

end entity;

architecture rtlBSN of PO_Simon_Iter is

signal outMuxX, outMuxY, outRegX, outRegY, outRodadaX, outRodadaY : std_logic_vector  (31 downto 0);
signal outMuxKey, outRegKey, outRodadaKey : std_logic_vector  (127 downto 0);
signal outMuxCnt, outAddCnt, outRegCnt : std_logic_vector  (5 downto 0);
signal zBit : std_logic;

signal one  : std_logic_vector  (5 downto 0) := (0=>'1', others=>'0');
signal zero : std_logic_vector  (5 downto 0) := (others=>'0');

-- Ultima rodada = 43 (rodadas 0 a 43 = 44 rodadas)
constant LAST_ROUND : std_logic_vector (5 downto 0) := "101011";

-- Sequencia z3 (bit menos significativo usado primeiro)
constant SIMON_Z3 : std_logic_vector (63 downto 0) := x"FC2CE51207A635DB";


component Reg is

	generic
	(
		DATA_WIDTH : natural := 8
	);

	port 
	(
		clk		: in std_logic;
		enable	: in std_logic;
		input	   : in std_logic_vector((DATA_WIDTH-1) downto 0);
		output   : out std_logic_vector((DATA_WIDTH-1) downto 0)
	);

end component;


component adder is

	generic
	(
		DATA_WIDTH : natural := 8
	);

	port 
	(
		a	   : in std_logic_vector((DATA_WIDTH-1) downto 0);
		b	   : in std_logic_vector  ((DATA_WIDTH-1) downto 0);
		result : out std_logic_vector ((DATA_WIDTH-1) downto 0)
	);

end component;


component mux2p1 is

	generic
	(
		DATA_WIDTH : natural := 8
	);

	port 
	(
		a	   : in std_logic_vector  ((DATA_WIDTH-1) downto 0);
		b	   : in std_logic_vector  ((DATA_WIDTH-1) downto 0);
		sel   : in std_logic;
		result : out std_logic_vector ((DATA_WIDTH-1) downto 0)
	);

end component;


component Simon_Rodada is

	port 
	(
		x_in	  : in std_logic_vector  (31 downto 0);
		y_in	  : in std_logic_vector  (31 downto 0);
		key_in  : in std_logic_vector  (127 downto 0);
		z_bit	  : in std_logic;
		x_out	  : out std_logic_vector (31 downto 0);
		y_out	  : out std_logic_vector (31 downto 0);
		key_out : out std_logic_vector (127 downto 0)
	);

end component;


begin

-- Ctrl_load = '1' carrega as entradas; '0' realimenta a saida da rodada
MuxX: 	Mux2p1
			 generic map (DATA_WIDTH => 32)
			 port map (a => outRodadaX, b => x_PO, sel => Ctrl_load, result => outMuxX);

MuxY: 	Mux2p1
			 generic map (DATA_WIDTH => 32)
			 port map (a => outRodadaY, b => y_PO, sel => Ctrl_load, result => outMuxY);

MuxKey: 	Mux2p1
			 generic map (DATA_WIDTH => 128)
			 port map (a => outRodadaKey, b => key_PO, sel => Ctrl_load, result => outMuxKey);

MuxCnt: 	Mux2p1
			 generic map (DATA_WIDTH => 6)
			 port map (a => outAddCnt, b => zero, sel => Ctrl_load, result => outMuxCnt);

RegX: 	Reg
			 generic map (DATA_WIDTH => 32)
			 port map (clk => clk, enable => En_state, input => outMuxX, output => outRegX);

RegY: 	Reg
			 generic map (DATA_WIDTH => 32)
			 port map (clk => clk, enable => En_state, input => outMuxY, output => outRegY);

RegKey: 	Reg
			 generic map (DATA_WIDTH => 128)
			 port map (clk => clk, enable => En_state, input => outMuxKey, output => outRegKey);

RegCnt: 	Reg
			 generic map (DATA_WIDTH => 6)
			 port map (clk => clk, enable => En_state, input => outMuxCnt, output => outRegCnt);

AddCnt: 	Adder
			 generic map (DATA_WIDTH => 6)
			 port map (a => outRegCnt, b => one, result => outAddCnt);

Rodada: 	Simon_Rodada
			 port map (x_in => outRegX, y_in => outRegY, key_in => outRegKey, z_bit => zBit,
						  x_out => outRodadaX, y_out => outRodadaY, key_out => outRodadaKey);

-- Bit z3 da rodada corrente (indice = contador de rodadas)
zBit <= SIMON_Z3(to_integer(unsigned(outRegCnt)));

-- Sinal de status para a Parte de Controle
Flag_last <= '1' when outRegCnt = LAST_ROUND else '0';

x_out_PO <= outRegX;
y_out_PO <= outRegY;

outRegX_view   <= outRegX;
outRegY_view   <= outRegY;
outRegKey_view <= outRegKey;
outRegCnt_view <= outRegCnt;
zBit_view      <= zBit;

end rtlBSN;
