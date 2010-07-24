#!/bin/bash
export LANG=
fail=0

runtest_int() {
    local msg=$(echo "$2"|perl -0777 -pe 's/\n/ /g')
    /bin/echo -En "  $msg ... "
    echo "$3" | ../8cc - .tmpTEST$$.o
    gcc -o .tmpTEST$$ .tmpTEST$$.o
    local result="`./.tmpTEST$$`"
    if [ "$result" = "$1" ]; then
	echo $1
    else
	echo "NG ($result)"
	fail=$((fail+1))
    fi
}

runtest() {
    runtest_int "$1" "$2" "main() {$2}"
}

runtest1() {
    runtest_int "$1" "$2" "$2"
}

#
# Basic tests
#
/bin/echo -e '\nBasic tests...'
runtest '' '-1;'
runtest 'Hello, world!' 'printf("Hello, world!");'
runtest 'Hello, world!' 'printf("Hello, %s", "world!");'
runtest '3' 'int i=3; printf("%d", i);'
runtest '6' 'int i=3; int j=0; j=i+3; printf("%d", j);'
runtest '50' 'int i=atoi("50"); int j = i; printf("%d", j);'
runtest '15' 'int i=3; int j=i+5+7; printf("%d", j);'
runtest '-5' 'int i=3; int j=5-i-7; printf("%d", j);'
runtest '0' 'int i=3; int j=5-i-7; printf("%d", j+5);'
runtest '0' 'int i=3; int j=5-i-7; printf("%d", j+5);'
runtest '3.5' 'printf("%.1f", 3.0 + 0.5);'
runtest '2.5' 'printf("%.1f", 3.0 - 0.5);'
runtest '9.9' 'printf("%.1f", 1.1 * 9.0);'
runtest '3.0' 'printf("%.1f", 9.9 / 3.3);'

#
# Operator precedences
#
/bin/echo -e '\nOperator precedences...'
runtest '10' 'int i=3; int j=1+i*3; printf("%d", j);'
runtest '5' 'int i=9; int j=1+i/3+9/i; printf("%d", j);'

#
# Assignment
#
/bin/echo -e '\nAssignment...'
runtest '3' 'int i=3; int j=i; printf("%d", j);'
runtest '5' 'int i=3; i+=2; printf("%d", i);'
runtest '1' 'int i=3; i-=2; printf("%d", i);'
runtest '6' 'int i=3; i*=2; printf("%d", i);'
runtest '2' 'int i=6; i/=3; printf("%d", i);'

#
# Comma operator
#
/bin/echo -e '\nComma operator...'
runtest '321' 'int i=3; while (i) printf("%d", i), i=i-1;'

#
# Parenthesized operator
#
/bin/echo -e '\nParenthesized operator...'
runtest '25' 'int i=2; int j=(i+3)*5; printf("%d", j);'

#
# "if" statement
#
/bin/echo -e '\nIf statement...'
runtest 'true'  'int i=1; if (i) { printf("true"); } else { printf("false"); }'
runtest 'false' 'int i=0; if (i) { printf("true"); } else { printf("false"); }'
runtest 'true'  'int i=1; if (i)   printf("true");   else   printf("false");'

#
# "while" statement
#
/bin/echo -e '\nWhile statement...'
runtest '54321a' 'int i=5; while (i) { printf("%d", i); i=i-1; } printf("a");'
runtest '54321a' 'int i=5; while (i)   printf("%d", i), i=i-1;   printf("a");'

#
# "for" statement
#
/bin/echo -e '\nFor statement...'
runtest '321' 'int i=0; for (i=3;i;i=i-1) { printf("%d", i); }'
runtest '321' 'int i=0; for (i=3;i;i=i-1)   printf("%d", i);'
runtest '321' 'for (int i=3;i;i=i-1) printf("%d", i);'

#
# "do" statement
#
/bin/echo -e '\nDo statement...'
runtest '321' 'int i=3; do { printf("%d", i); i=i-1;} while (i);'
runtest '321' 'int i=3; do   printf("%d", i), i=i-1;  while (i);'

