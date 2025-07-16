import sys
import serial

def main():
    port = sys.argv[1] if len(sys.argv) > 1 else ('COM3' if sys.platform.startswith("win") else '/dev/ttyUSB0')
    baud = int(sys.argv[2]) if len(sys.argv) > 2 else 115200

    print(f"Opening {port} @ {baud} baud …")
    try:
        with serial.Serial(port, baudrate=baud, timeout=1) as ser:
            print("Listening – press Ctrl-C to stop.\n")
            while True:
                byte = ser.read(1)          # blocking read (1 byte) with timeout
                if byte:                    # non-empty ⇒ something arrived
                    value   = byte[0]       # 0-to-255 int
                    nibble  = value & 0x0F  # keep bits 3..0
                    print(f"Raw: 0x{value:02X}   Low-nibble: {nibble:04b} (0x{nibble:X})")
    except serial.SerialException as e:
        sys.exit(f"Serial error: {e}")
    except KeyboardInterrupt:
        print("\nStopped.")

if __name__ == "__main__":
    main()