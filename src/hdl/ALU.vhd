--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
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
--|
--| ALU OPCODES:
--|
--|     ADD     000
--|
--|
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
    Port ( i_A1      : in std_logic_vector(7 downto 0);
           i_B1      : in std_logic_vector(7 downto 0);
           i_op     : in std_logic_vector(2 downto 0);
           o_result : out signed(7 downto 0);
           o_flags  : out std_logic_vector(2 downto 0) 
     );
end ALU;

architecture behavioral of ALU is
 
    component fullAdder is
	   port(
           i_A, i_B, i_Cin        :    in  std_logic;
           o_S, o_Cout            :    out    std_logic
	   );
    end component fullAdder;   

	signal w_B      : std_logic_vector(7 downto 0);   
    signal w_S      : std_logic_vector(7 downto 0);
    signal w_and_or : std_logic_vector(7 downto 0);
    signal w_Cout0, w_Cout1, w_Cout2, w_Cout3, w_Cout4, w_Cout5, w_Cout6, w_Cout7 : std_logic;
    signal w_result : std_logic_vector(7 downto 0);    
  
begin	
	-- CONCURRENT STATEMENTS ----------------------------
	adder0_inst : fullAdder
         port map(
             i_A    => i_A1(0),
             i_B    => w_B(0),
             i_Cin  => i_op(0),
             o_S    => w_S(0),
             o_Cout => w_Cout0
     );
     
	adder1_inst : fullAdder
          port map(
              i_A    => i_A1(1),
              i_B    => w_B(1),
              i_Cin  => w_Cout0,
              o_S    => w_S(1),
              o_Cout => w_Cout1
      );
      
	adder2_inst : fullAdder
            port map(
                i_A    => i_A1(2),
                i_B    => w_B(2),
                i_Cin  => w_Cout1,
                o_S    => w_S(2),
                o_Cout => w_Cout2
        );      
      
	adder3_inst : fullAdder
              port map(
                  i_A    => i_A1(3),
                  i_B    => w_B(3),
                  i_Cin  => w_Cout2,
                  o_S    => w_S(3),
                  o_Cout => w_Cout3
          );      
	
	adder4_inst : fullAdder
                port map(
                    i_A    => i_A1(4),
                    i_B    => w_B(4),
                    i_Cin  => w_Cout3,
                    o_S    => w_S(4),
                    o_Cout => w_Cout4
            );	
	
	adder5_inst : fullAdder
                  port map(
                      i_A    => i_A1(5),
                      i_B    => w_B(5),
                      i_Cin  => w_Cout4,
                      o_S    => w_S(5),
                      o_Cout => w_Cout5
              );	

	adder6_inst : fullAdder
                port map(
                    i_A    => i_A1(6),
                    i_B    => w_B(6),
                    i_Cin  => w_Cout5,
                    o_S    => w_S(6),
                    o_Cout => w_Cout6
                );

	adder7_inst : fullAdder
                port map(
                    i_A    => i_A1(7),
                    i_B    => w_B(7),
                    i_Cin  => w_Cout6,
                    o_S    => w_S(7),
                    o_Cout => w_Cout7
                    );	

    w_B         <= i_B1 when i_op(0) = '0' else 
                    not i_B1;
    w_and_or    <= i_A1 or i_B1 when i_op(0) = '0' else 
                   i_A1 and i_B1; 
    w_result    <= w_S when i_op(2 downto 1) = "00" else 
                   w_and_or when i_op(2 downto 1) = "01" else 
                   std_logic_vector(shift_left(unsigned(i_A1), to_integer(unsigned(i_B1(2 downto 0))))) when i_op(2 downto 1) = "10" else
                   std_logic_vector(shift_right(unsigned(i_A1), to_integer(unsigned(i_B1(2 downto 0)))));
   
   o_result     <= signed(w_result);
   o_flags(2)   <= w_result(7);
   o_flags(1)   <= '1' when w_result = "00000000"
                    else '0';
   o_flags(0)   <= w_Cout7;
   
                   

end behavioral;