#
# "==" and "!=" operators
#
/bin/echo -e '\n== and != operators...'
runtest '1' 'int i=5; int j=5; int k=i==j; printf("%d", k);'
runtest '0' 'int i=3; int j=5; int k=i==j; printf("%d", k);'
runtest 'true'  'int i=5; int j=5; if (i==j) { printf("true"); } else { printf("false"); }'
runtest 'false' 'int i=3; int j=5; if (i==j) { printf("true"); } else { printf("false"); }'
# "!="
runtest '0' 'int i=5; int j=5; int k=i!=j; printf("%d", k);'
runtest '1' 'int i=3; int j=5; int k=i!=j; printf("%d", k);'
runtest 'false' 'int i=5; int j=5; if (i!=j) { printf("true"); } else { printf("false"); }'
runtest 'true'  'int i=3; int j=5; if (i!=j) { printf("true"); } else { printf("false"); }'
# Flonum
runtest '1' 'printf("%d", 1.2 == 1.2);'
runtest '0' 'printf("%d", 1.2 == 1.0);'
runtest '0' 'printf("%d", 1.2 != 1.2);'
runtest '1' 'printf("%d", 1.2 != 1.0);'

#
# "!" operator
#
/bin/echo -e '\n! operator...'
runtest '1' 'int i=0; printf("%d", !i);'
runtest '0' 'int i=1; printf("%d", !i);'
runtest '0' 'int i=0; printf("%d", !!i);'
runtest '1' 'int i=9; printf("%d", !!i);'

#
# "~" operator
#
/bin/echo -e '\n~ operator...'
runtest '-1 -2' 'printf("%d %d", ~0, ~1);'
runtest '-1 -2' 'int i=0; int j=1; printf("%d %d", ~i, ~j);'

#
# "&" operator
#
/bin/echo -e '\n& operator...'
runtest '20' 'printf("%d", 30&21);'
runtest '20' 'int i=30; i&=21; printf("%d", i);'

#
# "|" operator
#
/bin/echo -e '\n| operator...'
runtest '30' 'printf("%d", 20|26);'
runtest '30' 'int i=20; i|=26; printf("%d", i);'

#
# "^" operator
#
/bin/echo -e '\n^ operator...'
runtest '4' 'printf("%d", 7^3);'
runtest '7' 'int i=4; i^=3; printf("%d", i);'

#
# Shift operators
#
/bin/echo -e '\nShift operators...'
runtest '1' 'printf("%d", 1<<0);'
runtest '4' 'printf("%d", 1<<2);'
runtest '1' 'printf("%d", 1>>0);'
runtest '1' 'printf("%d", 4>>2);'
runtest '16' 'int i=4; i<<=2; printf("%d", i);'
runtest '2' 'int i=8; i>>=2; printf("%d", i);'

