library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_read is 
end tb_read;

architecture test of tb_read is
	--File handler
	file file_input : text; 	
	component top_practica1 is
		port (
			rst_n         : in std_logic;
			clk100Mhz     : in std_logic;
			BTNC           : in std_logic;
			LED           : out std_logic
		);
	  end component;
	  
  constant timer_debounce : integer := 10; --ms
  constant freq : integer := 100_000; --KHZ
  constant clk_period : time := (1 ms/ freq);
	
	-- Inputs 
	signal  rst_n       :   std_logic ;
	signal  clk         :   std_logic:= '0';
	signal  BTNC     :   std_logic ;
	-- Output
	signal  LED   :   std_logic;
	  
begin
	UUT: top_practica1
		port map (
		rst_n     => rst_n,
		clk100Mhz => clk,
		BTNC       => BTNC,
		LED       => LED
		);
	clk <= not clk after clk_period/2;
	proc_sequencer : process
	-- Process to read the data
		file text_file :text open read_mode is "inputs.csv";
		variable text_line : line; -- Current line
		variable ok: boolean; -- Saves the status of the operation of reading

		--File para el fichero output 
		file file_output : text;
		variable file_line : line;

		variable char : character; -- Read each character of the line(used when using comments)
		variable delay: time ; -- Saves the desired delay time
	
		variable rst_nVar: std_logic;
		variable BTNCVar: std_logic;
		variable LEDVar: std_logic;
	
	begin
	
		file_open(file_output,"C:\Users\jfgor\Vivado\Práctica1_vhdl_VIVADO\outputs.csv",write_mode);
		write(file_line, string'("Simulation of top_practica1.vhd"));
		writeline(file_output,file_line);
		while not endfile(text_file) loop

			readline(text_file, text_line);
			-- Skip empty lines and commented lines
			if text_line.all'length = 0 or text_line.all(1) = '#' then
				next;
			end if;
			-- Read the delay time
			read(text_line, delay, ok);
			assert ok
				report "Read 'delay' failed for line: " & text_line.all
				severity failure;
			-- Read first operand (rst_n)
			read(text_line, rst_nVar, ok);
			assert ok
				report "Read 'rst_n' failed for line: " & text_line.all
				severity failure;
			rst_n<= rst_nVar;
			-- Read the second operand (BTNC)
			read(text_line, BTNCVar, ok);
			assert ok
				report "Read 'BTNC' failed for line: " & text_line.all
				severity failure;
			BTNC <= BTNCVar;
			-- Read the third operand (LED)
			read(text_line, LEDVar, ok);
			assert ok
				report "Read 'LED' failed for line: " & text_line.all
				severity failure;
						
			-- Wait for the delay
			wait for delay;
			
			
			writeline(file_output,file_line);
		    write(file_line,string'(" Time: "));
		    write(file_line,delay);
			write(file_line,string'("; rst_n: "));
		    write(file_line,rst_n);
		    write(file_line,string'("; BTNC: "));
		    write(file_line,BTNC);
		    write(file_line,string'("; LED: "));
		    write(file_line, LED);
		    write(file_line,string'(" ;"));
			writeline(file_output,file_line);
			
            -- Print the comments(if any) to console
			-- Print trailing comment to console, if any
			read(text_line, char, ok); -- Skip expected newline
			read(text_line, char, ok);
			if char = '#' then
				read(text_line, char, ok); -- Skip expected newline
				report text_line.all;
			end if;
			
			if LED = LEDVar then
			
				writeline(file_output,file_line);
				write(file_line,string'("Correct value of LED: "));
				write(file_line,LED);
				write(file_line,string'(" ;"));
				writeline(file_output,file_line);
				writeline(file_output,file_line);
			else
				writeline(file_output,file_line);
				write(file_line,string'("ERROR: expected LED to be "));
				write(file_line,LEDVar);
				write(file_line,string'(" actual value "));
				write(file_line,LED);
				write(file_line,string'(" ;"));
                writeline(file_output,file_line);
				writeline(file_output,file_line);

			end if;

          --  wait for 20ns;
				
		end loop;	
		write(file_line, string'("Finished simulation of top_practica1.vhd"));
        writeline(file_output,file_line);
       report "Finished" severity FAILURE; 
        --file_close(file_output);
  end process;
  process is 
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait for 100ns;
  end process;
end test;