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

end
