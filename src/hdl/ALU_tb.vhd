--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : clock_divider_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the generic clock divider.
--|
--| DOCUMENTATION : None
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std, unisim
--|    Files     : clock_divider.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity ALU_tb is
end ALU_tb;

architecture test_bench of ALU_tb is 	
  
    component ALU is
        Port ( i_A1      : in std_logic_vector(7 downto 0); 
               i_B1      : in std_logic_vector(7 downto 0); 
               i_op     : in std_logic_vector(2 downto 0);  
               o_result : out signed(7 downto 0);           
               o_flags  : out std_logic_vector(2 downto 0)  
         );                                                 
                                                         
    end component ALU;
	
	signal w_op : std_logic_vector(2 downto 0);
	signal w_A : std_logic_vector(7 downto 0);
	signal w_B : std_logic_vector(7 downto 0);
	signal w_result : signed(7 downto 0);
	signal w_flags : std_logic_vector(2 downto 0) := "000";
	
begin
	-- PORT MAPS ----------------------------------------

	-- map ports for any component instances (port mapping is like wiring hardware)
	uut_inst : ALU 
	port map (
		i_A1      =>   w_A,
		i_B1      =>   w_B,
		i_op      =>   w_op,
		o_result  =>   w_result,
		o_flags   =>   w_flags
		
	);
	
	
	-- Test Plan Process --------------------------------
	test_process : process 
	begin
		w_op <= "000";
		w_A <= "00110010";
		w_B <= "00110010";
		wait for 10 ns;
		assert(w_result = "01100100") and (w_flags = "000") report "bad add 1" severity failure;
		--wait for 10ns;
		
		w_op <= "000";                                                                         
		w_A <= "01001111";                                                                     
		w_B <= "10100101";                                                                     
		wait for 10 ns;                                                                        
		assert(w_result = "11110100") and (w_flags = "100") report "bad add 2" severity failure;
		--wait for 10ns;      
		
		w_op <= "001";                                                                        
		w_A <= "10100101";                                                                    
		w_B <= "10100101";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "00000000") and (w_flags = "011") report "bad sub 1" severity failure;
		--wait for 10ns;                                                                                                                                           
		
		w_op <= "000";                                                                        
		w_A <= "11111111";                                                                    
		w_B <= "11111111";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "11111110") report "bad add Cout" severity failure;
		assert (w_flags = "101") report "bad add Cout" severity failure;
		--wait for 10ns;                                                                        
		 
		w_op <= "010";                                                                        
		w_A <= "01100100";                                                                    
		w_B <= "01001111";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "01101111") and (w_flags = "000") report "bad OR" severity failure;
		--wait for 10ns; 
		
		w_op <= "011";                                                                        
		w_A <= "01100100";                                                                    
		w_B <= "01001111";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "01000100") report "bad AND" severity failure;
		--wait for 10ns;                                                                        
		
		w_op <= "100";                                                                        
		w_A <= "01100100";                                                                    
		w_B <= "00000100";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "01000000") report "bad SL" severity failure;
		--wait for 10ns;                                                                        
		
		w_op <= "110";                                                                        
		w_A <= "01000100";                                                                    
		w_B <= "00000101";                                                                    
		wait for 10 ns;                                                                       
		assert(w_result = "00000010") report "bad SR" severity failure;                                                                       
		--wait for 10ns;                                                                        
		                                                                                                                                                            
	end process;	
	-----------------------------------------------------	
	
end test_bench;
