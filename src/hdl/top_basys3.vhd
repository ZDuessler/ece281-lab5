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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0);
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- advance
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
	-- declare components 
    component clock_divider is
            generic ( constant k_DIV : natural := 2   ); -- How many clk cycles until slow clock toggles
            Port (     
                i_clk    : in std_logic;
                i_reset  : in std_logic;
                o_clk    : out std_logic
            );
     end component;
    
    component controller_fsm is
            Port ( 
                i_reset   : in  STD_LOGIC;
                i_adv     : in  STD_LOGIC;
                o_cycle   : out STD_LOGIC_VECTOR (3 downto 0)           
            );
    end component;	
    
    component ALU is
            Port ( 
                i_A1       : in STD_LOGIC_VECTOR (7 downto 0);
                i_B1       : in STD_LOGIC_VECTOR (7 downto 0);
                i_op      : in STD_LOGIC_VECTOR (2 downto 0);
                o_result   : out STD_LOGIC_VECTOR (7 downto 0);
                o_flags   : out STD_LOGIC_VECTOR (2 downto 0)          
            );
    end component;    
    
    component twoscomp_decimal is
            Port ( 
                i_binary       : in  STD_LOGIC_VECTOR (7 downto 0);
                o_negative      : out STD_LOGIC; 
                o_hundreds      : out STD_LOGIC_VECTOR (3 downto 0);
                o_tens      : out STD_LOGIC_VECTOR (3 downto 0);
                o_ones      : out STD_LOGIC_VECTOR (3 downto 0)          
            );
    end component;        
    
    component TDM4 is
            Port ( 
                i_clk        : in  STD_LOGIC;
                i_reset      : in  STD_LOGIC;
                i_D3       : in  STD_LOGIC_VECTOR (3 downto 0);
                i_D2       : in  STD_LOGIC_VECTOR (3 downto 0);
                i_D1       : in  STD_LOGIC_VECTOR (3 downto 0);
                i_D0       : in  STD_LOGIC_VECTOR (3 downto 0);
                o_data       : out STD_LOGIC_VECTOR (3 downto 0);
                o_sel        : out STD_LOGIC_VECTOR (3 downto 0)        
            );
    end component;    
    
    component sevenSegDecoder is 
            Port (
                i_D : in std_logic_vector(3 downto 0);
                o_S : out std_logic_vector(6 downto 0)
            );
    end component sevenSegDecoder;


	-- and signals
	signal w_cycle     : std_logic_vector(3 downto 0);
	signal w_clk       : std_logic;
	signal w_A         : std_logic_vector(7 downto 0);
	signal w_B         : std_logic_vector(7 downto 0);
	signal w_result    : std_logic_vector(7 downto 0);
	signal w_bin       : std_logic_vector(7 downto 0);
	signal w_sign      : std_logic_vector(3 downto 0);
	signal w_neg       : std_logic;
	signal w_hund      : std_logic_vector(3 downto 0);
	signal w_tens      : std_logic_vector(3 downto 0);
	signal w_ones      : std_logic_vector(3 downto 0);
	signal w_data      : std_logic_vector(3 downto 0);
    signal w_an        : std_logic_vector(3 downto 0);
    signal w_sel       : std_logic_vector(3 downto 0);
    
  
begin
	-- PORT MAPS ----------------------------------------
       TDM_clock_divider_inst : clock_divider   
                generic map (k_DIV => 250000)   
                port map (                      
                    i_clk => clk,               
                    i_reset => btnU,     
                    o_clk => w_clk          
          );                                     
       controller_fsm_inst : controller_fsm
             port map(
                i_reset   => btnU,
                i_adv     => btnC,
                o_cycle   => w_cycle
         );	
         
       ALU_inst : ALU
               port map(
                 i_A1       => w_A,
                 i_B1       => w_B,
                 i_op      => sw(2 downto 0),
                 o_result   => w_result,
                 o_flags   => led(15 downto 13) 
           );  
           
       twoscomp_decimal_inst : twoscomp_decimal
               port map(
                    i_binary       => w_bin,
                    o_negative      => w_neg,
                    o_hundreds      => w_hund,
                    o_tens      => w_tens,
                    o_ones      => w_ones
               );     
                 
       	w_sign <= x"A" when w_neg = '1' else 
                  x"B";        
                  
       TDM4_inst : TDM4
               port map(
                    i_clk       => w_clk,
                    i_reset     => btnU,
                    i_D3        => w_sign,
                    i_D2        => w_hund,
                    i_D1        => w_tens,
                    i_D0        => w_ones,
                    o_data      => w_data,
                    o_sel       => w_sel
               );   
               
       sevenSegDecoder_inst : sevenSegDecoder
                port map(
                     i_D      => w_data,
                     o_S      => seg
                );              
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	w_A <= sw(7 downto 0) when w_cycle = "0001" 
	       else w_A;
	w_B <= sw(7 downto 0) when w_cycle = "0010"
	       else w_B;
	       
	w_bin <=   w_A      when w_cycle = "0001" else 
	           w_B      when w_cycle = "0010" else 
	           w_result when w_cycle = "0100" else
	           w_bin ;
	

	                 
	w_an <= "1111" when w_cycle = "1000" else 
	        w_sel;
	        
    an <= w_an;
    led(3 downto 0) <= w_cycle; 
    
	
end top_basys3_arch;
