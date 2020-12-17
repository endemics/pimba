context 'pimusicbox configuration' do
  describe file('/boot/config/settings.ini') do
    it { should be_file }
  end
end

context 'pimusicbox dependencies' do

  describe file('/sbin/wpa_cli') do
    it { should be_file }
    it { should be_executable }
  end

  describe file('/etc/wpa_supplicant/') do
    it { should be_directory }
  end

end

context 'pimusicbox directory' do

  describe file('/opt/musicbox') do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/opt/musicbox/startup.sh') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/opt/musicbox/bin/network.sh') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/opt/musicbox/bin/system.sh') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/opt/musicbox/bin/setsound.sh') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

end
