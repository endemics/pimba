context 'ssh' do
  describe package('openssh-server') do
    it { should be_installed }
  end

  describe service('ssh') do
    it { should_not be_enabled }
  end
end
