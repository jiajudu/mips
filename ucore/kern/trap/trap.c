#include <defs.h>
#include <asm/mipsregs.h>
#include <clock.h>
#include <trap.h>
#include <thumips.h>
#include <thumips_tlb.h>
#include <stdio.h>
#include <mmu.h>
#include <pmm.h>
#include <memlayout.h>
#include <glue_pgmap.h>
#include <assert.h>
#include <console.h>
#include <kdebug.h>
#include <error.h>
#include <syscall.h>
#include <proc.h>
#include <thumips.h>
#define TICK_NUM 100

#define GET_CAUSE_EXCODE(x)   ( ((x) & CAUSEF_EXCCODE) >> CAUSEB_EXCCODE)

static void print_ticks() {
		PRINT_HEX("%d ticks\n",TICK_NUM);
}



static const char *
trapname(int trapno) {
		static const char * const excnames[] = {
				"Interrupt",
				"TLB Modify",
				"TLB miss on load",
				"TLB miss on store",
				"Address error on load",
				"Address error on store",
				"Bus error on instruction fetch",
				"Bus error on data load or store",
				"Syscall",
				"Breakpoint",
				"Reserved (illegal) instruction",
				"Coprocessor unusable",
				"Arithmetic overflow",
		};
		if(trapno <= 12)
			return excnames[trapno];
		else
			return "Unknown";
}

bool
trap_in_kernel(struct trapframe *tf) {
	return !(tf->tf_status & KSU_USER);
}


void print_regs(struct pushregs *regs)
{
	int i;
	for (i = 0; i < 30; i++) {
		kprintf(" $");
		printbase10(i+1);
		kprintf(": ");
		printhex(regs->reg_r[i]);
		kputchar('\n');
	}
}

void
print_trapframe(struct trapframe *tf) {
		PRINT_HEX("trapframe at ", tf);
		print_regs(&tf->tf_regs);
		PRINT_HEX(" $ra: ", tf->tf_ra);
		PRINT_HEX(" BadVA: ", tf->tf_vaddr);
		PRINT_HEX(" Status: ", tf->tf_status);
		PRINT_HEX(" Cause: ", tf->tf_cause);
		PRINT_HEX(" EPC: ", tf->tf_epc);
		if (!trap_in_kernel(tf)) {
			kprintf("Trap in usermode: ");
		}else{
			kprintf("Trap in kernel: ");
		}
		kprintf(trapname(GET_CAUSE_EXCODE(tf->tf_cause)));
		kputchar('\n');
}

static void interrupt_handler(struct trapframe *tf)
{
	extern clock_int_handler(void*);
	extern serial_int_handler(void*);
	int i;
	for(i=0;i<8;i++){
		if(tf->tf_cause & (1<<(CAUSEB_IP+i))){
			switch(i){
				case TIMER0_IRQ:
					//kprintf("+1s\n");
					clock_int_handler(NULL);
					break;
				case COM1_IRQ:
					//kprintf("serial interrupt:\n");
					serial_int_handler(NULL);
					break;
				default:
					kprintf("interrupt number: %d\n", i);
					print_trapframe(tf);
					panic("Unknown interrupt!");
			}
		}
	}

}

static int conv(char c){
    if(c > 47 && c < 58){
        return c - 48;
    }
    return c - 87;
}

