/*
Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Original Author: Shay Gal-on
*/

/*
 * ----------------------------------------------------------------------------
 * RISC-V CPU Branch-Intensive Benchmark Program
 * Based on: https://github.com/eembc/coremark/blob/main/core_state.c
 * Modified by: Linda6
 * Date: 2023-05-08
 *
 * Benchmark results/details: https://godbolt.org/z/P7nnbrnPW
 *
 * Description:
 * This file is a modified version of the original core_state.c from the EEMBC
 * CoreMark benchmark suite. It has been adapted to serve as a standalone C
 * benchmark for a RISC-V CPU, focusing on the state machine logic for parsing
 * numeric strings. The implementation generates numerous branch instructions,
 * making it ideal for testing CPU branch prediction performance.
 *
 * Key Modifications:
 * - Ensured iteration count 'itot' is set to 10000.
 * - Removed dependency on coremark.h, directly defining necessary types and constants
 * - Removed core_bench_state() and core_init_state() functions, simplifying benchmark logic
 * - Added new main() function to directly drive the state machine with predefined test strings
 * - Added generate_test_string() function to create test inputs based on itot parameter
 * - Used inline assembly to write results directly to RISC-V registers for observation
 * - Removed printf and stdio.h dependencies for better compatibility with bare-metal environments
 * - Modified core_state_transition() function for standalone use
 * ----------------------------------------------------------------------------
 */


// Define necessary types (originally from coremark.h)
typedef unsigned char ee_u8;
typedef unsigned ee_u32;

// CoreMark specific enums and constants (originally from coremark.h)
#define NUM_CORE_STATES 8
enum CORE_STATE
{
    CORE_START = 0,
    CORE_S1,
    CORE_INT,
    CORE_FLOAT,
    CORE_S2,
    CORE_EXPONENT,
    CORE_SCIENTIFIC,
    CORE_INVALID
};

// Forward declaration
static ee_u8 ee_isdigit(ee_u8 c);
enum CORE_STATE core_state_transition(ee_u8 **instr, ee_u32 *transition_count);

static ee_u8
ee_isdigit(ee_u8 c)
{
    ee_u8 retval;
    retval = ((c >= '0') && (c <= '9')) ? 1 : 0;
    return retval;
}

/* Function: core_state_transition
        Actual state machine.
        The state machine will continue scanning until either:
        1 - an invalid input is detected.
        2 - a valid number has been detected.
        The input pointer is updated to point to the end of the token, and the
   end state is returned (either specific format determined or invalid).
*/
enum CORE_STATE
core_state_transition(ee_u8 **instr, ee_u32 *transition_count)
{
    ee_u8 *str = *instr;
    ee_u8 NEXT_SYMBOL;
    enum CORE_STATE state = CORE_START;
    for (; *str && state != CORE_INVALID; str++)
    {
        NEXT_SYMBOL = *str;
        if (NEXT_SYMBOL == ',') /* end of this input */
        {
            str++;
            break;
        }
        switch (state)
        {
            case CORE_START:
                if (ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_INT;
                }
                else if (NEXT_SYMBOL == '+' || NEXT_SYMBOL == '-')
                {
                    state = CORE_S1;
                }
                else if (NEXT_SYMBOL == '.')
                {
                    state = CORE_FLOAT;
                }
                else
                {
                    state = CORE_INVALID;
                    transition_count[CORE_INVALID]++;
                }
                transition_count[CORE_START]++;
                break;
            case CORE_S1:
                if (ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_INT;
                    transition_count[CORE_S1]++;
                }
                else if (NEXT_SYMBOL == '.')
                {
                    state = CORE_FLOAT;
                    transition_count[CORE_S1]++;
                }
                else
                {
                    state = CORE_INVALID;
                    transition_count[CORE_S1]++;
                }
                break;
            case CORE_INT:
                if (NEXT_SYMBOL == '.')
                {
                    state = CORE_FLOAT;
                    transition_count[CORE_INT]++;
                }
                else if (!ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_INVALID;
                    transition_count[CORE_INT]++;
                }
                break;
            case CORE_FLOAT:
                if (NEXT_SYMBOL == 'E' || NEXT_SYMBOL == 'e')
                {
                    state = CORE_S2;
                    transition_count[CORE_FLOAT]++;
                }
                else if (!ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_INVALID;
                    transition_count[CORE_FLOAT]++;
                }
                break;
            case CORE_S2:
                if (NEXT_SYMBOL == '+' || NEXT_SYMBOL == '-')
                {
                    state = CORE_EXPONENT;
                    transition_count[CORE_S2]++;
                }
                else if (ee_isdigit(NEXT_SYMBOL)) // Allow digit after E/e based on some interpretations, original coremark is stricter
                {
                    state = CORE_SCIENTIFIC; // Or CORE_EXPONENT depending on exact FSM desired
                    transition_count[CORE_S2]++;
                }
                else
                {
                    state = CORE_INVALID;
                    transition_count[CORE_S2]++;
                }
                break;
            case CORE_EXPONENT:
                if (ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_SCIENTIFIC;
                    transition_count[CORE_EXPONENT]++;
                }
                else
                {
                    state = CORE_INVALID;
                    transition_count[CORE_EXPONENT]++;
                }
                break;
            case CORE_SCIENTIFIC:
                if (!ee_isdigit(NEXT_SYMBOL))
                {
                    state = CORE_INVALID;
                    // According to core_state.png, transition from SCIENTIFIC on non-digit leads to INVALID.
                    // The original code has transition_count[CORE_INVALID]++ here.
                    // Let's stick to incrementing the state we are transitioning FROM, or the target if it's INVALID.
                    transition_count[CORE_SCIENTIFIC]++; // Count transition from scientific
                }
                // If it's a digit, it stays in SCIENTIFIC state, loop continues, count for SCIENTIFIC happens on next non-digit or EOI.
                break;
            default:
                break;
        }
    }
    *instr = str;
    return state;
}


