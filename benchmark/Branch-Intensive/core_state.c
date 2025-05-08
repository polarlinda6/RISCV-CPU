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
  * MODIFICATIONS for RISC-V CPU Project (Benchmark Version)
  * Based on: core_state.c (original version in this project)
  * By: Linda6
  * Date: 2025-05-08
  *
  * Benchmark results/details: https://godbolt.org/z/1qh6dxceP
  * 
  * Purpose: This file is a modified version of the original core_state.c from 
  *          the EEMBC CoreMark benchmark suite. It has been adapted to serve as 
  *          a standalone C benchmark for a RISC-V CPU, focusing on the state 
  *          machine logic for parsing numeric strings.
  *
  * Key differences from original core_state.c:
  * - Dependency on coremark.h removed: Typedefs (ee_u8, ee_u32), enums 
  *   (CORE_STATE), and constants (NUM_CORE_STATES) are now defined directly 
  *   within this file.
  * - Removed core_bench_state() and core_init_state(): The benchmark 
  *   initialization and execution logic, including CRC calculation and input 
  *   string generation/corruption, have been removed to simplify the code for 
  *   direct execution of the state machine with a fixed input.
  * - Simplified main() function: A new main() function is introduced to directly 
  *   drive the core_state_transition() function with a predefined test string. 
  *   It initializes counters and processes the input string token by token.
  * - Output to RISC-V Registers: Instead of printing results or calculating CRC, 
  *   the final_state_counts and transition_counts arrays are written to 
  *   specific RISC-V registers (a0-a7 for final_state_counts, s0-s7 for 
  *   transition_counts) using inline assembly. This is for direct observation 
  *   of results in a CPU simulation/emulation environment.
  * - Removed printf and stdio.h: All printf statements and the inclusion of 
  *   stdio.h have been removed to eliminate external I/O dependencies, making 
  *   the code more suitable for bare-metal or restricted environments.
  * - Standalone Compilation: The modifications allow this file to be compiled 
  *   and run as a self-contained C program (e.g., for a RISC-V target) 
  *   without the rest of the CoreMark framework.
  * - Modified core_state_transition() for standalone use: While the core FSM logic 
  *   is largely preserved, its invocation and the way transition counts are handled 
  *   are adapted for the new main() function. Specifically, the logic for 
  *   incrementing transition_count[CORE_SCIENTIFIC] and 
  *   transition_count[CORE_INVALID] in certain cases was adjusted slightly 
  *   compared to the original, and a case for `ee_isdigit(NEXT_SYMBOL)` after 
  *   `CORE_S2` was clarified to transition to `CORE_SCIENTIFIC`.
  * ---------------------------------------------------------------------------- 
  */

// Define necessary types (originally from coremark.h)
typedef unsigned char ee_u8;
typedef signed short ee_s16; // Not used in this simplified version, but kept for consistency
typedef unsigned int ee_u32;

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

// Example main function to drive the state machine
int main() {
    // Test strings - you can modify these or provide input differently
    ee_u8 test_input_string[] = "5012,.1234500,-110.700,+0.64400,5.500e+3,-.123e-2,-87e+832,+0.6e-12,T0.3e-1F,-T.T++Tq,1T3.4e4z,34.0e-T^";
    ee_u8 *p_input = test_input_string;
    ee_u32 transition_counts[NUM_CORE_STATES];
    ee_u32 final_state_counts[NUM_CORE_STATES];
    int i;

    for (i = 0; i < NUM_CORE_STATES; i++) {
        transition_counts[i] = 0;
        final_state_counts[i] = 0;
    }

    while (*p_input != '\0') {
        ee_u8 *token_start = p_input;
        enum CORE_STATE final_state = core_state_transition(&p_input, transition_counts);
        final_state_counts[final_state]++;
        
        // Print the token that was just processed
        // Find the end of the processed token (either comma or null terminator from p_input before core_state_transition incremented it)
        ee_u8 *token_end = p_input;
        if (*(token_end-1) == ',') { // If it ended with a comma, don't print the comma as part of the token
            token_end--;
        }
        if (*p_input == '\0') break; // End of string
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