static int gdbcmd(char *buf, struct trapframe *tf) {
	if(buf[0] == 'c'){
		return -1;
	}
	if(buf[0] == 'r'){
		int i;
		for (i = 0; i < 30; i++) {
			kprintf(" $");
			printbase10(i+1);
			kprintf(": ");
			printhex(tf->tf_regs.reg_r[i]);
		}
		kprintf(" $ra: ");
		printhex(tf->tf_ra);
		return 0;
	}
	if(buf[0] == 'b'){
		if(buf[1] != ' '){
			kprintf("command error.\n");
			return 0;
		}
		int valid = 1;
		int i = 0;
		for(i = 0; i < 8; i++){
			if((buf[i + 2] < 48 || buf[i + 2] > 57) && (buf[i + 2] < 97 || buf[i + 2] > 102)){
				valid = 0;
			}
		}
		if(valid == 0){
			kprintf("command error.\n");
			return 0;
		}
		unsigned int ad = 0;
    	for(i = 0; i < 8; i++){
        	ad = ad * 16 + conv(buf[i + 2]);
    	}
		writewatchlo(ad);
		return 0;
	}
	if(buf[0] == 't'){
		if(buf[1] != ' ' || buf[4] != ' '){
			kprintf("command error.\n");
			return 0;
		}
		int valid = 1;
		int i = 0;
		for(i = 2; i < 4; i++){
			if((buf[i] < 48 || buf[i] > 57) && (buf[i] < 97 || buf[i] > 102)){
				valid = 0;
			}
		}
		for(i = 5; i < 13; i++){
			if((buf[i] < 48 || buf[i] > 57) && (buf[i] < 97 || buf[i] > 102)){
				valid = 0;
			}
		}
		if(valid == 0){
			kprintf("command error.\n");
			return 0;
		}
		unsigned int rs = 0;
    	rs = conv(buf[2]) * 16 + conv(buf[3]);
		if(rs == 0 || rs >= 32){
			kprintf("command error.\n");
			return 0;
		}
		unsigned int v = 0;
    	for(i = 0; i < 8; i++){
        	v = v * 16 + conv(buf[i + 5]);
    	}
		if(rs == 31){
			tf -> tf_ra = v;
		}else{
			tf -> tf_regs.reg_r[rs - 1] = v;
		}
		return 0;
	}
	if(buf[0] == 's'){
		uint32_t currentPC = tf -> tf_epc;
		uint32_t currentInstruction = *((uint32_t*)currentPC);
		uint32_t instructionType = currentInstruction >> 26;
		uint32_t breakPoint1 = 0;
		uint32_t breakPoint2 = 0;
		uint32_t rtv = 0;
		uint32_t offset = 0;
		int32_t off = 0;
		uint32_t destination = 0;
		switch(instructionType){
			case 0:
				if(currentInstruction & 0x3f == 8 || currentInstruction & 0x3f == 9){
					breakPoint1 = currentPC + 8;
					destination = (currentInstruction >> 21) & 0x1f;
					if(destination == 31){
						breakPoint2 = tf -> tf_ra;
					}else if(destination == 0){
						breakPoint2 = 0;
					}else{
						breakPoint2 = tf -> tf_regs.reg_r[destination - 1];
					}
				}else{
					breakPoint1 = currentPC + 4;
				}
				break;
			case 1:
				rtv = (currentInstruction >> 16) & 0x1f;
				if(rtv == 0 || rtv == 1){
					offset = currentInstruction & 0xffff;
					off = ((int32_t)(offset << 16)) >> 14;
					breakPoint2 = currentPC + 4 + off;
					breakPoint1 = currentPC + 8;
				}else{
					breakPoint1 = currentPC + 4;
				}
				break;
			case 2:
			case 3:
				kprintf("currentInstruction: %08x\n", currentInstruction);
				breakPoint1 = currentPC + 8;
				breakPoint2 = (currentPC & 0xf0000000) + (currentInstruction & 0x03ffffff) * 4;
				break;
			case 4:
			case 5:
			case 6:
			case 7:
				offset = currentInstruction & 0xffff;
				off = ((int32_t)(offset << 16)) >> 14;
				breakPoint2 = currentPC + 4 + off;
				breakPoint1 = currentPC + 8;
				break;
			default:
				breakPoint1 = currentPC + 4;
				break; 
		}
		kprintf("breakpoint: %08x %08x\n", breakPoint1, breakPoint2);
		writewatchlo(breakPoint1);
		writewatchhi(breakPoint2);
		return -1;
	}
	kprintf("command error.\n");
	return 0;
}

static void debug_handler(struct trapframe* tf){
	intr_disable();
	kprintf("\nbreak point at 0x%08x.\n", tf->tf_epc);
	writewatchlo(0);
	writewatchhi(0);
	kprintf("[r]register, [c]continue, [b]breakpoint, [t]change register, [s]step\n");
	char *buf;
	while (1) {
		if ((buf = readline("\ngdb$")) != NULL) {
			if (gdbcmd(buf, tf) < 0) {
				break;
			}
		}
	}
	intr_enable();
}

extern pde_t *current_pgdir;

static inline int get_error_code(int write, pte_t *pte)
{
	int r = 0;
	if(pte!=NULL && ptep_present(pte))
		r |= 0x01;
	if(write)
		r |= 0x02;
	return r;
}

