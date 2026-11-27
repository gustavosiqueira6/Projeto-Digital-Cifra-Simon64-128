
-- Quartus II VHDL Template
-- SIMON-64/128 - Um passo do key schedule
-- key_in  = janela corrente: k3 & k2 & k1 & k0 (k0 = round key atual)
-- key_out = janela seguinte: nova_palavra & k3 & k2 & k1

library ieee;
use ieee.std_logic_1164.all;

entity Simon_KeySch is

	port 
	(
		key_in	  : in std_logic_vector  (127 downto 0);
		z_bit	     : in std_logic;
		round_key  : out std_logic_vector (31 downto 0);
		key_out	  : out std_logic_vector (127 downto 0)
	);

end entity;

architecture RTLGSPT of Simon_KeySch is

signal k0, k1, k2, k3 : std_logic_vector (31 downto 0);
signal outRotr3, outXorK1, outRotr1, outNewKey : std_logic_vector (31 downto 0);
signal zWord : std_logic_vector (31 downto 0);
constant SIMON_C : std_logic_vector (31 downto 0) := x"FFFFFFFC";

begin

	k0 <= key_in(31 downto 0);
	k1 <= key_in(63 downto 32);
	k2 <= key_in(95 downto 64);
	k3 <= key_in(127 downto 96);

	-- temp = rotr(k3,3) ; new_key = k0 xor temp xor k1 xor rotr(temp xor k1,1) xor C xor z
	outRotr3  <= k3(2 downto 0) & k3(31 downto 3);
	outXorK1  <= outRotr3 xor k1;
	outRotr1  <= outXorK1(0) & outXorK1(31 downto 1);

	zWord     <= (0=>z_bit, others=>'0');
	outNewKey <= k0 xor outXorK1 xor outRotr1 xor SIMON_C xor zWord;

	-- Saidas
	round_key <= k0;
	key_out   <= outNewKey & k3 & k2 & k1;

end RTLGSPT;
