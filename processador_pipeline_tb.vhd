library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity processador_pipeline_tb is
end entity;

architecture behaviour of processador_pipeline_tb is

component processador_pipeline
    port (
        clk	: in std_logic;
        reset	: in std_logic
        
        );
    end component;
    
    signal clock_sg	    : std_logic := '0';
    signal reset_sg	    : std_logic := '1';

begin

    UUT: processador_pipeline port map (
        clk	=> clock_sg,
        reset	=> reset_sg
        );
        
        clock_sg <= not clock_sg after 5 ns;
        reset_sg <=  '0' after 10 ps;
    
    
end behaviour;