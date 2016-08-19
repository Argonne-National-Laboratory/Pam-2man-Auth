#include <pwd.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <syslog.h>
#include <security/pam_modules.h>
#include <security/pam_misc.h>
#include <security/pam_appl.h>

PAM_EXTERN int pam_sm_authenticate( 
  pam_handle_t *pamh, int flags, int argc, const char **argv ) {
  
  openlog("pam_2man", LOG_PID, LOG_AUTHPRIV);
  pam_handle_t * pamh2 = NULL;
  const char* pUsername2 = NULL;

  struct pam_conv conv = { misc_conv, NULL };
  int get_user_status;
  int auth_status;
  const char* pUsername1;
  const char * second_auth = NULL;

  if (argc && (strcmp(argv[0],"group") == 0)) { 
    second_auth = "2man_group";
  }

  get_user_status = pam_get_user(pamh, &pUsername1, NULL);
  if (get_user_status != PAM_SUCCESS) {
    syslog(LOG_ERR, "cannot determine user name");
    closelog();
    return get_user_status;
  }
  printf("Successfully authorized %s as first of two required\n", pUsername1);
  syslog(LOG_NOTICE, "successfully authorized %s as first of two required", 
    pUsername1);

  pam_start(second_auth, pUsername2, &conv, &pamh2);

  pam_get_user(pamh2, &pUsername2, NULL);
  auth_status = pam_authenticate(pamh2, 0);

  if (auth_status != PAM_SUCCESS) {
    syslog(LOG_NOTICE, "could not authenticate %s", pUsername2);
    printf("Could not successfully authenticate the second user\n");
    printf("%s\n", pam_strerror(pamh2, auth_status));
    closelog();
    return auth_status;
  } else {
    syslog(LOG_NOTICE, "authorized %s as second of two required", 
      pUsername2);
    printf("Successfully authorized %s as second of two required\n", 
      pUsername2);
  }

  if ((strcmp(pUsername1, pUsername2) == 0)) {
    syslog(LOG_ERR, "%s tried to login with the same username twice", 
      pUsername1);
    printf("Authentication must happen with 2 different users\n");
    closelog();
    return PAM_AUTH_ERR;
  } else if ((strcmp(pUsername1, "root") == 0) || 
    (strcmp(pUsername2, "root") == 0)) {
    syslog(LOG_ERR, "user attempted 2man with root");
    printf("Please try again with standard (non-root) user accounts\n");
    closelog();
    return PAM_AUTH_ERR;
  } else {
    syslog(LOG_NOTICE, "successfully authenticated %s approved by %s", 
      pUsername1, pUsername2);
    closelog();
    return PAM_SUCCESS;
  } 
}

#define UNUSED __attribute__ ((unused))
PAM_EXTERN int
pam_sm_setcred(pam_handle_t *pamh UNUSED, int flags UNUSED,
               int argc UNUSED, const char **argv UNUSED)
{
        return PAM_IGNORE;
}
