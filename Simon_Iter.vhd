
-- Quartus II VHDL Template
-- SIMON-64/128 - Arquitetura iterativa (1 rodada por ciclo)
-- Top-level: Parte de Controle (FSM) + Parte Operativa

library ieee;
use ieee.std_logic_1164.all;

entity Simon_Iter is

	port 
	(
	-- Portas principais 
		clk_top	  : in std_logic;
		reset_top  : in std_logic;
		start_top  : in std_logic;
		x_top	     : in std_logic_vector  (31 downto 0);
		y_top	     : in std_logic_vector  (31 downto 0);
		key_top    : in std_logic_vector  (127 downto 0);
		x_out_top  : out std_logic_vector (31 downto 0);
		y_out_top  : out std_logic_vector (31 downto 0);
		done_top   : out std_logic;

	-- Portas de depuração
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

end entity;

architecture rtlBSN of Simon_Iter is

signal ctrl_load_conect, en_state_conect, flag_last_conect : std_logic;


COMPONENT PC_Simon_Iter IS
    PORT (
		  -- Portas principais
		  reset 	  : IN STD_LOGIC := '0';
		  clock 	  : IN STD_LOGIC;
		  start 	  : IN STD_LOGIC;
		  flag_last : IN STD_LOGIC;
		  ctrl_load : OUT STD_LOGIC;
		  en_state  : OUT STD_LOGIC;
		  done 	  : OUT STD_LOGIC;

		  -- Portas de depuração
		  state_view : OUT STD_LOGIC_VECTOR (2 downto 0)
    );
END COMPONENT;

component PO_Simon_Iter is

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

end component;

begin
			 
PC: 	PC_Simon_Iter
			 port map (
						  reset => reset_top,
						  clock => clk_top,
						  start => start_top,
						  flag_last => flag_last_conect,
						  ctrl_load => ctrl_load_conect,
						  en_state => en_state_conect,
						  done => done_top,
						  state_view => state_view
						);

PO: 	PO_Simon_Iter
			 port map (
						-- Portas principais
							clk => clk_top,
							x_PO => x_top,
							y_PO => y_top,
							key_PO => key_top,
							Ctrl_load => ctrl_load_conect,
							En_state => en_state_conect,
							Flag_last => flag_last_conect,
							x_out_PO => x_out_top,
							y_out_PO => y_out_top,

						-- Portas de depuração
							outRegX_view => outRegX_view,
							outRegY_view => outRegY_view,
							outRegKey_view => outRegKey_view,
							outRegCnt_view => outRegCnt_view,
							zBit_view => zBit_view
						);

ctrl_load_view <= ctrl_load_conect;
en_state_view  <= en_state_conect;
flag_last_view <= flag_last_conect;

end rtlBSN;
