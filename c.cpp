// c.cpp - Generic C++ driver program to call assembly examples
//
// See listing1-4.cpp.

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

extern "C" {
void asmMain(void);
char *getTitle(void);
ssize_t readline(char *dest, int maxlen);
}

ssize_t readline(char *dest, int maxlen)
{
	char *result = fgets(dest, maxlen, stdin);
	if (result == NULL) {
		return -1;
	}

	// Remove the newline character, if one was read.
	ssize_t len = (ssize_t)strlen(result);
	if (len > 0 && dest[len - 1] == '\n') {
		dest[--len] = '\0';
	}
	return len;
}

int main(void)
{
	char *title = getTitle();
	printf("Calling %s:\n", title);
	asmMain();
	printf("%s terminated.\n", title);
	return 0;
}
