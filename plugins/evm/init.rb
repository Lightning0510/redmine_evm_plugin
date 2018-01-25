Redmine::Plugin.register :evm do
  name 'Evm plugin'
  author 'linhtq'
  description 'This is a plugin for EVM'
  version '0.0.1'

  project_module :evm do
    permission :view_evm, :evm => :index
  end

  menu :project_menu, :evm, { :controller => 'evm', :action => 'index' }, :caption => 'EVM', :before => :settings, :param => :project_id
end
