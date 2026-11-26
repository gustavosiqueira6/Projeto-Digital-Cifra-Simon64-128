
-- Quartus II VHDL Template
-- SIMON-64/128 - Funcao de rodada (rede Feistel)
-- x_out = y_in xor F(x_in) xor round_key ; y_out = x_in
-- F(x) = (rotl(x,1) and rotl(x,8)) xor rotl(x,2)

library ieee;
use ieee.std_logic_1164.all;

entity Simon_Feistel is

	port 
	(
		x_in	     : in std_logic_vector  (31 downto 0);
		y_in	     : in std_logic_vector  (31 downto 0);
		round_key  : in std_logic_vector  (31 downto 0);
		x_out	     : out std_logic_vector (31 downto 0);
		y_out	     : out std_logic_vector (31 downto 0)
	);

end entity;

architecture rtlBSN of Simon_Feistel is

signal outRotl1, outRotl8, outRotl2, outAnd, outF : std_logic_vector (31 downto 0);

begin

	-- Rotacoes a esquerda (apenas fiacao, nao gera logica)
	outRotl1 <= x_in(30 downto 0) & x_in(31);
	outRotl8 <= x_in(23 downto 0) & x_in(31 downto 24);
	outRotl2 <= x_in(29 downto 0) & x_in(31 downto 30);

	-- Funcao F
	outAnd <= outRotl1 and outRotl8;
	outF   <= outAnd xor outRotl2;

	-- Saidas da rodada
	x_out <= y_in xor outF xor round_key;
	y_out <= x_in;

end rtlBSN;
