from __future__ import print_function
import serial
import time
from struct import *

t=serial.Serial("com4",115200,stopbits=serial.STOPBITS_TWO, timeout = 2)
def writeRom(address, data):
	t.write(chr(2))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	t.write(chr(data>>24))
	t.write(chr((data>>16)%256))
	t.write(chr((data>>8)%256))
	t.write(chr(data%256))

def readRom(address):
	t.write(chr(1))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	data = (t.read(1))
	if(len(data) != 0):
		data = ord(data)
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
	else:
		data = "fail"
	return data
def writeFlash(address, data):
	address = address + 2
	t.write(chr(5))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	t.write(chr(data>>24))
	t.write(chr((data>>16)%256))
	t.write(chr((data>>8)%256))
	t.write(chr(data%256))
	result = t.read(1)
	if(result == chr(14)):
		result ="success"
	else:
		result = "fail"
	return result
def eraseFlash(address):
	t.write(chr(3))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	result = t.read(1)
	if(result == chr(14)):
		result ="success"
	else:
		result = "fail"
	return result
def readFlash(address):
	address = address + 2
	t.write(chr(4))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	data = (t.read(1))
	if(len(data) != 0):
		data = ord(data)
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
	else:
		data = "fail"
	return data
def writeSram(address, data):
	address = address
	t.write(chr(7))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	t.write(chr(data>>24))
	t.write(chr((data>>16)%256))
	t.write(chr((data>>8)%256))
	t.write(chr(data%256))
	result = t.read(1)
	if(result == chr(14)):
		result ="success"
	else:
		result = "fail"
	return result
def readSram(address):
	address = address
	t.write(chr(6))
	t.write(chr(address>>24))
	t.write(chr((address>>16)%256))
	t.write(chr((address>>8)%256))
	t.write(chr(address%256))
	data = (t.read(1))
	if(len(data) != 0):
		data = ord(data)
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
		data = (data<<8)+ ord(t.read(1))
	else:
		data = "fail"
	return data
def run():
	while(True):
		command = str(raw_input("$"))
		command = command.split(" ")
		if(command[0] == "writeRom"):
			address = int(command[1])
			data = int(command[2])
			writeRom(address,data)
		elif(command[0] == "readRom"):
			address = int(command[1])
			data = readRom(address)
			if(data != "fail"):
				print(hex(data))
			else:
				print(data)
		elif(command[0] == "writeFlash"):
			try:
				address = int(command[1])
			except:
				address =int(command[1],16)
			try:
				data = int(command[2])
			except:
				data =int(command[2],16)
			result = writeFlash(address,data)
			print(result)
		elif(command[0] == "eraseFlash"):
			try:
				address = int(command[1])
			except:
				address =int(command[1],16)
			result = eraseFlash(address)
			print(result)
		elif(command[0] == "readFlash"):
			try:
				address = int(command[1])
			except:
				address =int(command[1],16)
			data = readFlash(address)
			if(data != "fail"):
				print(hex(data))
			else:
				print(data)
		elif(command[0] == "writeSram"):
			try:
				address = int(command[1])
			except:
				address =int(command[1],16)
			try:
				data = int(command[2])
			except:
				data =int(command[2],16)
			result = writeSram(address,data)
			print(result)
		elif(command[0] == "readSram"):
			try:
				address = int(command[1])
			except:
				address =int(command[1],16)
			data = readSram(address)
			if(data != "fail"):
				print(hex(data))
			else:
				print(data)
		elif(command[0] == "quit"):
			break
		elif(command[0] == "writeOs"):
			writeOs()
		elif(command[0] == "readSramAndErase"):
			readSramAndErase(command[1])
		elif(command[0] == "selfCheck"):
			testSram(int(command[1], 16), int(command[2], 16))
		else:
			print("error")

def readSramAndErase(outfile):
	out = open(outfile,"w")
	for i in range(10000):
		data = ((readSram(i*4)))
                print("{0:08x}".format(data),end = "\n",file = out)
                #print(str(hex((data))),end = "\n",file = out)
def testSram(begin, end):
	address = begin
	data = 0xffefffff
	while address <= end:
		writeSram(address, data)
		if readSram(address) != data:
			print("error at ")
			print(str(hex(address)))
			break
		address += 4
	if address >= end:
		print("sram test successful form %p to %p".format(begin,end))
def writeOs():
	"""
	out = open("log2.txt","w")
	for i in range(10000):
		writeFlash(i*2,i*2)
		data = readFlash(i*2)
		print(str(i)+" "+str(data-i*2),file = out)
	"""
	f=open("ucore-kernel-initrd","rb")
	out=open("read","wb")
	start = 0
	try:
		while(True):
			chunk = unpack("H",f.read(2))
			if not chunk:
				break
			chunk = chunk[0]
			#chunk = ((chunk%256)<<8) + (chunk >>8)
			writeFlash(start, chunk)
			data = readFlash(start)
			
			count = 0
			while(data != chunk):
				if(count == 4 and ((data-chunk)==4096 or (data-chunk)==16)):
					break
				count = count+1
				writeFlash(start, chunk)
				data = readFlash(start)
				print("error "+str(hex(start))+" "+str(hex(data))+" "+str(hex(chunk)))
				#break
			print(chr(int(data)>>8), end='',file=out)
			print(chr(int(data)%256), end='',file=out)
	   		start +=2
	finally:
		f.close()
		out.close()
if(__name__ == "__main__"):
	run()
	


