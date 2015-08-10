require 'spec_helper'

describe 'logicmonitor' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "logicmonitor class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('logicmonitor::params') }
        it { should contain_class('logicmonitor::install').that_comes_before('logicmonitor::config') }
        it { should contain_class('logicmonitor::config') }
        it { should contain_class('logicmonitor::service').that_subscribes_to('logicmonitor::config') }

        it { should contain_service('logicmonitor') }
        it { should contain_package('logicmonitor').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'logicmonitor class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('logicmonitor') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
