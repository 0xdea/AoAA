// listing1-4.cpp - Generic C++ driver program to call assembly examples
//
// ```
// $ g++ listing1-4.cpp <listingC-N>.S -o listing1-4
// $ objdump --disassemble listing1-4
// ...
// $ sudo dtruss ./listing1-4
// ...
// ```

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
