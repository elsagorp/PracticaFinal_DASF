--------------------------------------------------------------------------------
--
-- Title       : 	FSM for the Synchronous clock
-- Design      :	Synchronous Clock generator
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : fsm_sclk.vhd
-- Generated   : 20 February 2022
--------------------------------------------------------------------------------
-- Description : Generates a synchronous clock (SCLK) and a rising/falling edge 
--				signal (SCLK_rise/ SCLK_fall) it has a negative asynchronous 
--				reset (n_rst) and a generic to indicate the period of the 
-- 				synchronous clock.  

--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 20/02/22  :| First version

-- -----------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
ENTITY fsm_sclk IS
	GENERIC (
		g_freq_SCLK_KHZ : INTEGER := 1500000; -- Frequency in KHz of the 
		--synchronous generated clk
		g_system_clock : INTEGER := 100000000 --Frequency in KHz of the system clk
	);
	PORT (
		rst_n : IN STD_LOGIC; -- asynchronous reset, low active
		clk : IN STD_LOGIC; -- system clk
		start : IN STD_LOGIC; -- signal to start the synchronous clk
		SCLK : OUT STD_LOGIC;-- Synchronous clock at the g_freq_SCLK_KHZ
		SCLK_rise : OUT STD_LOGIC;-- one cycle signal of the rising edge of SCLK
		SCLK_fall : OUT STD_LOGIC -- one cycle signal of the falling edge of SCLK
	);
END fsm_sclk;

ARCHITECTURE behavioural OF fsm_sclk IS

	-- Tenéis que hacer la conversion necesaria para sacar la constante que indique
	--	el número de ciclos para medio periodo del SCLK. Debéis usar floor 
	-- para el redondeo (que opera con reales)
	CONSTANT c_half_T_SCLK : INTEGER := INTEGER(floor(real(g_system_clock)/real(g_freq_SCLK_KHZ))); --constant value to compare and generate the rising/falling edge 
	CONSTANT c_counter_width : INTEGER := INTEGER(ceil(log2(real(c_half_T_SCLK)))); -- the width of the counter, take as reference the debouncer --g_system_clock
	--FSM tiene tres estados, lo sabemos por el ASM
	type state_type is (S0,S1,S2);
    -- Registro para almacenar los estados
    signal PS, NS : state_type;
	--Creamos el generador de reloj CNT
	signal CNT: unsigned (c_counter_width-1 downto 0);
	-- Señal para saber si CNT = c_half_T_SCLK llamada time_elapsed
	signal time_elapsed : std_logic;
	    -- Se�al para indicar que est� en el estado en el que hay que contar
	signal enable_count: std_logic ;

BEGIN
	Estados:PROCESS (clk, rst_n)
	BEGIN
		IF (rst_n = '0') THEN
			PS <= S0;
		ELSIF rising_edge(clk) THEN
			PS<= NS;
		END IF;
	END PROCESS;

	Contador:PROCESS (clk, rst_n)
	BEGIN
		if(rst_n= '0') then --Señal de reinicio 
			CNT <= (others  => '0');
			time_elapsed <= '0';

		elsif(rising_edge(clk)) then
			if(enable_count = '1')then
				if(CNT < c_half_T_SCLK)then 
					CNT <= CNT + 1;
				
				else 
					time_elapsed <= '1';
					CNT <= (others  => '0');
				end if;

			else 
				CNT <= (others  => '0');
				time_elapsed <= '0';

			end if;
		end if;
	END PROCESS;

	FSM:process(PS, time_elapsed, start,CNT,rst_n)
	begin
		if(rst_n = '0') then
			SCLK<='0';
			SCLK_rise <= '0';
			SCLK_fall <= '0';
		end if;
		case PS is
			--Estado IDLE
			when S0 =>
			    SCLK_fall <= '0';
			    SCLK_rise <= '0';
				enable_count <= '0';
				if(start = '1')then NS <= S1;
				else NS <= S0;
				end if;

			--Estado para detectar flanco de subida del reloj SCLK
			when S1 =>
				SCLK <= '0';
				enable_count <= '1';
				if(time_elapsed = '1')then  
					enable_count <= '0';
					SCLK_rise <= '1';
					NS <= S2;
				elsif(time_elapsed = '0')then  
					NS <= S1;
				end if;
			--Estado para detectar flanco de bajada del reloj SCLK
			WHEN S2 =>
				SCLK <= '1';
				SCLK_rise <= '0';
				enable_count <= '1';
				if(time_elapsed = '1')then  
					enable_count <= '0';
					SCLK_fall <= '1';
					NS <= S0;
				elsif(time_elapsed = '0')then  
					NS <= S2;
				end if;
		end case;
	end process;
END behavioural;