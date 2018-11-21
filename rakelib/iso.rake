namespace :iso do
  desc <<-DESC.gsub(/^ {4}/,'')
    Copies `*.iso` and `*.json`  files back from VM

    Arguments:
      * `dest_dir` Directory to download `*.iso` and `*.json` files into
  DESC
  task :download, [:dest_dir, :extra_files] do |t, args|
    require 'tmpdir'
    args.with_defaults(dest_dir: '.', extra_files: '')

    extra = args.extra_files.split(':').map do |file|
      %["simp_builder:/vagrant/simp-core/#{file}"]
    end.join(' ')

    mkdir_p args.dest_dir unless File.exists?(args.dest_dir)
    sh "vagrant ssh-config > .ssh-config"
    sh "scp -F .ssh-config -p #{extra} \
      simp_builder:/vagrant/simp-core/build/distributions/*/*/*/SIMP_ISO/*.{iso,json} \
      #{args.dest_dir}/"
  end
end
