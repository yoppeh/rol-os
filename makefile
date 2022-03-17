as_cmd = ca65
as_arg = --cpu 65816
ln_cmd = ld65
ln_arg = -C rol-ld65.cfg
ar_cmd = ar65
ar_arg =

obj_list = rol.o bcd.o ds1501.o math.o mem.o sc28l92.o string.o time.o w65c22.o

rol.bin : $(obj_list) rol-ld65.cfg
	$(ln_cmd) $(ln_arg) -m rol.map $(obj_list) -o $@

rol.o : rol.s ascii.i ds1501.i flags.i math.i mem.i rol.i sc28l92.i string.i time.i w65c22.i
	$(as_cmd) $(as_arg) $< -o $@

bcd.o : bcd.s bcd.i rol.i
	$(as_cmd) $(as_arg) $< -o $@

ds1501.o : ds1501.s ds1501.i rol.i time.i
	$(as_cmd) $(as_arg) $< -o $@

math.o : math.s math.i
	$(as_cmd) $(as_arg) $< -o $@

mem.o : mem.s mem.i
	$(as_cmd) $(as_arg) $< -o $@

string.o : string.s string.i math.i rol.i
	$(as_cmd) $(as_arg) $< -o $@

sc28l92.o : sc28l92.s sc28l92.i flags.i rol.i
	$(as_cmd) $(as_arg) $< -o $@

time.o: time.s ascii.i bcd.i rol.i time.i
	$(as_cmd) $(as_arg) $< -o $@

w65c22.o : w65c22.s w65c22.i ds1501.i math.i rol.i 
	$(as_cmd) $(as_arg) $< -o $@


.PHONY : clean
clean :
	-rm *.bin
	-rm *.map
	-rm *.o
