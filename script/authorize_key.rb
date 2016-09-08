# modified from the script described here:
# http://hakunin.com/six-ansible-practices

def authorize_key(config, user, *key_paths)
  [*key_paths, nil].each do |key_path|
    if key_path.nil?
      fail "Public key not found at following paths: #{key_paths.join(', ')}"
    end

    full_key_path = File.expand_path(key_path)

    if File.exists?(full_key_path)
      config.vm.provision 'file',
        run: 'once',
        source: full_key_path,
        destination: '/home/vagrant/.ssh/authorized_key.pub'

      config.vm.provision 'shell',
        privileged: true,
        run: 'once',
        inline:
          "echo \"Creating /home/#{user}/.ssh/authorized_keys with #{key_path}\" && " +
          "rm -f /home/#{user}/.ssh/authorized_keys && " +
          "mkdir -p /home/#{user}/.ssh && " +
          "touch /home/#{user}/.ssh/authorized_keys && " +
          "mv /home/vagrant/.ssh/authorized_key.pub /home/#{user}/.ssh/authorized_keys && " +
          "chown -R #{user}:#{user} /home/#{user}/.ssh && " +
          "chmod 700 /home/#{user}/.ssh && " +
          "chmod 600 /home/#{user}/.ssh/* && " +
          "rm -f /home/vagrant/.ssh/authorized_key.pub && " +
          'echo "Done!"'
      break
    end
  end
end
