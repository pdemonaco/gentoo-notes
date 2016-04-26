Prolific USB Serial Adapter
===========================

This is what's needed to get those usb serial adapters installed

Add the following module to your kernel
```kernel
CONFIG_USB_SERIAL_PL2303
```

Once the module is present & usable you should see something like this in dmesg:
```
[   32.796961] usb 1-2: new full-speed USB device number 5 using xhci_hcd
[   32.961412] usb 1-2: New USB device found, idVendor=067b, idProduct=2303
[   32.961415] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[   32.961418] usb 1-2: Product: USB-Serial Controller D
[   32.961420] usb 1-2: Manufacturer: Prolific Technology Inc. 
[   33.017365] usbcore: registered new interface driver usbserial
[   33.017378] usbcore: registered new interface driver usbserial_generic
[   33.017387] usbserial: USB Serial support registered for generic
[   33.018073] usbcore: registered new interface driver pl2303
[   33.018088] usbserial: USB Serial support registered for pl2303
[   33.018109] pl2303 1-2:1.0: pl2303 converter detected
[   33.018714] usb 1-2: pl2303 converter now attached to ttyUSB0
```

In this example the device is connected via /dev/ttyUSB0
Connecting to the device - needed to be done as root
```
screen /dev/ttyUSB0 <baud>
```
