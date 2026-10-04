### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Crest-Kernel by imCrest
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=larry
device.name2=OP5958L1
device.name3=CPH2467
device.name4=CPH2465
device.name5=CPH2469
device.name6=sm6375
device.name7=NordCE3Lite
device.name8=OnePlusNordCE3Lite
device.name9=holi
device.name10=blair
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
# boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# custom banner
ui_print "----------------------------------";
ui_print "          Crest-Kernel            ";
ui_print "  OnePlus Nord CE 3 Lite (larry)  ";
ui_print "    KernelSU-Next | Android 17    ";
ui_print "       ADB Sideload / AOSP        ";
ui_print "----------------------------------";

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install
