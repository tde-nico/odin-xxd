package main

import "core:fmt"
import "core:os"
import "core:strings"

iteration: int = 0;

hexdump :: proc(data: []byte) {
	for i := 0; i < len(data); i += 16 {
		line_str := strings.Builder{};
		line_size := 16;
		if len(data) - i < line_size {
			line_size = len(data) - i;
		}
		line := data[i:i+line_size];

		fmt.sbprintf(&line_str, "%08x: ", i + iteration * 256);
		for j := 0; j < 16; j += 2 {
			if line_size != 16 && j+1 > line_size {
				strings.write_string(&line_str, "     ");
				continue;
			}
			if j+2 <= line_size {
				fmt.sbprintf(&line_str, "%02x%02x ", line[j], line[j+1]);
			} else {
				fmt.sbprintf(&line_str, "%02x   ", line[j]);
			}
		}

		strings.write_byte(&line_str, ' ');
		for char in line {
			if char >= 32 && char <= 126 {
				strings.write_byte(&line_str, char);
			} else {
				strings.write_byte(&line_str, '.');
			}
		}

		fmt.printf("%s\n", fmt.sbprint(&line_str));
	}
	iteration += 1;
}

main :: proc() {
	err: os.Error;
	input := os.stdin;
	defer {
		if input != os.stdin {
			os.close(input);
		}
	}

	if len(os.args) > 1 {
		input, err = os.open(os.args[1], os.O_RDONLY);
		if err != nil {
			fmt.printf("Error opening file %s: %v\n", os.args[1], err);
			return;
		}
	}

	for {
		bytes: [256]byte;
		n, err := os.read(input, bytes[:]);
		if err != nil {
			fmt.printf("Error reading: %v\n", err);
			return;
		}

		hexdump(bytes[:n]);
		
		if n != 256 {
			break;
		}
	}
}
