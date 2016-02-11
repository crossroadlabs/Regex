#ifndef __ICU_USER_CONFIG_H__
#define __ICU_USER_CONFIG_H__

#ifdef U_DEBUG
    /* Use the predefined value. */
#elif defined(DEBUG)
#   define U_DEBUG 1
# else
#   define U_DEBUG 0
#endif

//#define U_DISABLE_RENAMING 1
#define U_SHOW_CPLUSPLUS_API 0
#define UCONFIG_NO_REGULAR_EXPRESSIONS 0
#define U_HIDE_DRAFT_API 1
#define U_DEFAULT_SHOW_DRAFT 0
#define U_USING_ICU_NAMESPACE 0

#endif
