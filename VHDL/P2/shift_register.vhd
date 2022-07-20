LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ShiftRegister IS
    GENERIC (g_N : INTEGER := 5);
    PORT (
        d_in : IN STD_LOGIC;   -- Valor de entrada que se añadira al registro 
        D : IN STD_LOGIC_VECTOR (g_N - 1 DOWNTO 0);     -- Entrada de datos para la carga en paralelo
        rst_n : in STD_LOGIC;   --Reset
        s0 : IN STD_LOGIC;      --Selector0  junto con S1 serán los que decidan que operación realizar 
        S1 : IN STD_LOGIC;      --Selector1
        clk : IN STD_LOGIC;         --Señal de reloj
        Q : OUT STD_LOGIC_VECTOR (g_N - 1 DOWNTO 0);  --Valor en tiempo real del registro interno
        d_out : OUT STD_LOGIC);    --Valor de salida del registro
END ShiftRegister;
ARCHITECTURE Behavioral OF ShiftRegister IS

-- Funcionara como regisros para hacer de registro de desplazamiento 
signal internal_value : std_logic_vector (g_N - 1 DOWNTO 0);
-- Auxiliar de  la salida donde de guardara el dato que se queda fuera al desplazar
signal aux_dout: std_logic;
BEGIN

    PROCESS (clk, rst_n, S0,S1)BEGIN

            IF rst_n = '0' THEN
                internal_value <= (OTHERS => '0');

            end if;
            IF rising_edge(clk) THEN
                -- No hay cambios 
                IF s0 = '0' AND s1 = '0' THEN
                    internal_value<= internal_value;
                -- Rotar a la derecha
                ELSIF S0 = '0' AND S1 = '1' THEN --right
                internal_value <=  d_in &internal_value(g_N - 1 downto 1) ;

                -- Rotar a la izquierda
                ELSIF S0 = '1' AND S1 = '0' THEN --left

                    internal_value <= internal_value(g_N - 2 downto 0) & d_in;

                -- Carga paralelo
                ELSIF S0 = '1' AND S1 = '1' THEN
                    internal_value <= D;
         
                END IF;
            END IF;

    END PROCESS;
    process(S0,S1,internal_value)begin
        Q<= internal_value;
        if(S0 = '1' AND S1 = '0')THEN
             --Devuelve el bit MSB
            d_out <= internal_value(g_N - 1);
        else
            --Devuelve el bit LSB
            d_out <= internal_value(0);
        end if;

     end process;

END Behavioral;