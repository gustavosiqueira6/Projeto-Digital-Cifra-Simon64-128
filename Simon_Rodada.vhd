
-- Quartus II VHDL Template
-- SIMON-64/128 - Uma rodada completa (Fase 2)
-- Bloco combinacional: key schedule + funcao de rodada.
-- Este mesmo bloco e reutilizado como Parte Operativa na arquitetura iterativa.

library ieee;
use ieee.std_logic_1164.all;

entity Simon_Rodada is

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

end entity;

architecture rtlBSN of Simon_Rodada is

signal outRoundKey : std_logic_vector (31 downto 0);

component Simon_KeySch is

	port 
	(
		key_in	  : in std_logic_vector  (127 downto 0);
		z_bit	     : in std_logic;
		round_key  : out std_logic_vector (31 downto 0);
		key_out	  : out std_logic_vector (127 downto 0)
	);

end component;

component Simon_Feistel is

	port 
	(
		x_in	     : in std_logic_vector  (31 downto 0);
		y_in	     : in std_logic_vector  (31 downto 0);
		round_key  : in std_logic_vector  (31 downto 0);
		x_out	     : out std_logic_vector (31 downto 0);
		y_out	     : out std_logic_vector (31 downto 0)
	);

end component;

begin

KeySch: 	Simon_KeySch
			 port map (key_in => key_in, z_bit => z_bit, round_key => outRoundKey, key_out => key_out);

Feistel: Simon_Feistel
			 port map (x_in => x_in, y_in => y_in, round_key => outRoundKey, x_out => x_out, y_out => y_out);

end rtlBSN;
