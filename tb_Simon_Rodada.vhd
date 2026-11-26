
-- Testbench funcional da rodada unica (round = 0, z_bit = 1)
-- Vetores gerados pelo modelo de referencia em C (Apendice B)

library ieee;
use ieee.std_logic_1164.all;

entity tb_Simon_Rodada is
end entity;

architecture sim of tb_Simon_Rodada is

signal x_in, y_in, x_out, y_out : std_logic_vector (31 downto 0);
signal key_in, key_out : std_logic_vector (127 downto 0);
signal z_bit : std_logic := '1';

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

type vetor_t is record
	key   : std_logic_vector (127 downto 0);
	x, y  : std_logic_vector (31 downto 0);
	ex, ey: std_logic_vector (31 downto 0);
	ekey  : std_logic_vector (127 downto 0);
	z     : std_logic;
end record;
type vetores_t is array (natural range <>) of vetor_t;

constant VETORES : vetores_t (0 to 4) := (
		(x"1b1a1918131211100b0a090803020100", x"656b696c", x"20646e75", x"fc8b8a84", x"656b696c", x"70a011c31b1a1918131211100b0a0908", '1' ),
		(x"00000000000000000000000000000000", x"00000000", x"00000000", x"00000000", x"00000000", x"fffffffd000000000000000000000000", '1' ),
		(x"55555555aaaaaaaa55555555aaaaaaaa", x"aaaaaaaa", x"55555555", x"55555555", x"aaaaaaaa", x"5555555755555555aaaaaaaa55555555", '1' ),
		(x"ffffffffffffffffffffffffffffffff", x"ffffffff", x"ffffffff", x"00000000", x"ffffffff", x"00000002ffffffffffffffffffffffff", '1' ),
		(x"876543210fedcba99abcdef012345678", x"deadbeef", x"cafebabe", x"0f667aa7", x"deadbeef", x"12b3e45b876543210fedcba99abcdef0", '1' )
);

begin

DUT: 	Simon_Rodada
		 port map (x_in => x_in, y_in => y_in, key_in => key_in, z_bit => z_bit,
					  x_out => x_out, y_out => y_out, key_out => key_out);

process
	variable erros : natural := 0;
begin
	for n in VETORES'range loop
		key_in <= VETORES(n).key;
		x_in   <= VETORES(n).x;
		y_in   <= VETORES(n).y;
		z_bit  <= VETORES(n).z;
		wait for 10 ns;
		if (x_out = VETORES(n).ex and y_out = VETORES(n).ey and key_out = VETORES(n).ekey) then
			report "Vetor " & integer'image(n) & ": APROVADO";
		else
			report "Vetor " & integer'image(n) & ": REPROVADO" severity error;
			erros := erros + 1;
		end if;
	end loop;
	if (erros = 0) then
		report "TODOS OS VETORES APROVADOS";
	else
		report integer'image(erros) & " VETOR(ES) REPROVADO(S)" severity error;
	end if;
	wait;
end process;

end sim;
