/**
 * MC68230 ports definitions for SBC68K
 *
 * Author: Daniel Nery Silva de Oliveira
 * Escola Politécnica da USP
 *
 * See https://neo.dmcs.pl/pn/MC68230.pdf
 *
 * 04/2018
 */

typedef unsigned char uint8_t;
typedef volatile uint8_t* reg_t;
typedef volatile uint8_t* const creg_t;

#define BASE_ADDR 0xFE8001

#define _addr8(reg_select)   ((reg_t)(((reg_select) << 1) + BASE_ADDR))

extern creg_t PGCR;     // Port General Control Register
extern creg_t PSRR;     // Port Service Request Register

// Port X Data Direction Registers
extern creg_t PADDR;
extern creg_t PBDDR;
extern creg_t PCDDR;

extern creg_t PIVR;    // Port Interrupt Vector Register

// Port X Control Registers
extern creg_t PACR;
extern creg_t PBCR;

// Port X Data Registers
extern creg_t PADR;
extern creg_t PBDR;
extern creg_t PCAR;

// Port X Alternate Register
extern creg_t PAAR;
extern creg_t PBAR;

extern creg_t PSR ;    // Port Status Register
extern creg_t TCR ;    // Timer Control Register
extern creg_t TIVR;    // Timer Interrupt Vecto Register

// Counter Preload Register High, Middle, Low
extern creg_t CPRH;
extern creg_t CPRM;
extern creg_t CPRL;

// Count Register High, Middle, Low
extern creg_t CNTRH;
extern creg_t CNTRM;
extern creg_t CNTRL;

extern creg_t TSR  ;    // Timer Status Register
