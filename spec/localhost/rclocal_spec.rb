context 'rc.local' do
  describe file('/etc/rc.local') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should_not contain 'By default this script does nothing.' }
    it { should contain '/opt/musicbox/startup.sh' }
  end
end
