
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key is
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

--led_out : out STD_LOGIC := '0' ;
--led_alarm : out STD_LOGIC := '0';




end key;

architecture Behavioral of key is
signal i : integer :=0;
signal row_out:std_logic_vector(3 downto 0);
signal current_Input: std_logic_vector(3 downto 0);

Signal Current_Password : STD_LOGIC_VECTOR(15 downto 0) := "0001001000110100" ; --Current used password , preset with 1234
Signal current_position : integer range 1 to 4 ; -- Position of the cruser in the password
Signal Flag_Number_pressed : boolean := false ; -- Key pressed or not (For debouncing)
Signal Password_out : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- Final password to be output-ed
Signal New_Password : STD_LOGIC_VECTOR(15 downto 0); -- New password to be set
Signal Number : STD_LOGIC_VECTOR(3 downto 0); -- Number pressed
--Signal Door_Open : Boolean := false; -- Specifies if door open or closed
Signal Trials : Integer range 0 to 3 := 0; --Number of wrong trials
Signal Set_new_password : Boolean := false; -- To set a new password
Signal sec : integer := 0;
Signal led_position_s : STD_LOGIC_VECTOR(1 downto 0) := "00" ;
Signal alarm_s : STD_LOGIC := '0' ;
Signal flag_t : STD_LOGIC := '0' ;
--Signal led_out_s : STD_LOGIC := '0';
--Signal led_alarm_s : STD_LOGIC := '1';

type state is(s0,s1,s2,s3);
signal s :state;


begin

process(s)
begin
case s is

when s0=> row_out<="0001";
when s1=> row_out<="0010";
when s2=> row_out<="0100";
when s3=> row_out<="1000";
when others => row_out<="0000";
end case;
end process;


   process (clk)
	begin
	if clk'event and clk = '1' then
	if (flag_t='1')then
	--	Led_out_s <= '1';
		sec<= sec+1;
		 end if;
		 
		 if(sec=20000000)then
		 Correct_passowrd <= '0' ;
	--	 led_out_s<='0'; 
		 sec <= 0;
		 flag_t<='0';
       	end if;	
	if(i = 2800000)then
	i<=0;
	
	
	case s is
	when s0=> s<=s1;
	when s1=> s<=s2;
	when  s2=> s<=s3;
	when  s3=> s<=s0;
   when others => s<=s0;
		end case;	  
			if(columns(0)='1' or columns(1)='1' or columns(2)='1' or columns(3)='1')then
				if columns = "1000" then
						if row_out = "1000" then
							current_Input <= "0000";  number <= "0001"; flag_number_pressed <= true;LedTest <= "0000" ; -- number 1
						elsif row_out = "0100" then
							current_Input <= "0100";  number <= "0100"; flag_number_pressed <= true;LedTest <= "0100" ; -- number 4
						elsif row_out = "0010" then
							current_Input <= "1000";  number <= "0111"; flag_number_pressed <= true;LedTest <= "1000" ; -- number 7
						elsif row_out = "0001" then
							current_Input <= "1100"; LedTest <= "1100" ; -- mode
						end if;
				elsif columns = "0100" then
						if row_out = "1000" then
							current_Input <= "0001";  number <= "0010"; flag_number_pressed <= true;LedTest <= "0001" ; --number 2
						elsif row_out = "0100" then
							current_Input <= "0101";  number <= "0101"; flag_number_pressed <= true;LedTest <= "0101" ; -- number 5
						elsif row_out = "0010" then
							current_Input <= "1001";  number <= "1000"; flag_number_pressed <= true;LedTest <= "1001" ; -- number 8
						elsif row_out = "0001" then
							current_Input <= "1101";  number <= "0000"; flag_number_pressed <= true;LedTest <= "1101" ; -- number 0
						end if;		
				elsif columns = "0010" then
						if row_out = "1000" then
							current_Input <= "0010";  number <= "0011"; flag_number_pressed <= true;LedTest <= "0010" ; -- number 3
						elsif row_out = "0100" then
							current_Input <= "0110";  number <= "0110"; flag_number_pressed <= true;LedTest <= "0110" ;  --number 6
						elsif row_out = "0010" then
							current_Input <= "1010";  number <= "1001"; flag_number_pressed <= true;LedTest <= "1010" ; --number 9
						elsif row_out = "0001" then
							current_Input <= "1110"; LedTest <= "1110" ; --cancel
						end if;	
				elsif columns = "0001" then
					if row_out = "1000" then
						current_Input <= "0011"; LedTest <= "0011" ; -- f1
					elsif row_out = "0100" then
						current_Input <= "0111"; LedTest <= "0111" ; -- f2
					elsif row_out = "0010" then
						current_Input <= "1101"; LedTest <= "1011" ; -- f3
					elsif row_out = "0001" then
						current_Input <= "1111"; LedTest <= "1111" ; -- enter
					end if;
				else
					current_Input <= "0000";
				end if;
				
			else
			
				if(current_position = 1 and door_open = false and flag_number_pressed = true) then
				
					Password_out(15 downto 12) <= Number ; 
					current_position <= current_position +1 ; 
					Flag_number_pressed <= false ; 
					led_position_s <= "00" ;
					
					elsif(current_position = 2 and door_open = false and flag_number_pressed = true) then
					
						Password_out(11 downto 8) <= Number ; 
						current_position <= current_position +1 ; 
						Flag_number_pressed <= false ; 
						led_position_s <= "01" ;
					
					elsif(current_position = 3 and door_open = false and flag_number_pressed = true) then
					
						Password_out(7 downto 4) <= Number ; 
						current_position <= current_position +1 ; 
						Flag_number_pressed <= false ;	
						led_position_s <= "10" ;
					
					elsif(current_position = 4 and door_open = false and flag_number_pressed = true) then
					
						Password_out(3 downto 0) <= Number ; 
						current_position <= current_position +1 ; 
						Flag_number_pressed <= false ; 
						led_position_s <= "11" ;
				
				end if;
				
								
				if(current_position = 1 and door_open = true and flag_number_pressed = true) then 
				
				New_Password(15 downto 12) <= Number ; 
				current_position <= current_position +1 ;		
				Flag_number_pressed <= false ;
				led_position_s <= "00" ;
				
				elsif(current_position = 2 and door_open = true and flag_number_pressed = true) then 

					New_Password(11 downto 8) <= Number ; 
					current_position <= current_position +1 ;
					Flag_number_pressed <= false ;
					led_position_s <= "01" ;
					
					elsif(current_position = 3 and door_open = true and flag_number_pressed = true) then 
					
					New_Password(7 downto 4) <= Number ; 
					current_position <= current_position +1 ;
					Flag_number_pressed <= false ;
					led_position_s <= "10" ;
					
					elsif(current_position = 4 and door_open = true and flag_number_pressed = true) then 
					
					New_Password(3 downto 0) <= Number ; 
					current_position <= current_position +1 ;
					Flag_number_pressed <= false ;
					led_position_s <= "11" ;
					
				end if ;

				
				
				if(current_input /= 0) then
					
					if(current_input = "1110") then -- Cancel is pressed
							
							current_position <= 1 ; 
							led_position_s <= "00" ;
							Password_out <= (others => '0') ;
							New_Password <= (others => '0') ;
							
							if(Door_open = true) then 
								Current_Password <= Current_Password ; set_new_password <= false ;
