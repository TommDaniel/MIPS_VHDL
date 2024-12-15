LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY processador IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behaviour OF processador IS
    SIGNAL PC : STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE mem IS ARRAY (INTEGER RANGE 0 TO 254) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    TYPE reg IS ARRAY (INTEGER RANGE 0 TO 15) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL regs : reg;
    SIGNAL mem_inst : mem;
    SIGNAL mem_data : mem;

    SIGNAL endereco_registrador0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL endereco_registrador1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL endereco_registrador_dest : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL desvio : STD_LOGIC;
    SIGNAL op_code : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ula : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL equal : STD_LOGIC;
    SIGNAL mult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL soma : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL subt : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL BEQ : STD_LOGIC;
    SIGNAL BNE : STD_LOGIC;
    SIGNAL SW : STD_LOGIC;
    SIGNAL instrucao : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL endereco : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL enable_reg : STD_LOGIC;

BEGIN
    --memoria de intrução com 255 posições
    mem_inst <= (0 => "1110010000000001", 1 => "1010010101000101", 2 => "0000000000000010", 3 => "0000000100000011", 4 => "0010010000010000", 5 => "1100000000000000", OTHERS => (OTHERS => '0'));

    --endereço para saltos, load e store
    endereco <= instrucao(7 DOWNTO 0);
    --pega a instrução da memoria de instruções
    instrucao <= mem_inst(conv_integer(PC));
    --pega o opcode da instrução
    op_code <= instrucao(15 DOWNTO 13);

    --regitradores
    endereco_registrador0 <= instrucao(3 DOWNTO 0);
    endereco_registrador1 <= instrucao(7 DOWNTO 4);
    endereco_registrador_dest <= instrucao(11 DOWNTO 8);

    --verifica se é uma instrução que usa registradores
    enable_reg <= '1' WHEN (op_code = "000") OR (op_code = "001") OR (op_code = "010") OR (op_code = "011") OR (op_code = "111") ELSE
        '0';
    --verifica se é uma instrução de salto
    desvio <= '1' WHEN BEQ = '1' OR BNE = '1' OR (op_code = "110") ELSE
        '0';
    --verifica se os registradores são iguais
    equal <= '1' WHEN regs(conv_integer(endereco_registrador0)) = regs(conv_integer(endereco_registrador1)) ELSE
        '0';
    --operações da ula
    soma <= regs(conv_integer(endereco_registrador0)) + regs(conv_integer(endereco_registrador1));
    subt <= regs(conv_integer(endereco_registrador0)) - regs(conv_integer(endereco_registrador1));
    mult <= regs(conv_integer(endereco_registrador0)) * regs(conv_integer(endereco_registrador1));
    --verifica se é uma instrução de store
    SW <= '1' WHEN op_code = "111" ELSE
        '0';
    --verifica se é uma instrução de branch
    BEQ <= '1' WHEN op_code = "100" AND equal = '1' ELSE
        '0';
    BNE <= '1' WHEN op_code = "101" AND equal = '0' ELSE
        '0';

    -- ULA
    ula <= mem_data(conv_integer(endereco)) WHEN op_code(1 DOWNTO 0) = "00" ELSE
        soma WHEN op_code(1 DOWNTO 0) = "01" ELSE
        subt WHEN op_code(1 DOWNTO 0) = "10" ELSE
        mult(15 DOWNTO 0);
    
        
    PROCESS (reset, clock)
    BEGIN
        IF (reset = '0') THEN
            PC <= (OTHERS => '0');
            mem_data <= (1 => "0000000000000001", 2 => "0000000000000010", 3 => "0000000000000011", OTHERS => (OTHERS => '0'));

            regs <= (OTHERS => (OTHERS => '0'));
        ELSIF (clock = '1' AND clock'event) THEN
            -- logica pro PC
            IF (desvio = '0') THEN
                PC <= PC + 1;
            ELSE
                IF (BEQ = '1') THEN
                    PC <= PC + 1 + endereco_registrador_dest;
                ELSIF (BNE = '1') THEN
                    PC <= PC + 1 + endereco_registrador_dest;
                ELSE
                    PC <= endereco;
                END IF;
            END IF;
            IF (enable_reg = '1') THEN
                IF (SW = '1') THEN
                    mem_data(conv_integer(endereco)) <= regs(conv_integer(endereco_registrador_dest));
                ELSE
                    regs(conv_integer(endereco_registrador_dest)) <= ula;
                END IF;
            END IF;
        END IF;

    END PROCESS;

END behaviour;