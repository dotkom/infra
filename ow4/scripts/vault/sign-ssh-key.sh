vault write -field=signed_key ssh-client-signer/sign/default public_key=@$HOME/.ssh/id_rsa.pub > $HOME/.ssh/id_rsa-cert.pub
