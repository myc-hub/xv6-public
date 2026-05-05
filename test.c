#include "types.h"
#include "stat.h"
#include "user.h"

int
main(void)
{
  int pid;
  int pid_plus;
  
  pid = getpid();
  pid_plus = getpid_plus();
  
  printf(1, "[USER] Testing getpid_plus() system call:\n");
  printf(1, "[USER] getpid() = %d\n", pid);
  printf(1, "[USER] getpid_plus() = %d\n", pid_plus);
  printf(1, "[USER] Expected: %d\n", pid + 1);
  
  if (pid_plus == pid + 1)
    printf(1, "[USER] Test PASSED!\n");
  else
    printf(1, "[USER] Test FAILED!\n");
  
  exit();
}
