context 'activate ssh' do
  describe file('/boot/ssh') do
    it { should exist }
  end
end
