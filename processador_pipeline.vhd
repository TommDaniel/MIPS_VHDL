LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY processador_pipeline IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behaviour OF processador_pipeline IS

    SIGNAL IF_ID_pc : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IF_ID_instr : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_pc : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_instr : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_R0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_R1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_alu_result : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_pc : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_instr : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_R0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_R1 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_alu_result : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WB_MEM_instr : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    
    TYPE mem IS ARRAY (INTEGER RANGE 0 TO 254) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    TYPE reg IS ARRAY (INTEGER RANGE 0 TO 15) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mem_inst : mem;
    SIGNAL mem_data : mem;
    SIGNAL reg_file : reg;
    SIGNAL reg_dest : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL reg0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL reg1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL endereco : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL WB_MEM_ENDERECO : STD_LOGIC_VECTOR(7 DOWNTO 0);

    CONSTANT ADD_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
    CONSTANT SUB_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";
    CONSTANT MULT_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";
    CONSTANT LOAD_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    CONSTANT SW_OP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";

    SIGNAL mult : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL soma : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL subt : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    --memoria de intrução com 255 posições
    mem_inst <= ( 0 => "0000001000000010", 1 => "0000000100000011", 4 => "0010010000010010", 7 => "1110010000000001", OTHERS => (OTHERS => '0'));

    endereco <= EX_MEM_instr(7 DOWNTO 0);
    --selecionando registradores 
    reg_dest <= WB_MEM_instr(11 DOWNTO 8);
    reg0 <= ID_EX_instr(3 DOWNTO 0);
    reg1 <= ID_EX_instr(7 DOWNTO 4);


    soma <= ID_EX_R0 + ID_EX_R1;
    subt <= ID_EX_R0 - ID_EX_R1;
    mult <= ID_EX_R0 * ID_EX_R1;
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            mem_data <= (1 => "0000000000000001", 2 => "0000000000000010", 3 => "0000000000000011", OTHERS => (OTHERS => '0'));

            reg_file <= (OTHERS => (OTHERS => '0'));

            IF_ID_pc <= (OTHERS => '0');
            IF_ID_instr <= (OTHERS => '0');
            ID_EX_pc <= (OTHERS => '0');
            ID_EX_instr <= (OTHERS => '0');
            ID_EX_R0 <= (OTHERS => '0');
            ID_EX_R1 <= (OTHERS => '0');
            ID_EX_alu_result <= (OTHERS => '0');
            EX_MEM_pc <= (OTHERS => '0');
            EX_MEM_instr <= (OTHERS => '0');
            EX_MEM_R0 <= (OTHERS => '0');
            EX_MEM_R1 <= (OTHERS => '0');
            EX_MEM_alu_result <= (OTHERS => '0');
            

        ELSIF rising_edge(clk) THEN
            -- IF Stage
            IF_ID_pc <= IF_ID_pc + 1;
            IF_ID_instr <= mem_inst(conv_integer(IF_ID_pc));

            -- ID Stage
            ID_EX_pc <= IF_ID_pc;
            ID_EX_instr <= IF_ID_instr;
            ID_EX_R0 <= reg_file(conv_integer(reg0));
            ID_EX_R1 <= reg_file(conv_integer(reg1));
            
            -- EX Stage
            EX_MEM_pc <= ID_EX_pc;
            EX_MEM_instr <= ID_EX_instr;
            EX_MEM_R0 <= ID_EX_R0;
            EX_MEM_R1 <= ID_EX_R1;
            CASE EX_MEM_instr(15 DOWNTO 13) IS
                WHEN ADD_OP => EX_MEM_alu_result <= soma;
                WHEN SUB_OP => EX_MEM_alu_result <= subt;
                WHEN MULT_OP => EX_MEM_alu_result <= mult(15 DOWNTO 0);
                WHEN LOAD_OP => EX_MEM_alu_result <= mem_data(conv_integer(endereco));
                WHEN OTHERS => EX_MEM_alu_result <= (OTHERS => '0');
            END CASE;

            -- WB Stage
            WB_MEM_instr <= EX_MEM_instr;
            WB_MEM_ENDERECO <= endereco;
            CASE WB_MEM_instr(15 DOWNTO 13) IS
                WHEN LOAD_OP | ADD_OP | SUB_OP | MULT_OP =>
                    reg_file(conv_integer(reg_dest)) <= EX_MEM_alu_result;
                WHEN SW_OP =>
                    mem_data(conv_integer(WB_MEM_ENDERECO)) <= reg_file(conv_integer(reg_dest));
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

END behaviour;