#!/bin/bash

# Inception Server Setup Script
# Sets up Debian server with Docker and required packages for Inception project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
        exit 1
    fi
}

# Get the actual user (not root if using sudo)
get_real_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

# Main setup
main() {
    print_info "Starting Inception server setup..."
    
    # Check if running as root
    check_root
    
    # Get the real username
    REAL_USER=$(get_real_user)
    REAL_HOME=$(eval echo ~$REAL_USER)
    DOMAIN_NAME="${REAL_USER}.42.fr"
    
    print_info "Setting up for user: $REAL_USER"
    print_info "Home directory: $REAL_HOME"
    print_info "Domain name: $DOMAIN_NAME"
    
    # Update system
    print_info "Updating system packages..."
    apt update
    apt upgrade -y
    
    # Install required packages
    print_info "Installing required packages..."
    apt install -y \
        docker.io \
        docker-compose \
        make \
        git \
        curl \
        wget \
        vim \
        net-tools \
        openssl
    
    # Add user to docker group
    print_info "Adding $REAL_USER to docker group..."
    usermod -aG docker $REAL_USER
    
    # Enable and start Docker
    print_info "Enabling Docker service..."
    systemctl enable docker
    systemctl start docker
    
    # Configure /etc/hosts
    print_info "Configuring /etc/hosts..."
    if grep -q "$DOMAIN_NAME" /etc/hosts; then
        print_warning "/etc/hosts already contains $DOMAIN_NAME"
    else
        echo "127.0.0.1    $DOMAIN_NAME" >> /etc/hosts
        print_info "Added $DOMAIN_NAME to /etc/hosts"
    fi
    
    # Create data directories
    print_info "Creating data directories..."
    mkdir -p "$REAL_HOME/data/mariadb"
    mkdir -p "$REAL_HOME/data/wordpress"
    chown -R $REAL_USER:$REAL_USER "$REAL_HOME/data"
    
    # Verify Docker installation
    print_info "Verifying Docker installation..."
    if docker --version > /dev/null 2>&1; then
        print_info "Docker version: $(docker --version)"
    else
        print_error "Docker installation failed!"
        exit 1
    fi
    
    if docker-compose --version > /dev/null 2>&1; then
        print_info "Docker Compose version: $(docker-compose --version)"
    else
        print_error "Docker Compose installation failed!"
        exit 1
    fi
    
    # Print summary
    echo ""
    print_info "==============================================="
    print_info "Setup complete!"
    print_info "==============================================="
    echo ""
    print_info "Configuration:"
    echo "  - User: $REAL_USER"
    echo "  - Domain: $DOMAIN_NAME"
    echo "  - Data directory: $REAL_HOME/data"
    echo "  - Docker group: added"
    echo ""
    print_warning "IMPORTANT: You need to log out and log back in"
    print_warning "for Docker group changes to take effect!"
    echo ""
    print_info "After logging back in, verify with:"
    echo "  docker ps"
    echo ""
    print_info "Then clone your Inception project and run:"
    echo "  make"
    echo ""
    print_info "Access your site at: https://$DOMAIN_NAME"
    echo ""
}

# Run main function
main
