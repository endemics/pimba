context 'pimba' do

  describe file('/boot/pimba') do
    it { should be_directory }
  end

  describe file('/boot/pimba/docker-compose.yaml') do
    it { should be_file }
  end

  describe file('/etc/systemd/system/pimba.service') do
    it { should be_file }
  end

  describe service('pimba.service') do
    it { should be_enabled }
  end

end
