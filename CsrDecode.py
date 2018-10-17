import sys, os, re

csr_list = [
    "CSR_ALLOW_UNTRUSTED_KEXTS",
    "CSR_ALLOW_UNRESTRICTED_FS",
    "CSR_ALLOW_TASK_FOR_PID",
    "CSR_ALLOW_KERNEL_DEBUGGER",
    "CSR_ALLOW_APPLE_INTERNAL",
    "CSR_ALLOW_DESTRUCTIVE_DTRACE",
    "CSR_ALLOW_UNRESTRICTED_DTRACE (name deprecated)",
    "CSR_ALLOW_UNRESTRICTED_NVRAM",
    "CSR_ALLOW_DEVICE_CONFIGURATION",
    "CSR_ALLOW_ANY_RECOVERY_OS",
    "CSR_ALLOW_UNAPPROVED_KEXTS"
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
    h = grab("Please type a CsrActiveConfig value:  ")
    if not h:
        return
    has = hex_to_vals(h)
    if not len(has):
        print("\nNo values found.\n")
    else:
        print("\nActive values:\n\n{}\n".format("\n".join(has)))
while True:
    main()