static int
pgfault_handler(struct trapframe *tf, uint32_t addr, uint32_t error_code) {
#if 0
		extern struct mm_struct *check_mm_struct;
		if (check_mm_struct != NULL) {
				return do_pgfault(check_mm_struct, error_code, addr);
		}
		panic("unhandled page fault.\n");
#endif
	extern struct mm_struct *check_mm_struct;
	if(check_mm_struct !=NULL) { //used for test check_swap
		//print_pgfault(tf);
	}
	struct mm_struct *mm;
	if (check_mm_struct != NULL) {
		assert(current == idleproc);
		mm = check_mm_struct;
	}
	else {
		if (current == NULL) {
			print_trapframe(tf);
			//print_pgfault(tf);
			panic("unhandled page fault.\n");
		}
		mm = current->mm;
	}
	return do_pgfault(mm, error_code, addr);
}

/* use software emulated X86 pgfault */
static void handle_tlbmiss(struct trapframe* tf, int write)
{
#if 0
	if(!trap_in_kernel(tf)){
		print_trapframe(tf);
		while(1);
	}
#endif

	static int entercnt = 0;
	entercnt ++;
	//kprintf("## enter handle_tlbmiss %d times\n", entercnt);
	int in_kernel = trap_in_kernel(tf);
	assert(current_pgdir != NULL);
	//print_trapframe(tf);
	uint32_t badaddr = tf->tf_vaddr;
	int ret = 0;
	pte_t *pte = get_pte(current_pgdir, tf->tf_vaddr, 0);
	if(pte==NULL || ptep_invalid(pte)){   //PTE miss, pgfault
		//panic("unimpl");
		//TODO
		//tlb will not be refill in do_pgfault,
		//so a vmm pgfault will trigger 2 exception
		//permission check in tlb miss
		ret = pgfault_handler(tf, badaddr, get_error_code(write, pte));
	}else{ //tlb miss only, reload it
		/* refill two slot */
		/* check permission */
		if(in_kernel){
			tlb_refill(badaddr, pte); 
		//kprintf("## refill K\n");
			return;
		}else{
			if(!ptep_u_read(pte)){
				ret = -1;
				goto exit;
			}
			if(write && !ptep_u_write(pte)){
				ret = -2;
				goto exit;
			}
		//kprintf("## refill U %d %08x\n", write, badaddr);
			tlb_refill(badaddr, pte);
			return ;
		}
	}

exit:
	if(ret){
		print_trapframe(tf);
		if(in_kernel){
			panic("unhandled pgfault");
		}else{
			do_exit(-E_KILLED);
		}
	}
	return ;
}

static void
trap_dispatch(struct trapframe *tf) {
	int code = GET_CAUSE_EXCODE(tf->tf_cause);
	switch(code){
		case EX_IRQ:
			interrupt_handler(tf);
			break;
		case EX_TLBL:
			handle_tlbmiss(tf, 0);
			break;
		case EX_TLBS:
			handle_tlbmiss(tf, 1);
			break;
		case EX_RI:
			print_trapframe(tf);
			if(trap_in_kernel(tf)) {
				panic("hey man! Do NOT use that insn!");
			}
			do_exit(-E_KILLED);
			break;
		case EX_CPU:
			print_trapframe(tf);
			if(trap_in_kernel(tf)) {
				panic("CpU exception should not occur in kernel mode!");
			}
			do_exit(-E_KILLED);
			break;
		case EX_OVF:
			print_trapframe(tf);
			if(trap_in_kernel(tf)) {
				panic("Ov exception occur in kernel mode!");
			}
			do_exit(-E_KILLED);
			break;
		case EX_SYS:
			//print_trapframe(tf);
			tf->tf_epc += 4;
			syscall();
			break;
			/* alignment error or access kernel
			 * address space in user mode */
		case EX_ADEL:
		case EX_ADES:
			if(trap_in_kernel(tf)){
				print_trapframe(tf);
				panic("Alignment Error");
			}else{
				print_trapframe(tf);
				do_exit(-E_KILLED);
			}
			break;
		case EX_DBG:
			debug_handler(tf);
			break;
		default:
			print_trapframe(tf);
			panic("Unhandled Exception");
	}

}


/*
 * General trap (exception) handling function for mips.
 * This is called by the assembly-language exception handler once
 * the trapframe has been set up.
 */
	void
mips_trap(struct trapframe *tf)
{
	// dispatch based on what type of trap occurred
	// used for previous projects
	if (current == NULL) {
		trap_dispatch(tf);
	}
	else {
		// keep a trapframe chain in stack
		struct trapframe *otf = current->tf;
		current->tf = tf;

		bool in_kernel = trap_in_kernel(tf);

		trap_dispatch(tf);

		current->tf = otf;
		if (!in_kernel) {
			if (current->flags & PF_EXITING) {
				do_exit(-E_KILLED);
			}
			if (current->need_resched) {
				schedule();
			}
		}
	}
}

