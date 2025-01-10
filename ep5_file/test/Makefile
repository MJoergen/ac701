OBJS += drv_Io1035Utils.o
OBJS += drv_Io1035.o
OBJS += main.o

APP = /home/mike/bin/app

DEVICE = /sys/bus/pci/devices/0000\:02\:00.0/resource0

FILE = test.bit

$(APP): $(OBJS)
	gcc -o $(APP) $(OBJS) -lstdc++

%.o: %.cpp
	gcc -c -o $@ $<

clean:
	rm -rf *.o

test:
	sudo $(APP) $(DEVICE) $(FILE)

