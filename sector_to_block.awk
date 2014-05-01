# Convert bad sector LBAs into file system block numbers
# for an LVM logical volume occupying a contiguous
# range on a single physical disk partition
BEGIN {
    # Size of sector on disk in bytes
	sector_size = 512
    # LBA where LVM partition begins (fdisk -lu)
	part_lba = 2457945
	# LBA of first LVM PE (pvs -o pe_start --units s)
	# relative to partition
	pe_start = 384
	# LBA of first LVM PE
    lvm_base = part_lba + pe_start
	# Size of LVM PE in bytes (sudo pvdisplay | grep 'PE Size')
    pe_size = 4*1024*1024
	# Size of LVM PE in sectors
    pe_size_sect = pe_size / sector_size
	# First PE number of relevant LVM logical volume (pvdisplay -m)
	data_first_pe = 5457
	# Offset (in sectors) from lvm_base to LV start
	data_first_part_sect = data_first_pe * pe_size_sect
	# Block size of file system under LV in bytes
	# (dumpe2fs -h /dev/vg1/data | grep 'Block size')
	fs_block_size = 4096
	# Block size of file system under LV in sectors
	fs_block_size_sect = fs_block_size / sector_size
}
 
{
    # Input LBA of bad sector to map
	lba=$1
	# Offset (in sectors) of bad sector from start of LVM
	offset_lvm_base = lba - lvm_base
	# Offset (in sectors) from LV base
	data_sect = offset_lvm_base - data_first_part_sect
	# FS block number containing bad sector
	fs_block = data_sect / fs_block_size_sect
	print lba, data_sect, fs_block
}