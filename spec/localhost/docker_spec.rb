context 'docker' do
  describe package('docker-ce') do
    it { should be_installed }
  end

  describe package('docker-ce-cli') do
    it { should be_installed }
  end

  describe package('containerd.io') do
    it { should be_installed }
  end

  describe package('docker-compose') do
    it { should be_installed }
  end

end
