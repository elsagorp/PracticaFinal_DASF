--------------------------------------------------------------------------------
--
-- Title       : 	Debounce Logic module
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : debouncer.vhd
-- Generated   : 7 February 2022
--------------------------------------------------------------------------------
-- Description : Given a synchronous signal it debounces it.
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 07/02/22  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;


architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
    -- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    
    -- -----------------------------------------------------------------------------
    -- Declarar un tipo para los estados de la fsm usando type
    -- -----------------------------------------------------------------------------
    -- Crear los estados
    type state_type is (IDLE,BTN_PRS,VALID,BTN_UNPRS);
    -- Registro para almacenar los estados
    signal PS, NS : state_type;

	signal counter: unsigned (c_counter_width-1 downto 0);
    -- Señal para indicar que el tiempo se cumplió
	signal time_elapsed: std_logic ;
    -- Señal para indicar que está en el estado en el que hay que contar
	signal enable_count: std_logic ;
	
    --registro para la salida
   signal debounced_reg: std_logic ;
    
begin
    --Timer
    Timer:process (clk, rst_n)
    begin
    -- -----------------------------------------------------------------------------
	-- Completar el timer que genera la señal de time_elapsed para trancionar en 
	-- las máquinas de estados
	-- -----------------------------------------------------------------------------
    --modificar con lo del delegado   
        if(rst_n= '0') then --Señal de reinicio 
               counter <= (others  => '0');
	            time_elapsed <= '0';
        elsif(rising_edge(clk)) then
            if(enable_count = '1')then

                if(counter < c_cycles)then 
                    counter <= counter + 1;
                
                else 
                    time_elapsed <= '1';
                    counter <= (others  => '0');
                end if;

            else 
                counter <= (others  => '0');
                time_elapsed <= '0';
          
            end if;
        end if;
    end process;

    --FSM Register of next state
   process (clk, rst_n)
    begin
           if(rst_n= '0') then --Señal de reinicio 
                PS <= IDLE;
                debounced<= '0';
           elsif(rising_edge(clk)) then
                debounced<= debounced_reg;
                PS <= NS;
           end if;
    end process;
	
    FSM:process (PS,sig_in,ena,time_elapsed)
    begin
 	case PS is
        when IDLE=>
            debounced_reg <= '0';
            enable_count <= '0';
		    if(sig_in = '1')then NS <= BTN_PRS;
		    else NS <= IDLE;
              end if;

	   when BTN_PRS=>
            --debounced_reg <= '0';
            enable_count <= '1';
            if(ena = '0')then  NS <= IDLE;
            elsif(time_elapsed = '1' and sig_in = '0')then  
                enable_count <= '0';
                NS <= IDLE;
            elsif(time_elapsed = '0')then  
                NS <= BTN_PRS;
            elsif(time_elapsed = '1' and sig_in = '1')then 
                 debounced_reg <= '1';
                NS <= VALID;
            end if;
        when VALID=>
            debounced_reg <= '0';
            enable_count <= '0';
            if(ena = '0')then  NS <= IDLE;
            elsif(sig_in = '0')then  NS <= BTN_UNPRS;
             end if;
	   when BTN_UNPRS=>
            debounced_reg <= '0';
            enable_count <= '1';
            if(ena = '0' or time_elapsed = '1')then 
                NS <= IDLE;
            elsif(time_elapsed = '0')then  NS <= BTN_UNPRS;
            end if;
      end case;
      
    end process;
end Behavioural;