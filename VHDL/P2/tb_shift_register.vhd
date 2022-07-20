
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_shift_register is
--  Port ( );
end tb_shift_register;

architecture Behavioral of tb_shift_register is
    component ShiftRegister is
    GENERIC (g_N : INTEGER := 5);
    PORT (
        d_in : IN STD_LOGIC;
        D : IN STD_LOGIC_VECTOR (g_N - 1 DOWNTO 0);
        rst_n : in STD_LOGIC;
        s0 : IN STD_LOGIC;
        S1 : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        Q : OUT STD_LOGIC_VECTOR (g_N - 1 DOWNTO 0);
        d_out : OUT STD_LOGIC);
end component;

        constant freq : integer := 100_000; --KHZ
        constant clk_period : time := (1 ms/ freq);
        -- Entradas 
        signal  rst_n       :   std_logic := '0';
        signal  clk         :   std_logic := '0';
        signal  d_in         :   std_logic := '0';
        signal D           :   std_logic_vector( 4 downto 0):= (others=>'0');
        signal s0           :   std_logic:='0';
        signal s1           :   std_logic:='0';
         -- Salidas
        signal  Q           :   std_logic_vector( 4 downto 0);
        signal  d_out        :   std_logic;
        
begin
    UUT: ShiftRegister
    port map (
            rst_n  => rst_n,
            clk    => clk,
            d_in    => d_in,
            D      => D,
            s0     => s0,
            s1     => s1,
            Q      => Q,
            d_out   => d_out
    );
    clk <= not clk after clk_period/2;
    process is 
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
         rst_n <= '0';
        wait for 20 ns;
        rst_n <= '1';
        
        D<="01101";
        s0<='1';s1<='1';wait for 20ns; --carga
        
        
        --D<="10111";
        s0<='1';s1<='0'; -- rotar a la izquierda x3 (inserta 110)
        d_in<='1';wait for 100ns;
        s0<='1';s1<='0';
        d_in<='1';wait for 100ns;
        
        s0<='0';s1<='1';
        d_in<='0';    wait ;    -- rotar a la derecha introduciendo 1s
        
    end process;
end Behavioral;