#
# comparison operators
#
/bin/echo -e '\nComparison operators...'
runtest '1' 'int i=3; int j=5; printf("%d", i<j);'
runtest '0' 'int i=3; int j=5; printf("%d", i>j);'
runtest '0' 'int i=3; int j=3; printf("%d", i<j);'
runtest '0' 'int i=3; int j=3; printf("%d", i>j);'
runtest '1' 'int i=3; int j=5; printf("%d", i<=j);'
runtest '0' 'int i=3; int j=5; printf("%d", i>=j);'
runtest '1' 'int i=3; int j=3; printf("%d", i<=j);'
runtest '1' 'int i=3; int j=3; printf("%d", i>=j);'
runtest '1' 'printf("%d", 0<=1);'
runtest '0' 'printf("%d", 1<=0);'
runtest '1' 'printf("%d", 1>=0);'
runtest '0' 'printf("%d", 0>=1);'
runtest '0' 'printf("%d", 0<=-1);'
runtest '1' 'printf("%d", -1<=0);'
runtest '0' 'printf("%d", -1>=0);'
runtest '1' 'printf("%d", 0>=-1);'
# Floating point numbers
runtest '1' 'float i=3.0; float j=5.0; printf("%d", i<j);'
runtest '0' 'float i=3.0; float j=5.0; printf("%d", i>j);'
runtest '0' 'float i=3.0; float j=3.0; printf("%d", i<j);'
runtest '0' 'float i=3.0; float j=3.0; printf("%d", i>j);'
runtest '1' 'float i=3.0; float j=5.0; printf("%d", i<=j);'
runtest '0' 'float i=3.0; float j=5.0; printf("%d", i>=j);'
runtest '1' 'float i=3.0; float j=3.0; printf("%d", i<=j);'
runtest '1' 'float i=3.0; float j=3.0; printf("%d", i>=j);'
runtest '1' 'printf("%d", 0.0<=1.0);'
runtest '0' 'printf("%d", 1.0<=0.0);'
runtest '1' 'printf("%d", 1.0>=0.0);'
runtest '0' 'printf("%d", 0.0>=1.0);'
runtest '0' 'printf("%d", 0.0<=-1.0);'
runtest '1' 'printf("%d", -1.0<=0.0);'
runtest '0' 'printf("%d", -1.0>=0.0);'
runtest '1' 'printf("%d", 0.0>=-1.0);'

#
# "?:" operator
#
/bin/echo -e '\n?: operator...'
runtest '17' 'int i=1; printf("%d", i?17:42);'
runtest '42' 'int i=0; printf("%d", i?17:42);'
runtest '2' 'int i=1; int j=i?i+1:i-1; printf("%d", j);'
runtest '0' 'int i=1; int j=i-1?i+1:i-1; printf("%d", j);'
runtest '-1' 'int i=0; int j=i?i+1:i-1; printf("%d", j);'

#
# && operator
#
/bin/echo -e '\n&& operator...'
runtest 'ab' '1 && printf("a"); printf("b");'
runtest 'b' '0 && printf("a"); printf("b");'
runtest '3' 'int i = 1 && 3; printf("%d", i);'
runtest '0' 'int i = 5 && 3 && 0; printf("%d", i);'
runtest '0' 'int i = 0 && 0; printf("%d", i);'

#
# || operator
#
/bin/echo -e '\n|| operator...'
runtest 'b' '1 || printf("a"); printf("b");'
runtest 'ab' '0 || printf("a"); printf("b");'
runtest '1' 'int i = 1 || 3; printf("%d", i);'
runtest '3' 'int i = 0 || 3 || 5; printf("%d", i);'
runtest '0' 'int i = 0 || 0; printf("%d", i);'

#
# "++" and "--" operators
#
/bin/echo -e '\nIncrement and decrement operators...'
runtest '12' 'int i=1; printf("%d", i++);printf("%d", i);'
runtest '22' 'int i=1; printf("%d", ++i);printf("%d", i);'
runtest '54' 'int i=5; printf("%d", i--);printf("%d", i);'
runtest '44' 'int i=5; printf("%d", --i);printf("%d", i);'

#
# "break" and "continue"
#
/bin/echo -e '\nBreak and continue...'
runtest 'bar'  'int i=1; while (1) { if (i) { break; } printf("foo"); } printf("bar");'
runtest 'aac'  'int i=2; while (i) { if (i) { printf("a"); i=i-1; continue; } printf("b"); } printf("c");'
runtest '32a'  'for (int i=3;i;i=i-1) { printf("%d", i); if (i==2) { break; } } printf("a");'
runtest '321a' 'for (int i=3;i;i) { if (i) { printf("%d", i); i=i-1; continue; } } printf("a");'

#
# "goto" statement
#
/bin/echo -e '\nGoto statement...'
runtest 'acbd' 'A: printf("a"); goto C; B: printf("b"); goto D; C: printf("c"); goto B; D: printf("d");'

#
# "return" statement
#
/bin/echo -e '\nReturn statement...'
runtest 'a' 'printf("a"); return 1;'

