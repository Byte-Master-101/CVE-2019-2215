echo Note: running the exploit while gdb is connected makes it very unreliable, so only connect gdb when needed\n
target remote :1234

macro define offsetof(_type, _memb) ((long)(&((_type *)0)->_memb))
macro define task_is(_taskname) $_streq(((struct task_struct*)(*(long*)(__per_cpu_offset[0]+(long)&current_task)))->comm, _taskname) 

define print_binder
    set pagination off
    x/51gx $bthread
    set pagination on
end

set $targetproc = "cve-2019-2215-e"
c

b binder_free_thread if task_is($targetproc)
commands
    set $bthread = thread
    print_binder
    dis $bpnum1
    en $bpnum2
    c
end
dis $bpnum
set $bpnum1 = $bpnum

b wait.c:50 if task_is($targetproc) && wq_head == &$bthread->wait
commands
    print_binder
    dis $bpnum2
    en $bpnum3
    c
end
dis $bpnum
set $bpnum2 = $bpnum

b wait.c:52 if task_is($targetproc) && wq_head == &$bthread->wait
commands
    print_binder
    dis $bpnum3
    en $bpnum1
    c
end
dis $bpnum
set $bpnum3 = $bpnum

en $bpnum1

c
