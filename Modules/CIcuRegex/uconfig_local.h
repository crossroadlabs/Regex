//===--- uconfig_local.h ---------------------------------------------------===//
//Copyright (c) 2016 Daniel Leping (dileping)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//===----------------------------------------------------------------------===//

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
