--
-- Written by Michael Mattioli
--
-- Description: RC5 top-level design.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.all;

entity rc5_top is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            sel         : in std_logic; -- High = encrypt, low = decrypt.
            key         : in K; -- Secret key, K.
            data_in     : in std_logic_vector((W'length * 2)-1 downto 0);
            data_out    : out std_logic_vector((W'length * 2)-1 downto 0));
end rc5_top;

architecture behavioral of rc5_top is

    component rc5_key_expansion is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                key         : in K; -- Secret key, K.
                key_array   : out S); -- Key array, S.
    end component;

    component rc5_encrypt is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                plaintext   : in std_logic_vector((W'length * 2)-1 downto 0);
                key_array   : in S; -- Key array, S.
                ciphertext  : out std_logic_vector((W'length * 2)-1 downto 0));
    end component;

    component rc5_decrypt is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                ciphertext  : in std_logic_vector((W'length * 2)-1 downto 0);
                key_array   : in S; -- Key array, S.
                plaintext   : out std_logic_vector((W'length * 2)-1 downto 0));
    end component;

    signal array_s : S;
    signal enc_out : std_logic_vector((W'length * 2)-1 downto 0);
    signal dec_out : std_logic_vector((W'length * 2)-1 downto 0);

begin

    key_expand: rc5_key_expansion port map (clk => clk,
                                            rst => rst,
                                            key => key,
                                            key_array => array_s);

    encrypt: rc5_encrypt port map ( clk => clk,
                                    rst => rst,
                                    plaintext => data_in,
                                    key_array => array_s,
                                    ciphertext => enc_out);

    decrypt: rc5_decrypt port map ( clk => clk,
                                    rst => rst,
                                    ciphertext => data_in,
                                    key_array => array_s,
                                    plaintext => dec_out);

    data_out <= enc_out when sel = '1' else dec_out;

end behavioral;
