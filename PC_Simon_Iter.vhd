
library ieee;
use ieee.std_logic_1164.all;

entity PC_Simon_Iter is
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
END PC_Simon_Iter;

architecture BEHAVIOR of PC_Simon_Iter is

   type type_state is (ESPERA, CARGA, RODADAS, FIM);
   
   signal state, next_state: type_state;

begin

	 -- Registrador de estado (reset assincrono)
    process (clock, reset)
    begin
		  if (reset = '1') then
				state <= ESPERA;
		  elsif (rising_edge(clock)) then
				state <= next_state;
		  end if;
    end process;

	 -- Logica de proximo estado
    process (state, start, flag_last)
    begin
		  case state is
				when ESPERA =>
					 if (start = '1') then
						  next_state <= CARGA;
					 else
						  next_state <= ESPERA;
					 end if;
				when CARGA =>
					 next_state <= RODADAS;
				when RODADAS =>
					 if (flag_last = '1') then
						  next_state <= FIM;
					 else
						  next_state <= RODADAS;
					 end if;
				when FIM =>
					 next_state <= ESPERA;
		  end case;
    end process;
	 
	 -- Logica de saida (Moore)
    process (state)
    begin
		  ctrl_load  <= '0';
		  en_state   <= '0';
		  done 		 <= '0';
		  case state is
				when ESPERA =>
					 state_view <= "000";
				when CARGA =>
					 ctrl_load  <= '1';
					 en_state   <= '1';
					 state_view <= "001";
				when RODADAS =>
					 en_state   <= '1';
					 state_view <= "010";
				when FIM =>
					 done 		  <= '1';
					 state_view <= "011";
		  end case;
    end process;       
	 
end behavior;
