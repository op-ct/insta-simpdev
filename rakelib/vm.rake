namespace :vm do
  desc <<-DESC
    Provision builder VM, but don't build or download any ISOs.

    This is useful if you want to:
      * snapshot the VM as a runner to use for building
      * `vagrant ssh` into the VM before building
  DESC
  task :nobuild do
    sh 'SIMP_BUILDER__task_setup=no SIMP_BUILDER__task_clone=no SIMP_BUILDER__task_build=no vagrant up'
    sh 'vagrant snapshot save freshvm'
  end
end

