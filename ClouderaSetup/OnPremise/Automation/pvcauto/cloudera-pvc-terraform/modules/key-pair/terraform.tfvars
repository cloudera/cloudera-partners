# Common: vars
aws_region = "ap-southeast-1"

# Tags to apply to the key pair (e.g., owner and environment)
keypair_tags = {
  owner       = "ksahu" # Set your owner tag
  environment = "development"   # Set your environment tag
}

# Keypair creation: vars
# Set the flag to decide whether to create a new key pair or use an existing one
create_keypair = true # Set to false if you want to use an existing key pair

# Name of the new key pair to be created (used if create_keypair is true)
keypair_name = "pvc-new-keypair" # Change this to the desired key pair name

# Name of the existing key pair (used if create_keypair is false)
existing_keypair_name = "kuldeep-pvc-session" # Set this to the name of an existing key pair if create_keypair is false
