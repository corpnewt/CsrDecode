#!/usr/bin/env python
import sys, os, re

csr_list = [
    "CSR_ALLOW_UNTRUSTED_KEXTS",
    "CSR_ALLOW_UNRESTRICTED_FS",
    "CSR_ALLOW_TASK_FOR_PID",
    "CSR_ALLOW_KERNEL_DEBUGGER",
    "CSR_ALLOW_APPLE_INTERNAL",
    # "CSR_ALLOW_DESTRUCTIVE_DTRACE (name deprecated)",
    "CSR_ALLOW_UNRESTRICTED_DTRACE",
    "CSR_ALLOW_UNRESTRICTED_NVRAM",
    "CSR_ALLOW_DEVICE_CONFIGURATION",
    "CSR_ALLOW_ANY_RECOVERY_OS",
    "CSR_ALLOW_UNAPPROVED_KEXTS",
    "CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE"
]
csr_dict = {}
val = 1
for key in csr_list:
    csr_dict[str(val)] = key
    val *= 2

def cls():
  	os.system('cls' if os.name=='nt' else 'clear')

def grab(prompt = ""):
    if sys.version_info >= (3, 0):
        return input(prompt)
    else:
        return str(raw_input(prompt))

def _check_hex(hex_string):
    # Remove 0x/0X
    hex_string = hex_string.replace("0x", "").replace("0X", "")
    hex_string = re.sub(r'[^0-9A-Fa-f]+', '', hex_string)
    return hex_string

def hex_to_dec(hex_string):
    hex_string = _check_hex(hex_string)
    if not len(hex_string):
        return None
    try:
        dec = int(hex_string, 16)
    except:
        return None
    return dec

def hex_to_vals(hex_string):
    # Convert the hex to decimal string - then start with a reversed list
    # and find out which values we have enabled
    dec = hex_to_dec(hex_string)
    if not dec:
        return []
    has = []
    for key in sorted(csr_dict, key=lambda x:int(x), reverse=True):
        if int(key) <= dec:
            has.append(csr_dict[str(key)])
            dec -= int(key)
    return has

def main():
    cls()
    print("# CsrDecode #")
    print("")
    print("1. Hex To Values")
    print("2. Values to Hex")
    print("")
    print("Q. Quit")
    print("")
    menu = grab("Please select an option:  ").lower()
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
    cls()
    print("# CsrActiveConfig Hex To Values #")
    print("")
    while True:
        h = grab("Please type a CsrActiveConfig value (m for main menu):  ")
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
    toggle_dict = []
    for x in sorted(csr_dict, key=lambda x:int(x)):
        toggle_dict.append({"value":int(x),"enabled":False,"name":csr_dict[x]})
    while True:
        cls()
        print("# CsrActiveConfig Values To Hex #")
        print("")
        # Print them out
        for x,y in enumerate(toggle_dict,1):
            print("[{}] {}. {} - {}".format("#" if y["enabled"] else " ", x, y["name"],hex(y["value"])))
        print("")
        # Add the values of the enabled together
        curr = 0
        for x in toggle_dict:
            if not x["enabled"]:
                continue
            curr += x["value"]
        print("Current:  {}".format(hex(curr)))
        print("")
        print("A. Select All")
        print("N. Select None")
        print("M. Main Menu")
        print("Q. Quit")
        print("")
        print("Select options to toggle with comma-delimited lists (eg. 1,2,3,4,5)")
        print("")
        menu = grab("Please make your selection:  ").lower()
        if not len(menu):
            continue
        if menu == "m":
            return
        elif menu == "q":
            exit()
        elif menu == "a":
            for x in toggle_dict:
                x["enabled"] = True
            continue
        elif menu == "n":
            for x in toggle_dict:
                x["enabled"] = False
            continue
        # Should be numbers
        try:
            nums = [int(x) for x in menu.replace(" ","").split(",")]
            for x in nums:
                if x < 1 or x > len(toggle_dict):
                    # Out of bounds - skip
                    continue
                toggle_dict[x-1]["enabled"] ^= True
        except:
            continue

while True:
    main()
