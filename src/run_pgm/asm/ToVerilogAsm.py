from intelhex import IntelHex
ih = IntelHex()
ih.loadhex('testpgm.hex')
pydict = ih.todict()

counter = 0
with open('testpgm.txt', 'w') as f:
	with open('testpgm.bin', 'bw') as f2:
		for i in range(0, 4194304):
			if(i in pydict.keys()):
				f.write(format(pydict[i], 'x'))
				f.write(' ')
				f2.write(bytes([pydict[i]]))
			else:
				f.write('00 ')
				f2.write(b'\xFF')
			if(((i + 1) & 15) == 0):
				f.write('\n')
