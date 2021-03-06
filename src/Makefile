# This file defines ARCH, INCLUDES, TARGETS and EXETARGETS
!INCLUDE Makefile.common

# Set the flags for coqc here
COQFLAGS=-dont-load-proofs
COQC=coqc $(COQFLAGS)
COQTOP=coqtop $(COQFLAGS)
HEXBIN=tools\hexbin

COQINCLUDES=-R . $(LIBNAME)

all: $(TARGETS) $(EXETARGETS) $(DLLTARGETS) dirlocals
allexes: $(EXETARGETS) $(DLLTARGETS)

show:
  @echo ARCH=$(ARCH)
  @echo INCLUDES=$(INCLUDES)
  @echo ALLINCLUDES=$(ALLINCLUDES)
  @echo TARGETS=$(TARGETS)
  @echo EXETARGETS=$(EXETARGETS)
  @echo DLLTARGETS=$(DLLTARGETS)
  @echo COQINCLUDES=$(COQINCLUDES)
  @echo COQPROGARGS=$(COQPROGARGS)

clean:
  @echo off
#  for %D IN ($(INCLUDES)) DO (del %%D\*.vo %%D\*.dep %%D\*.glob %%D\*.exe %%D\*.dll %%D\*.hex)
  del *.vo *.dep *.glob *.exe *.dll *.hex
  del x86\*.vo x86\*.dep x86\*.glob x86\*.exe x86\*.dll x86\*.hex
  del charge\*.vo charge\*.dep charge\*.glob charge\*.exe charge\*.dll charge\*.hex
  del x86\win\*.vo x86\win\*.dep x86\win\*.glob x86\win\*.exe x86\win\*.dll x86\win\*.hex
  del x86\lib\regexp\*.vo x86\lib\regexp\*.dep x86\lib\regexp\*.glob x86\lib\regexp\*.exe x86\lib\regexp\*.dll x86\lib\regexp\*.hex

# clear existing list first
.SUFFIXES:
.SUFFIXES: .dll .exe .vo .dep .v .hex

.v.vo:
	$(COQC) $(COQINCLUDES) $<

.v.hex:
        $(COQTOP) -quiet -batch $(COQINCLUDES) -l $< >$*.hex

# The syntax #@ refers to the full target name (.exe file), $< refers to the dependent (.hex file)
.hex.exe:
        $(HEXBIN) $< $@

.hex.dll:
        $(HEXBIN) $< $@

Makefile.deps: $(TARGETS:.vo=.dep) $(EXETARGETS:.exe=.dep) $(DLLTARGETS:.dll=.dep)
	@type $** > $@ 2>NUL
        @exedep $(EXETARGETS) >>$@ 2>NUL
        @exedep $(DLLTARGETS) >>$@ 2>NUL

.v.dep:
	coqdep $(COQINCLUDES) $< > $@

dirlocals: .dir-locals.el.in
	@powershell -Command "(Get-Content .dir-locals.el.in) | ForEach-Object { $$_ -replace \"@LIBNAME@\", \"$(LIBNAME)\" } | Set-Content .dir-locals.el"

!IF EXIST (Makefile.deps)
!INCLUDE Makefile.deps
!ENDIF