// Static buffer for storing the generated string
#define MAX_STRING_SIZE 10000
static ee_u8 string_buffer[MAX_STRING_SIZE];

// Simple pseudo-random number generator
static ee_u32 rand_seed = 0;

static ee_u32 rand_next() {
    rand_seed = rand_seed * 1103515245 + 12345;
    return (rand_seed >> 16) & 0x7FFF;
}

// Generate a random digit character
static ee_u8 rand_digit() {
    return '0' + (rand_next() % 10);
}

// Generate a random sign character (+ or -)
static ee_u8 rand_sign() {
    return (rand_next() % 2) ? '+' : '-';
}

// Generate a random exponent character (e or E)
static ee_u8 rand_exponent() {
    return (rand_next() % 2) ? 'e' : 'E';
}

// Generate a random special character
static ee_u8 rand_special() {
    static const ee_u8 specials[] = {'T', 'F', 'q', 'z', '^'};
    return specials[rand_next() % 5];
}

// Add a character to the buffer, ensuring it doesn't overflow
static void add_char(ee_u8* buffer, ee_u32* pos, ee_u32 max_size, ee_u8 c) {
    if (*pos < max_size - 1) {
        buffer[(*pos)++] = c;
    }
}

// Add a sequence of digits to the buffer
static void add_digits(ee_u8* buffer, ee_u32* pos, ee_u32 max_size, ee_u32 count) {
    for (ee_u32 i = 0; i < count; i++) {
        add_char(buffer, pos, max_size, rand_digit());
    }
}

// Generate a random integer format string
static void gen_integer(ee_u8* buffer, ee_u32* pos, ee_u32 max_size, ee_u8 with_sign) {
    if (with_sign && (rand_next() % 2)) {
        add_char(buffer, pos, max_size, rand_sign());
    }
    
    // Generate 1-5 random digits
    add_digits(buffer, pos, max_size, (rand_next() % 5) + 1);
}

// Generate a random floating-point format string
static void gen_float(ee_u8* buffer, ee_u32* pos, ee_u32 max_size, ee_u8 with_sign) {
    if (with_sign && (rand_next() % 2)) {
        add_char(buffer, pos, max_size, rand_sign());
    }
    
    // Integer part (may be empty)
    if (rand_next() % 3 > 0) { // 2/3 probability of having an integer part
        add_digits(buffer, pos, max_size, (rand_next() % 3) + 1);
    }
    
    // Decimal point
    add_char(buffer, pos, max_size, '.');
    
    // Fractional part
    add_digits(buffer, pos, max_size, (rand_next() % 5) + 1);
}

// Generate a random scientific notation format string
static void gen_scientific(ee_u8* buffer, ee_u32* pos, ee_u32 max_size, ee_u8 with_sign) {
    // First generate a floating-point number
    gen_float(buffer, pos, max_size, with_sign);
    
    // Add exponent part
    add_char(buffer, pos, max_size, rand_exponent());
    
    // Exponent sign (optional)
    if (rand_next() % 2) {
        add_char(buffer, pos, max_size, rand_sign());
    }
    
    // Exponent value
    add_digits(buffer, pos, max_size, (rand_next() % 3) + 1);
}

// Generate an invalid format string (containing illegal characters)
static void gen_invalid(ee_u8* buffer, ee_u32* pos, ee_u32 max_size) {
    // Randomly select an invalid mode
    switch (rand_next() % 5) {
        case 0: // Letter at the beginning
            add_char(buffer, pos, max_size, rand_special());
            gen_float(buffer, pos, max_size, 0);
            break;
            
        case 1: // Insert letter in the middle
            gen_integer(buffer, pos, max_size, 1);
            add_char(buffer, pos, max_size, rand_special());
            gen_float(buffer, pos, max_size, 0);
            break;
            
        case 2: // Invalid exponent part
            gen_float(buffer, pos, max_size, 1);
            add_char(buffer, pos, max_size, rand_exponent());
            add_char(buffer, pos, max_size, rand_special());
            break;
            
        case 3: // Consecutive signs
            add_char(buffer, pos, max_size, rand_sign());
            add_char(buffer, pos, max_size, rand_sign());
            add_char(buffer, pos, max_size, rand_special());
            add_char(buffer, pos, max_size, '.');
            add_char(buffer, pos, max_size, rand_special());
            break;
            
        case 4: // Mixed special characters
            if (rand_next() % 2) {
                add_char(buffer, pos, max_size, rand_digit());
            } else {
                add_char(buffer, pos, max_size, rand_sign());
            }
            add_char(buffer, pos, max_size, rand_special());
            add_char(buffer, pos, max_size, '.');
            add_char(buffer, pos, max_size, rand_digit());
            add_char(buffer, pos, max_size, rand_exponent());
            add_char(buffer, pos, max_size, rand_special());
            break;
    }
}

