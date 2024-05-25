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
	-Wl,-Map=out.map \
	-Wl,-preset_vec=0000h \
	-Wl,-pisr_vec=0004h \
	-Wl,-ppage0=0005h \
	-Wl,-ppage1=0800h \
	-Wl,-ppage2=1000h \
	-Wl,-ppage3=1800h

OBJS = draw.o game_logic.o inputs.o music.o utils.o video.o main.o
INC = draw.inc game_logic.inc music.inc video.inc bits.inc ram.inc
EXEC = ddr.hex

all: $(OBJS) $(INC)
	$(CC) $(OBJS) -o $(EXEC) $(CFLAGS)

%.o: %.s
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -rf ./*.o ./*.i ./*.d ./*.lst ./*.rlf ./*.hex ./*.hxl ./*.elf ./*.cmf ./*.sym ./*.map
