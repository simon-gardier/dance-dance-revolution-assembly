CC = "/opt/microchip/xc8/v2.46/pic-as/bin/pic-as"

CFLAGS = -mcpu=PIC16F1789 \
	-D__DEBUG=1 \
	-mdfp="/opt/microchip/mplabx/v6.20/packs/Microchip/PIC12-16F1xxx_DFP/1.7.242/xc8" \
	-msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull \
	-fmax-errors=20 \
	-mwarn=0 \
	-xassembler-with-cpp \
	-mcallgraph=std \
	-mno-download-hex \
	-Wa,-a \
	-Wl,-Map=out.map \
	-Wl,-preset_vec=0000h \
	-Wl,-pisr_vec=0004h \
	-Wl,-ppage0=0005h \
	-Wl,-ppage1=0800h \
	-Wl,-ppage2=1000h \
	-Wl,-ppage3=1800h \
	-Wl,-ppage4=2000h

OBJS = inputs.o music.o draw.o game_logic.o main.o
EXEC = program.hex

all: $(OBJS)
	$(CC) $(OBJS) -o $(EXEC) $(CFLAGS)

%.o: %.s
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -rf ./*.o ./*.i ./*.d ./*.lst ./*.rlf ./*.hex ./*.hxl ./*.elf ./*.cmf ./*.sym ./*.map
