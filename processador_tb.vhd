LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY processador_tb IS
END ENTITY;

ARCHITECTURE behaviour OF processador_tb IS
    COMPONENT processador
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clock_sg : STD_LOGIC := '0';
    SIGNAL reset_sg : STD_LOGIC := '0';

BEGIN
    UUT : processador PORT MAP(
        clock => clock_sg,
        reset => reset_sg
    );

    clock_sg <= NOT clock_sg AFTER 5 ns;
    reset_sg <= '1' AFTER 10 ps;
END behaviour;