-------------------------------------------------------------------------------
--
-- Title       : 	FIR filter
-- Design      :	
-- Author      :	Pablo Sarabia Ortiz
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : fir.vhd
-- Generated   : 03 May 2022
--------------------------------------------------------------------------------
-- Description : Problema 2.4 Arbitro prioridad dinamica
-- Enunciado   :
-- FIR 8 bit filter with four stages
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Pablo Sarabia     :| 03/05/22  :| First version

-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
port (
	clk		:in std_logic;
	rst		:in std_logic;
	-- Coeficientes son signed
	beta1	:in std_logic_vector(7 downto 0); 
 	beta2	:in std_logic_vector(7 downto 0);
	beta3	:in std_logic_vector(7 downto 0);
	beta4	:in std_logic_vector(7 downto 0);
	-- Data input 8 bit
	i_data 	:in std_logic_vector(7 downto 0); --x
	-- Filtered data
	o_data 	:out std_logic_vector(9 downto 0) --y
	);
end fir_filter;
ARCHITECTURE behavioural OF fir_filter IS
--y(n)= B1x(n) + B2x(n-1) + B3x(n-2) + B4x(n-3)
-- Multiplicacion -> ancho bits  es M +N = 8 + 8 = 16
--registros
signal B1x_reg:signed (15 downto 0);
signal B2x_reg:signed (15 downto 0);
signal B3x_reg:signed (15 downto 0);
signal B4x_reg:signed (15 downto 0);

--Operaciones mmultiplicacion
signal B1x:signed (15 downto 0);
signal B2x:signed (15 downto 0);
signal B3x:signed (15 downto 0);
signal B4x:signed (15 downto 0);

-- Suma -> ancho bits  es N+1 = 17+1 = 18
signal suma:signed(17 downto 0);

--Crear registro para x
signal xn_0:signed (7 downto 0);
signal xn_1:signed (7 downto 0);
signal xn_2:signed (7 downto 0);
signal xn_3:signed (7 downto 0);

--Crear registro para betas
signal B1:signed (7 downto 0);
signal B2:signed (7 downto 0);
signal B3:signed (7 downto 0);
signal B4:signed (7 downto 0);

--formula: y[n]= beta1*x[n] + beta2*x[n-1] + beta3*x[n-2] + beta4*x[n-3] 
begin
--Registros para x(n),x(n-1),x(n-2),x(n-3)
RegistersX:PROCESS (clk,rst)BEGIN
		if(rst= '0')then
			xn_0<=(others=>'0');
			xn_1<=(others=>'0');
			xn_2<=(others=>'0');
			xn_3<=(others=>'0');

		elsif rising_edge(clk)then
			--x(n)
			xn_0<=signed(i_data);
			--x(n-1)
			xn_1<=xn_0;
			--x(n-2)
			xn_2<=xn_1;
			--x(n-3)
			xn_3<=xn_2;				
		end if;
 end process;
 --Registros para beta1,2,3,4
 RegistersBeta:PROCESS (clk,rst)BEGIN
		if(rst= '0')then
			B1<=(others=>'0');
			B2<=(others=>'0');
			B3<=(others=>'0');
			B4<=(others=>'0');

		elsif rising_edge(clk)then
			--beta1
			B1<=signed(beta1);
			--beta2
			B2<=signed(beta2);
			--beta3
			B3<=signed(beta3);
			--beta4
			B4<=signed(beta4);				
		end if;

 end process;
MultiplicaReg:PROCESS (clk,rst)	BEGIN

		if(rst= '0')then
			B1x_reg<=(others=>'0');
			B2x_reg<=(others=>'0');
			B3x_reg<=(others=>'0');
			B4x_reg<=(others=>'0');

		elsif(rising_edge(clk))then

			B1x_reg<=B1x;			
			B2x_reg<=B2x;
			B3x_reg<=B3x;
			B4x_reg<=B4x;	
		end if;
  end process;
  
  Multiplica:PROCESS (xn_0,xn_1,xn_2,xn_3,B1,B2,B3,B4)BEGIN
            --beta1*x[n]
			B1x<=resize(xn_0 * B1,B1x'length);
			--beta2*x[n-1]			
			B2x<=resize(xn_1 *B2,B2x'length);
			--beta3*x[n-2]
			B3x<=resize(xn_2*B3,B3x'length) ;
			--beta4*x[n-3] 
			B4x<=resize(xn_3*B4,B4x'length) ;		
  end process;

--beta1*x[n] + beta2*x[n-1] + beta3*x[n-2] + beta4*x[n-3] 
Sumando:process(B1x_reg,B2x_reg,B3x_reg,B4x_reg)BEGIN

	 suma<= resize(B1x_reg + B2x_reg,suma'length)  + resize(B3x_reg + B4x_reg,suma'length) ; 
	       
  end process; 
 --register out
 Salida:process(clk,rst,i_data,beta1,beta2,beta3,beta4)BEGIN
		if(rst= '0')then
	       o_data <= (others=> '0');
	   elsif(rising_edge(clk))then
	       
	       o_data <= std_logic_vector(resize(suma, o_data'length));
	       end if;
  end process;
END behavioural;