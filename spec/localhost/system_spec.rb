context 'system' do

  describe file('/etc/environment') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_readable.by('owner') }
    it { should be_readable.by('group') }
    it { should be_readable.by('others') }
    it { should contain 'TZ=:/etc/localtime' }
  end

  describe file('/etc/init.d/resize2fs_once') do
    it { should_not exist }
  end

  describe file('/etc/fstab') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    it { should contain 'LABEL=boot      /boot' }
    it { should contain 'LABEL=rootfs    /' }
  end

  describe file('/boot/cmdline.txt') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should contain 'root=/dev/mmcblk0p2' }
    it { should_not contain 'init=/usr/lib/raspi-config/init_resize.sh' }
  end

end
