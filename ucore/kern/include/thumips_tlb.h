#ifndef _THUMIPS_TLB_H
#define _THUMIPS_TLB_H

#include <asm/mipsregs.h>
#include <memlayout.h>
#include <glue_pgmap.h>

#define THUMIPS_TLB_ENTRYL_V (1<<1)
#define THUMIPS_TLB_ENTRYL_D (1<<2)
#define THUMIPS_TLB_ENTRYL_G (1<<0)
#define THUMIPS_TLB_ENTRYH_VPN2_MASK (~0x1FFF)



static inline void write_one_tlb(int index, unsigned int pagemask, unsigned int hi, unsigned int low0, unsigned int low1)
{
	write_c0_entrylo0(low0);
	//write_c0_pagemask(pagemask);
	write_c0_entrylo1(low1);
	write_c0_entryhi(hi);
	write_c0_index(index);
	tlb_write_indexed();
}

#define PTE2TLBLOW(x) (((((uint32_t)(*(x))-KERNBASE)>> 12)<<6)|THUMIPS_TLB_ENTRYL_V|THUMIPS_TLB_ENTRYL_D|(2<<3))
static inline uint32_t pte2tlblow(pte_t pte)
{
  uint32_t t = (((uint32_t)pte - KERNBASE ) >> 12)<<6;
  if(!ptep_present(&pte))
    return 0;
  t |= THUMIPS_TLB_ENTRYL_V;
  /* always ignore ASID */
  t |= THUMIPS_TLB_ENTRYL_G;
  t |= (2<<3);
  if(ptep_s_write(&pte))
    t |= THUMIPS_TLB_ENTRYL_D;
  return t;
}

static inline void tlb_refill(uint32_t badaddr, pte_t *pte)
{
  if(!pte)
    return ;
  if(badaddr & (1<<12))
    pte--;
  static unsigned int index = 0;
  write_one_tlb(index & 0x0000000F, 0, badaddr & THUMIPS_TLB_ENTRYH_VPN2_MASK, pte2tlblow(*pte), pte2tlblow(*(pte+1)));
  index++;
}

void tlb_invalidate_all();
#endif
