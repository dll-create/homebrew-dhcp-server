require "language/node"

class DhcpServer < Formula
  desc "Lightweight DHCP server with modern web UI for BMC provisioning"
  homepage "https://github.com/dll-create/dhcp-server"
  url "https://github.com/dll-create/dhcp-server/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "1c67a9e263d991e5b2309a5c6d2c7542a26e2a0026a4f258a0b8e7102f26e578"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)

    (bin/"dhcp-server").write <<~EOS
      #!/bin/bash
      echo ""
      echo "⚡ DHCP Server — http://localhost:3000"
      echo ""
      echo "⚠️  Safety: Only use on direct-connect interfaces (e.g. laptop → BMC)"
      echo ""

      if [ "$(id -u)" -ne 0 ]; then
        echo "ℹ️  Web UI only (no DHCP). Run 'sudo dhcp-server' for full DHCP."
        echo ""
      fi

      exec node "#{libexec}/lib/node_modules/dhcp-server/server.js" "$@"
    EOS
  end

  def caveats
    <<~EOS
      To start (web UI only):
        dhcp-server

      To start with DHCP (requires root):
        sudo dhcp-server

      Then open http://localhost:3000

      ⚠️  Never run on a network with an existing DHCP server.
    EOS
  end

  test do
    fork do
      exec bin/"dhcp-server"
    end
    sleep 2
    output = shell_output("curl -s http://localhost:3000/api/status")
    assert_match "running", output
  end
end
