# Makefrag - makefile fragment for atc
#
# Copyright (c) 1997, 1998 Joseph Samuel Myers.
# Copyright (c) 2014 Fengyuan Chen.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

CLEANFILES := grammar.c grammar.h grammar.tab.* lex.c lex.yy.c *.o atc
CFLAGS := -I./include/ -DBSD -DYY_NO_UNPUT
LIBS := -ll -lm -lcurses -lbsd
LEX := flex
YACC := bison
SOURCES := main.c tunable.c update.c extern.c graphics.c input.c list.c log.c lex.c grammar.c

grammar.c:	grammar.y
	$(YACC) -d grammar.y
	mv grammar.tab.c $@
	mv grammar.tab.h grammar.h
	touch grammar.h

grammar.h:	grammar.c

lex.d:	grammar.h

lex.c:	lex.l
	$(LEX) lex.l
	mv lex.yy.c $@
atc: $(SOURCES)
	gcc $(CFLAGS) $(SOURCES) $(LIBS) -o atc
clean:
	rm -f $(CLEANFILES)
all: atc
	