--								led_alarm_s <= '1';
							end if;
							
					elsif(current_input = "1111") then -- Enter is pressed
					
							if(Password_out = Current_Password and Door_open = false ) then
							
								Correct_passowrd <= '1' ;
								flag_t<='1';
								Trials <= 0 ; Alarm_s <= '0';
								current_position <= 1 ;
								Password_out <= (others => '0');
	--							led_alarm_s <= '0';
								
							--	Door_open <= true ;
								led_position_s <= "00" ;
								
								--Led_out_s <= '1'; 
								
								
								
								elsif(password_out /= Current_password and Door_open = false and Trials < 3) then
								
									Correct_passowrd <= '0' ;
									Trials <= Trials +1 ;
									Password_out <= (others => '0');
									current_position <= 1 ;
		--							Led_out_s <= '0'; 
									
									--Door_open <= false ; 
									
		--							led_alarm_s <= '1';
									led_position_s <= "00" ;
								--	led_alarm_s <= '0';
									
								elsif(password_out /= Current_password and Door_open = false and Trials = 3) then	
								
									Correct_passowrd <= '0' ;
									Alarm_s <= '1';
									Password_out <= (others => '0');
									current_position <= 1 ;
								--	Led_out_s <= '0'; 
									--Door_open <= false ; 
			--						led_alarm_s <= '1';
									led_position_s <= "00" ;
								--	led_alarm_s <= '1';
									
								elsif(Door_open = true and set_new_password = true)then	
									Current_Password <= New_Password ;
									New_password <= (others => '0') ;

							--		led_alarm_s <= '0';
								
							end if;	
						
						elsif(current_input = "1100") then -- Mode is pressed
							Set_new_password <= true ;	
						
--						elsif(current_input = "0011") then -- F1 is pressed
--							door_open <= false ;
--							led_alarm_s <= '1';
--				
				end if;	
		 
			end if ;	
				
				
				
				current_Input <= "0000";
		 
			end if;
				
			LedTest <= current_Input;
			
		 
			
    else 
	  i<=i+1;
	 end if;						
		end if;
	 end process;
	 
	rows <= row_out;
	alarm <= alarm_s;
	led_position <= led_position_s ;
	--led_out <= led_out_s ;
--	led_alarm <= led_alarm_s;
	

	
end Behavioral;