#
# Function call
#
/bin/echo -e '\nFunction call...'
runtest1 'foo' 'main() { bar(); } bar() { printf("foo"); }'
runtest1 'foo' 'bar() { printf("foo"); } main() { bar(); }'
runtest1 '17' 'main() { printf("%d", bar()); } bar() { return 17; }'
# functions taking parameters
runtest1 '1 2' 'main() { bar(1, 2); } bar(int i, int j) { printf("%d %d", i, j); }'
runtest1 '17 42' 'main() { int p[3]; p[0]=17; p[1]=42; bar(p); } bar(int *p) { printf("%d %d", p[0], p[1]); }'

#
# Pointer operations
#
/bin/echo -e '\nPointer operations...'
runtest '17' 'long i=17; long *j=&i; printf("%d", *j);'
runtest '17' 'long i=17; long *j=&i; long **k=&j; printf("%d", **k);'
runtest '42' 'long i=17; long *j=&i; *j=42; printf("%d", *j);'
runtest '42' 'long i=17; long *j=&i; long **k=&j; **k=42; printf("%d", **k);'

#
# Array
#
/bin/echo -e '\nArray...'
runtest '17' 'int i[20]; printf("17");'
runtest '17 42' 'int i[20]; i[0]=17; i[19]=42; printf("%d %d", i[0], i[19]);'
runtest '17 42' 'int i[20]; int *p=i; p[0]=17; p[1]=42; printf("%d %d", *p, p[1]);'
runtest '5' 'int i[20]; int *p=i; int *q=p+5; printf("%d", q-p);'
runtest '123'       'int a[3][3]; a[0][1]=1; a[2][0]=2; a[2][2]=3; printf("%d%d%d", a[0][1], a[2][0], a[2][2]);'
runtest '012345678' 'int a[3][3]; for (int i=0;i<3;i++) for (int j=0;j<3;j++) a[i][j]=i*3+j; for (int i=0;i<9;i++) printf("%d",*(*a+i));'
runtest "bx" 'printf(0 ? "a" : "b"); printf(1 ? "x" : "y");'

#
# Aray and pointer arithmetic
#
/bin/echo -e '\nPointer arithmetic...'
runtest '17 42' 'int i[20]; i[0]=17; i[1]=42; int *j=i; printf("%d ", *j); j++; printf("%d", *j);'

#
# Array and function parameter
#
/bin/echo -e '\nArray and function parameter...'
runtest1 '012345678' 'main() { int a[9]; for (int i=0;i<9;i++) a[i]=i; f(a); } f(int a[][3]) { for (int i=0;i<3;i++) for (int j=0;j<3;j++) printf("%d", a[i][j]); }'
runtest1 '012345678' 'main() { int a[9]; for (int i=0;i<9;i++) a[i]=i; f(a); } f(int *a[3])  { for (int i=0;i<3;i++) for (int j=0;j<3;j++) printf("%d", a[i][j]); }'

#
# Char type
#
/bin/echo -e '\nChar type...'
runtest '3 257' 'char c=3; int i=c+254; printf("%d %d", c, i);'
runtest '2' 'char c=255+3; printf("%d", c);'
runtest '-1' 'char c=255; printf("%d", c);'
runtest '255' 'unsigned char c=255; printf("%d", c);'

#
# Literal string
#
/bin/echo -e '\nChar type...'
runtest 'Hello' 'char *p="Hello"; printf("%s", p);'
runtest 'Hello world' 'char *p="Hello " "world"; printf("%s", p);'

#
# Type conversion between floating point and integer
#
/bin/echo -e '\nFlonum type conversion...'
runtest '3.0' 'float f=3; printf("%.1f", f);'
runtest '3' 'int i=3.0; printf("%d", i);'

rm -f .tmpTEST$$ .tmpTEST$$.o
echo
if [ $fail -gt 0 ]; then
    echo "Test failure(s): $fail";
    exit 1
else
    echo OK
    exit 0
fi
