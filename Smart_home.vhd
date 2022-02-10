
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adc_code is
    Port ( 
			  check : out STD_LOGIC_VECTOR (1 downto 0):="00";
			  SPI_MISO : in  STD_LOGIC;
           AD_CONV : out  STD_LOGIC :='0';
           AMP_CS : out  STD_LOGIC :='1';
           SPI_MOSI : out  STD_LOGIC:='0';
           SPI_SCK : inout  STD_LOGIC;
       --    LED : out  STD_LOGIC_VECTOR(7 downto 0);
           clk : in  STD_LOGIC;
           SPI_SS_B : out  STD_LOGIC :='1';
           SF_CE0 : out STD_LOGIC :='1';
           FPGA_INIT_B : out  STD_LOGIC :='0';
           enable : in  STD_LOGIC;
			  valve : out STD_LOGIC ;
			  valve2 : out STD_LOGIC ;
			  Relay : out STD_LOGIC_VECTOR (2 downto 0) := "000";
           DAC_CS : out  STD_LOGIC :='1' ;
			  
			 

rows_out : out STD_LOGIC_VECTOR(3 downto 0);
columns_in : in STD_LOGIC_VECTOR(3 downto 0);
Alarm_out : out STD_LOGIC;
Led_position_out : out STD_LOGIC_VECTOR(1 downto 0) := "00" ;
LedTest_out: out std_logic_vector (3 downto 0);

Close_Button : in STD_LOGIC;
pwm1 : out STD_LOGIC ;
pwm2 : out STD_LOGIC);
			  
end adc_code;

architecture Behavioral of adc_code is
	type state_type is (IDLE ,TEMP , ADC , OUTPUT );
	signal state : state_type ;
	signal clk_counter :integer range 0 to 10:= 0;
	signal risingedge :std_logic := '0';
	signal gaincount : integer range 0 to 7 := 7;
	signal count1 : integer range 0 to 13;
	signal adccounter: integer range 0 to 64:=0;
	signal ADC1 : signed (13 downto 0):= (others => '0');
	signal delay1 :integer range 0 to 10000000:=0;
	signal compare :signed (7 downto 0):= (others => '0');
	Signal enableBlink : STD_LOGIC :='0' ; 
	Signal blinkCounter : integer ;
Signal enaabelAlarm : STD_LOGIC :='0' ; 	

	--signal count2 : integer range 0 to 2 := 0;
	
	
	Component key is
port(
clk: in std_logic;

--reset:in std_logic;

columns : in std_logic_vector (3 downto 0);
rows : out std_logic_vector (3 downto 0);
Alarm : out STD_LOGIC := '0';

Door_open : in Boolean ;
Correct_passowrd : out STD_LOGIC := '0';
LedTest: out std_logic_vector (3 downto 0);
led_position : out STD_LOGIC_VECTOR(1 downto 0) := "00" );

end component;

component double is
 Port (  
	 enable: in  STD_LOGIC;
	          close : in STD_Logic;
               clk : in  STD_LOGIC;
					is_open : out boolean :=false ;
					
	--		  result  : OUT STD_LOGIC;--debounced signal
           pwm2 : out  STD_LOGIC; 
           pwm : out  STD_LOGIC
												);
												
end component;


Signal Is_Open_s : boolean;
Signal Door_open_s : boolean;
Signal Correct_password_s : STD_LOGIC ;
Signal Enable_s : STD_Logic;
	
begin

	
Key_pad : key port map(clk , columns_in , rows_out , enaabelAlarm , Door_open_s , Correct_password_s , LedTest_out, Led_position_out);

Motor : double port map(Enable_s , Close_Button , clk , Is_Open_s ,PWM1 , PWM2);