// Main function: Generate branch-intensive test string with specified length
ee_u8* generate_test_string(ee_u32 itot) {
    ee_u32 pos = 0;
    ee_u32 token_count = 0;
    
    // Reset random seed, can use a fixed value or based on some system state
    rand_seed = 0x12345678 ^ (itot * 16777619);
    
    // Generate multiple tokens, each separated by a comma
    while (token_count < itot && pos < MAX_STRING_SIZE - 20) {
        // Randomly select a format
        ee_u32 format = rand_next() % 10;
        
        switch (format) {
            case 0: // Simple integer
            case 1:
                gen_integer(string_buffer, &pos, MAX_STRING_SIZE, 0);
                break;
                
            case 2: // Signed integer
                gen_integer(string_buffer, &pos, MAX_STRING_SIZE, 1);
                break;
                
            case 3: // Simple floating-point
                gen_float(string_buffer, &pos, MAX_STRING_SIZE, 0);
                break;
                
            case 4: // Signed floating-point
                gen_float(string_buffer, &pos, MAX_STRING_SIZE, 1);
                break;
                
            case 5: // Scientific notation
            case 6:
                gen_scientific(string_buffer, &pos, MAX_STRING_SIZE, 0);
                break;
                
            case 7: // Signed scientific notation
                gen_scientific(string_buffer, &pos, MAX_STRING_SIZE, 1);
                break;
                
            case 8: // Invalid format 1
            case 9: // Invalid format 2
                gen_invalid(string_buffer, &pos, MAX_STRING_SIZE);
                break;
        }
        
        // Add separator
        add_char(string_buffer, &pos, MAX_STRING_SIZE, ',');
        token_count++;
    }
    
    string_buffer[pos] = '\0';
    return string_buffer;
}
 
int main() {
    ee_u32 itot = 10000; 
    ee_u32 transition_counts[NUM_CORE_STATES] = {};
    ee_u32 final_state_counts[NUM_CORE_STATES] = {};
    
    for (ee_u8* p_input = generate_test_string(itot); *p_input != '\0';) {
        enum CORE_STATE final_state = core_state_transition(&p_input, transition_counts);
        ++final_state_counts[final_state];
    }

    // Results to registers
    // Final state counts (how many tokens ended in each state)
    if (NUM_CORE_STATES >= 1) asm("mv t1, %0" : : "r" (final_state_counts[0]));
    if (NUM_CORE_STATES >= 2) asm("mv t2, %0" : : "r" (final_state_counts[1]));
    if (NUM_CORE_STATES >= 3) asm("mv s2, %0" : : "r" (final_state_counts[2]));
    if (NUM_CORE_STATES >= 4) asm("mv s3, %0" : : "r" (final_state_counts[3]));
    if (NUM_CORE_STATES >= 5) asm("mv s4, %0" : : "r" (final_state_counts[4]));
    if (NUM_CORE_STATES >= 6) asm("mv s5, %0" : : "r" (final_state_counts[5]));
    if (NUM_CORE_STATES >= 7) asm("mv s6, %0" : : "r" (final_state_counts[6]));
    if (NUM_CORE_STATES >= 8) asm("mv s7, %0" : : "r" (final_state_counts[7]));
    
    // Transition counts (how many transitions occurred from each state)
    if (NUM_CORE_STATES >= 1) asm("mv s8,  %0" : : "r" (transition_counts[0]));
    if (NUM_CORE_STATES >= 2) asm("mv s9,  %0" : : "r" (transition_counts[1]));
    if (NUM_CORE_STATES >= 3) asm("mv s10, %0" : : "r" (transition_counts[2]));
    if (NUM_CORE_STATES >= 4) asm("mv s11, %0" : : "r" (transition_counts[3]));
    if (NUM_CORE_STATES >= 5) asm("mv t3,  %0" : : "r" (transition_counts[4]));
    if (NUM_CORE_STATES >= 6) asm("mv t4,  %0" : : "r" (transition_counts[5]));
    if (NUM_CORE_STATES >= 7) asm("mv t5,  %0" : : "r" (transition_counts[6]));
    if (NUM_CORE_STATES >= 8) asm("mv t6,  %0" : : "r" (transition_counts[7]));

    return 0;
}