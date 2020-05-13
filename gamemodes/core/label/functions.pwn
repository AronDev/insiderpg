convertLabelColor(color) {
    new labelHexColor = -1;
    switch(color) {
        case 0: labelHexColor = COLOR_RED;
        case 1: labelHexColor = COLOR_YELLOW;
        case 2: labelHexColor = COLOR_GREEN;
        case 3: labelHexColor = COLOR_SBLUE;
    }
    return labelHexColor;
}
