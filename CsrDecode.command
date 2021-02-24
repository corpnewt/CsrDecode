#!/usr/bin/env python

import os, textwrap
from typing import List, Iterator, Tuple
from dataclasses import dataclass

try:
    # Python 3.7.2+
    from typing import OrderedDict
except ImportError:
    from typing import MutableMapping

    OrderedDict = MutableMapping

# Updated Bits for Big Sur
# https://opensource.apple.com/source/xnu/xnu-7195.50.7.100.1/bsd/sys/csr.h.auto.html

csr_list: List[str] = [
    'CSR_ALLOW_UNTRUSTED_KEXTS',  # 1 << 0
    'CSR_ALLOW_UNRESTRICTED_FS',  # 1 << 1
    'CSR_ALLOW_TASK_FOR_PID',  # ...
    'CSR_ALLOW_KERNEL_DEBUGGER',
    'CSR_ALLOW_APPLE_INTERNAL',
    'CSR_ALLOW_UNRESTRICTED_DTRACE',
    'CSR_ALLOW_UNRESTRICTED_NVRAM',
    'CSR_ALLOW_DEVICE_CONFIGURATION',
    'CSR_ALLOW_ANY_RECOVERY_OS',
    'CSR_ALLOW_UNAPPROVED_KEXTS',
    'CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE',
    'CSR_ALLOW_UNAUTHENTICATED_ROOT',
]


def clear_screen():
    os.system('clear_screen' if os.name == 'nt' else 'clear')


# zip list to dict containing shift values
def csr_list_with_shift_vals_iter() -> Iterator[Tuple[str, int]]:
    return zip(csr_list, range(32))


def reverse_hex(hex: str) -> str:
    return ''.join(textwrap.wrap(hex, 2)[::-1])


def hex_to_vals(hex: str) -> List[str]:
    # split to 2 bytesh chunks, reverse list, join, convert to 10 base
    dec: int = int(reverse_hex(hex), 16)

    # filter by bitmask
    return [x[0] for x in csr_list_with_shift_vals_iter() if dec & 1 << x[1]]


def main():
    clear_screen()
    print("# CsrDecode #")
    print("")
    print("1. Hex To Values")
    print("2. Values to Hex")
    print("")
    print("Q. Quit")
    print("")
    menu = input("Please select an option:  ").lower()
    if not len(menu):
        return
    if menu == "q":
        exit()
    elif menu == "1":
        h_to_v()
    elif menu == "2":
        v_to_h()
    return


def h_to_v():
    clear_screen()
    print("# CsrActiveConfig Hex To Values #")
    print("")
    while True:
        h = input("Please type a CsrActiveConfig value (m for main menu):  ")
        if not h:
            continue
        if h.lower() == "m":
            return
        elif h.lower() == "q":
            exit()
        has = hex_to_vals(h)
        if not len(has):
            print("\nNo values found.\n")
        else:
            print("\nActive values:\n\n{}\n".format("\n".join(has)))


def v_to_h():
    # Create a dict with all values unchecked
    @dataclass
    class Toggle:
        enabled: bool
        name: str
        value: int

    toggle_list: List[Toggle] = [Toggle(enabled=False, name=x[0], value=1 << x[1]) for x in
                                 csr_list_with_shift_vals_iter()]

    while True:
        clear_screen()

        print("# CsrActiveConfig Values To Hex #")
        print("")

        # Print them out
        for x, y in enumerate(toggle_list, 1):
            print("[{}] {}. {} - {}".format("#" if y.enabled else " ", x, y.name, '0x{:08X}'.format(y.value)))
        print("")

        # Add the values of the enabled together
        cur_val = '{:08X}'.format(sum(map(lambda x: x.value, filter(lambda x: x.enabled, toggle_list)), 0))

        print("Current:  0x{} [{}]".format(cur_val, reverse_hex(cur_val)))
        print("")
        print("A. Select All")
        print("N. Select None")
        print("M. Main Menu")
        print("Q. Quit")
        print("")
        print("Select options to toggle with comma-delimited lists (eg. 1,2,3,4,5)")
        print("")
        menu = input("Please make your selection:  ").lower()
        if not len(menu):
            continue
        if menu == "m":
            return
        elif menu == "q":
            exit()
        elif menu == "a":
            for x in toggle_list:
                x.enabled = True
            continue
        elif menu == "n":
            for x in toggle_list:
                x.enabled = False
            continue
        # Should be numbers
        try:
            nums = [int(x) for x in menu.replace(" ", "").split(",")]
            for x in nums:
                if x < 1 or x > len(toggle_list):
                    # Out of bounds - skip
                    continue
                toggle_list[x - 1].enabled ^= True
        except:
            continue


while True:
    main()
