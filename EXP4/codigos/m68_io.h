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

creg_t PGCR =  _addr8(0x00);     // Port General Control Register
creg_t PSRR =  _addr8(0x01);     // Port Service Request Register

// Port X Data Direction Registers
creg_t PADDR = _addr8(0x02);
creg_t PBDDR = _addr8(0x03);
creg_t PCDDR = _addr8(0x04);

creg_t PIVR =  _addr8(0x05);    // Port Interrupt Vector Register

// Port X Control Registers
creg_t PACR =  _addr8(0x06);
creg_t PBCR =  _addr8(0x07);

// Port X Data Registers
creg_t PADR =  _addr8(0x08);
creg_t PBDR =  _addr8(0x09);
creg_t PCAR =  _addr8(0x0C);

// Port X Alternate Register
creg_t PAAR =  _addr8(0x0A);
creg_t PBAR =  _addr8(0x0B);

creg_t PSR  =  _addr8(0x0D);    // Port Status Register
creg_t TCR  =  _addr8(0x10);    // Timer Control Register
creg_t TIVR =  _addr8(0x11);    // Timer Interrupt Vecto Register

// Counter Preload Register High, Middle, Low
creg_t CPRH =  _addr8(0x13);
creg_t CPRM =  _addr8(0x14);
creg_t CPRL =  _addr8(0x15);

// Count Register High, Middle, Low
creg_t CNTRH = _addr8(0x17);
creg_t CNTRM = _addr8(0x18);
creg_t CNTRL = _addr8(0x19);

creg_t TSR   = _addr8(0x1A);    // Timer Status Register
