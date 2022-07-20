----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.05.2022 17:50:44
-- Design Name: 
-- Module Name: tb_fir - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_fir is

end tb_fir;

architecture Behavioral of tb_fir is

 component fir_filter is
        port (
            clk		:in std_logic;
            rst		:in std_logic;
            -- Coeficientes
            beta1	:in std_logic_vector(7 downto 0); --son signed
            beta2	:in std_logic_vector(7 downto 0);
            beta3	:in std_logic_vector(7 downto 0);
            beta4	:in std_logic_vector(7 downto 0);
            -- Data input 8 bit
            i_data 	:in std_logic_vector(7 downto 0);
            -- Filtered data
            o_data 	:out std_logic_vector(9 downto 0)
	);
   end component;

   constant clk_period: time:= 20ns;
    

  -- Inputs 
  signal  beta1       :  signed(7 downto 0) := (others => '0');
  signal  beta2       :  signed(7 downto 0) := (others => '0');
  signal  beta3       :  signed(7 downto 0) := (others => '0');
  signal  beta4       :  signed(7 downto 0) := (others => '0');
  signal  i_data       :  signed(7 downto 0) := (others => '0');
  signal  rst:   std_logic := '0';
  signal  clk:   std_logic := '0';
  -- Output
  signal  o_data      :signed(9 downto 0) := (others => '0');

begin
  UUT: fir_filter
    port map (
      rst     => rst,
      clk => clk,
      beta1   => std_logic_vector(beta1),
      beta2   => std_logic_vector(beta2),
      beta3   => std_logic_vector(beta3),
      beta4   => std_logic_vector(beta4),
      i_data  => std_logic_vector(i_data),
      signed(o_data)  => o_data
    );
    clk <= not clk after clk_period/2;
    process is 
    begin
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      rst <= '0';
      wait for 10 ns;
      wait until rising_edge(clk);
      rst <= '1';
      wait for 10 ns;	
      wait until rising_edge(clk);
      i_data <= to_signed(2, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(1, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(3, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(-1, i_data'length);
     
      beta1 <= to_signed(3, beta1'length);
      beta2<= to_signed(4, beta2'length);
      beta3 <= to_signed(4, beta3'length);
      beta4 <= to_signed(4, beta4'length);
       wait for 200 ns;
      wait until rising_edge(clk);
      i_data <= to_signed(1, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(2, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(3, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(4, i_data'length);
      
      beta1 <= to_signed(100, beta1'length);
      beta2 <= to_signed(1, beta2'length);
      beta3 <= to_signed(4, beta3'length);
      beta4 <= to_signed(40, beta4'length);
      wait for 200 ns;
      wait until rising_edge(clk);
      i_data <= to_signed(1, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(-1, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(3, i_data'length);
      wait for 20 ns;
      i_data <= to_signed(5, i_data'length);
      beta1 <= to_signed(55, beta1'length);
      beta2 <= to_signed(3, beta2'length);
      beta3 <= to_signed(4, beta3'length);
      beta4 <= to_signed(4, beta4'length);
      wait for 200 ns;
      wait until rising_edge(clk);
    end process;

end Behavioral;
