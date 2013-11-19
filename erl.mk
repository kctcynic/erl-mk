all: app
.PHONY: all

####

ALL_DEPS_DIRS = $(addprefix deps/,$(DEPS))

get-deps : deps/ $(ALL_DEPS_DIRS)
.PHONY: get-deps

deps/%/:
	git clone -n -- $(word 1,$(dep_$*)) $@
	cd $@ && git checkout -q $(word 2,$(dep_$*))

clean-deps:
	$(foreach dep,$(wildcard deps/*/),make -C $(dep) clean;)
.PHONY: clean-deps

deps/:
	mkdir deps/

#deps: get-deps
#	$(foreach dep,$(wildcard deps/*/),make -C $(dep) all;)

####

ebin/%.beam: src/%.erl
	erlc $(ERL_OPTS) -v -o ebin/ -pa ebin/ -I include/ $<

ebin/%.beam: src/%.xrl
	erlc -o ebin/ $<
	erlc -o ebin/ ebin/$*.erl

ebin/%.beam: src/%.yrl
	erlc -o ebin/ $<
	erlc -o ebin/ ebin/$*.erl

ebin/%.beam: src/%.S
	erlc $(ERL_OPTS) -v +from_asm -o ebin/ -pa ebin/ -I include/ $<

ebin/%.beam: src/%.core
	erlc $(ERL_OPTS) -v +from_core -o ebin/ -pa ebin/ -I include/ $<

ebin/%.app: src/%.app.src
	cp $< $@

app: ebin/ $(patsubst src/%.app.src,ebin/%.app, $(wildcard src/*.app.src))    \
           $(patsubst src/%.erl,    ebin/%.beam,$(wildcard src/*.erl    ))    \
           $(patsubst src/%.xrl,    ebin/%.beam,$(wildcard src/*.xrl    ))    \
           $(patsubst src/%.yrl,    ebin/%.beam,$(wildcard src/*.yrl    ))    \
           $(patsubst src/%.S,      ebin/%.beam,$(wildcard src/*.S      ))    \
           $(patsubst src/%.core,   ebin/%.beam,$(wildcard src/*.core   ))
#	echo $?
.PHONY: app

ebin/:
	mkdir ebin/

clean: clean-deps
	rm -rf ebin/
.PHONY: clean

distclean:
	rm -rf ebin/ deps/
.PHONY: distclean
