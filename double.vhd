
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity double is
 GENERIC(
    counter_size  :  INTEGER := 19); --counter(19 bits gives 10.5ms with the 50MHz clock when the counter ends and gives out the carry) 
    Port (   enable: in  STD_LOGIC;
	          close : in STD_Logic;
               clk : in  STD_LOGIC;
			  result  : OUT STD_LOGIC;--debounced signal
           pwm2 : out  STD_LOGIC; 
           pwm : out  STD_LOGIC);
end double;

architecture Behavioral of double is
signal i : integer :=0;
signal i2 : integer :=0;
signal counter : integer :=0;
signal bigcounter : integer :=0;
signal flag_pushed : integer :=0;
signal counter2 : integer :=0;
signal bigcounter2 : integer :=0;
signal flag_pushed2 : integer :=0;

--debouncer 
SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flipflops storing to check if the button is still in bouncing state." 2 flipflops or one with 2 bits flipflop stores 1 bit"
  SIGNAL counter_set : STD_LOGIC;                   
  SIGNAL counter_out : STD_LOGIC_VECTOR(counter_size DOWNTO 0) := (OTHERS => '0'); --counter output initialy is set to 0
  SIGNAL r : STD_LOGIC; -- same as the resalt 
  
begin

counter_set <= flipflops(0) xor flipflops(1);

process(clk,enable,close)
  begin
     if(clk'event and clk='1')then
  
  -- debouncing for the close button 
  
      flipflops(0) <= close;
      flipflops(1) <= flipflops(0);
      If(counter_set = '1') THEN           --reset counter because input is changing
        counter_out <= (OTHERS => '0');
      ELSIF(counter_out(counter_size) = '0') THEN --stable input time is not yet met check the most seg if 1 then the next clock cycle will carry 1 giving a result
        counter_out <= counter_out + 1;
      ELSE                                        
        r <= flipflops(1);
		  result<=r;
      END IF; 
		
		
		-- opening 
	if(enable='1')then
	   i<=i+1;
	   flag_pushed <=1;
		
	  if(i<25000000)then
		
			if(counter <= 225000)then
		     pwm2 <='1';
			 counter <= counter+1;
			 elsif(counter > 225000 and counter <= 275000)then
			 pwm2 <='0';
			 counter <= counter+1;
			 else
			 counter <= 0;
			 end if;
			 
	 elsif(i>=25000000)then 
			if(counter <= 225000)then
		     pwm <='1';
			 counter <= counter+1;
				--loop for 4.5 + 1 mili sec with low pwm
			 elsif(counter > 225000 and counter <= 275000)then
			 pwm <='0';
			 counter <= counter+1;
			 else
			 counter <= 0;
			 end if;
	end if;
			 
	   if(bigcounter>=50000000)then
		i<=0;
   	bigcounter <= 0;
			 end if;
			
	
	
	elsif(enable='0')then
	
		 if(bigcounter<50000000 and flag_pushed=1)then
		     i<=i+1;
		   if(i<25000000)then
			
			if(counter <= 225000)then
		     pwm2 <='1';
			 counter <= counter+1;
			 elsif(counter > 225000 and counter <= 275000)then
			 pwm2 <='0';
			 counter <= counter+1;
			 else
			 counter <= 0;
			 
			 end if;
			 
	    elsif(i>=25000000)then 
	 
		     if(counter <= 225000)then
		      pwm <='1';
			  counter <= counter+1;
	--loop for 4.5 + 1 mili sec with low pwm
			   elsif(counter > 225000 and counter <= 275000)then
			   pwm <='0';
			   counter <= counter+1;
				else
			   counter <= 0;
			   end if;
		      bigcounter<= bigcounter+1;
		  end if;
	   else
		    i<=0;
		    pwm <='0';
			 pwm2 <='0';
	  end if;
end if;
	
	
	
	
	
	-- closing
	


 if(r='1')then
	
	 flag_pushed2 <=1;
	 i2 <= i2+1;
	 
if(i2<25000000)then
	 if(counter2 <= 150000)then
		     pwm <='0';
			 counter2 <= counter2 + 1;
				--loop for 3 ( low + .5 mili sec with high pwm
			 elsif(counter2 > 150000 and counter2 <= 175000)then
			 pwm <='1';
			 counter2 <= counter2 +1;
			 else
			 counter2 <= 0;
			 end if;
			 
			 
 elsif(i2>=25000000)then
	 
			if(counter2 <= 150000)then
		     pwm2 <='0';
			 counter2 <= counter2 + 1;
				--loop for 3 ( low + .5 mili sec with high pwm
			 elsif(counter2 > 150000 and counter2 <= 175000)then
			 pwm2 <='1';
			 counter2 <= counter2 +1;
			 else
			 counter2 <= 0;
			 end if;
 end if;
			 
	   if(bigcounter2>=50000000)then
   	bigcounter2 <= 0;
		i2<=0;
			 end if;
			
	

	
	elsif(r='0')then
	
	if(bigcounter2<50000000 and flag_pushed2=1)then
		 i2<=i2+1;
		 if(i2<25000000)then
			
			if(counter2 <= 150000)then
		      pwm <='0';
			  counter2 <= counter2+1;
	         --loop for 4.5 + 1 mili sec with low pwm
			   elsif(counter2 > 150000 and counter2 <= 175000)then
			   pwm <='1';
			   counter2 <= counter2 +1;
				else
			   counter2 <= 0;
			   end if;
				
		 elsif(i2>=25000000)then 
		 
		     if(counter2 <= 150000)then
		      pwm2 <='0';
			  counter2 <= counter2+1;
	         --loop for 4.5 + 1 mili sec with low pwm
			   elsif(counter2 > 150000 and counter2 <= 175000)then
			   pwm2 <='1';
			   counter2 <= counter2 +1;
				else
			   counter2 <= 0;
			   end if;
		 end if;
		      bigcounter2<= bigcounter2 +1;
		 end if;
	end if;	
	
    END IF;      
      end process;
end Behavioral;