Door_open_s <= Is_Open_s;
Enable_s <= Correct_password_s;
 
 

	process(clk)
		begin
			if (rising_edge(clk)) then
				if (clk_counter = 10) then
					risingedge <= not (risingedge);
					clk_counter <= 0;
				else
					clk_counter <= clk_counter + 1;
				end if;
			end if;
	end process;
	
	SPI_SCK <= risingedge;
	
	process(SPI_SCK) 
		constant gain : std_logic_vector(7 downto 0) := "00010001";
		constant S1 :signed (7 downto 0):="10111101" ;
		constant S2 :signed (7 downto 0):="10010100" ;
	begin 
		if (enable = '0') then
		--	LED <= (others => '0');
		--	valve<='0' ;
		else
			if (rising_edge(SPI_SCK)) then 
				case state is 
					when IDLE => 
								check <= "00";
								if (enable = '1') then 
									DAC_CS <='0';
									SPI_SS_B <= '0';
									SF_CE0 <= '1';
									FPGA_INIT_B <= '1';
									AMP_CS <= '0' ;
									if (gaincount = 0) then
										SPI_MOSI <= gain(gaincount);
										AMP_CS <= '1';
										state <= TEMP;
									else
										SPI_MOSI <= gain(gaincount);
										gaincount <= gaincount - 1;
										state <= IDLE;
									end if;
								else
									state <= IDLE; 
								end if;
								
					When TEMP =>
										check <= "01";
										--SPI_MOSI <= '0';
										--if (count2 <2) then
											AD_CONV <= '1';
											--state <= TEMP;
											--count2 <= count2 + 1 ;
										--else
											adccounter <= 0; 
											count1 <= 13;
											state <= ADC ;
											--count2 <= 0;
										--end if;
								
					
					when ADC =>
								check <= "10";
								
								AD_CONV <= '0';
								if (adccounter <= 1) then --(0,1)
									adccounter <= adccounter + 1;
									state <= ADC;	
								elsif (adccounter > 1 and adccounter < 16) then
									adccounter <= adccounter + 1 ; --(2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
									ADC1(count1) <= SPI_MISO;
									count1 <= count1 - 1;
									state <= ADC;
								elsif (adccounter >= 16 and adccounter < 34) then --(17,18)
									
									adccounter <= adccounter + 1;
									state <= ADC;
								elsif (adccounter >=34) then
									
									state <= OUTPUT;					
								end if;
							
					when OUTPUT =>
								
								check <= "11";
								--AD_CONV <= '1';
								
								if( (ADC1(13) = '1') or (ADC1(12) = '1' ) )  then 
								enableBlink <='1'  ;
								valve2 <='1'  ;
								else 
								enableBlink <='0' ;
								valve2 <='0' ;
								end if ;
--							
--								LED(0) <= ADC1 (6);
--								LED(1) <= ADC1 (7);
--								LED(2) <= ADC1 (8);
--								LED(3) <= ADC1 (9);
--								LED(4) <= ADC1 (10);
--								LED(5) <= ADC1 (11);
--								LED(6) <= ADC1 (12);
--								LED(7) <= ADC1 (13);
								
							
								
--								relay(0) <= '1';
--								relay(1) <= '1';
--								relay (2) <= '0';
--								
--								if(compare (7) = '0') then
--									relay <= "100" ;
--								else
--									if(compare > S1 ) then
--										relay <= "100" ;
--									elsif ( compare >= S2) then
--										relay <= "110" ;
----									elsif ( compare < S2 ) then
----										relay <= "111" ;
--									else
--										relay <= "111" ;
--									end if;
--								end if;
								
--								if (delay1 = 3200000) then 
										
										ADC1 <= (others => '0');
										delay1<=0;
										state <= TEMP ;
										
--								else
--									delay1 <= delay1 + 1;
--									state <= OUTPUT;
--								end if;
				end case ;
			end if;					
		end if ;		
	end process ;	
	process ( enableBlink , enaabelAlarm ) 
	begin 
	if( enableBlink = '1'  or enaabelAlarm ='1' ) then 
	if( rising_edge(clk) )then 
		blinkCounter<=blinkCounter+1 ; 
	if( blinkCounter=50000000) then 
		valve<='1' ; 
	elsif( blinkCounter=100000000) then 
		valve<='0' ;
		blinkCounter<=0 ; 
	end if; 
	end if ; 
	end if  ;
	end process ; 
	
end Behavioral;