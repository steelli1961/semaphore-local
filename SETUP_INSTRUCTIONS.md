# Semaphore Local Setup Instructions

This guide will help you set up Semaphore locally for managing Ansible playbooks in your local network.

## Prerequisites

- Docker & Docker Compose (recommended for quickest setup)
- OR: Go 1.21+, Node.js 18+, PostgreSQL/MySQL, and Git
- Linux machines in your network that you want to manage

## Quick Start with Docker Compose

### 1. Using the provided Docker Compose setup

```bash
cd semaphore-local
docker-compose up -d
```

The service will be available at `http://localhost:3000`

**Default credentials:**
- Username: `admin`
- Password: `changeme` (CHANGE THIS IN PRODUCTION)

### 2. First Time Setup

1. Open `http://localhost:3000` in your browser
2. Log in with admin credentials
3. Go to Settings → Users and create additional users if needed
4. Create SSH keys for authentication with your Linux machines

## Manual Installation (Without Docker)

### Option A: Database Setup

**PostgreSQL:**
```bash
# macOS with Homebrew
brew install postgresql
brew services start postgresql

# Create database
createdb semaphore
createuser semaphore_user
psql -d semaphore -c "ALTER ROLE semaphore_user WITH PASSWORD 'semaphore_password';"
```

**OR MySQL:**
```bash
# macOS with Homebrew
brew install mysql
brew services start mysql

# Create database
mysql -u root -p
CREATE DATABASE semaphore;
CREATE USER 'semaphore_user'@'localhost' IDENTIFIED BY 'semaphore_password';
GRANT ALL PRIVILEGES ON semaphore.* TO 'semaphore_user'@'localhost';
FLUSH PRIVILEGES;
```

### Option B: Build and Run

```bash
# Install dependencies
go mod download
npm install --prefix web

# Build
make build

# Create config
cp config.json.example config.json
# Edit config.json with your database details

# Run migrations
./semaphore migrate

# Start server
./semaphore server --port 3000
```

## Configuration

### Environment Variables

Create a `.env` file:

```bash
# Database Configuration
SEMAPHORE_DB_USER=semaphore_user
SEMAPHORE_DB_PASS=semaphore_password
SEMAPHORE_DB_HOST=localhost
SEMAPHORE_DB_PORT=5432
SEMAPHORE_DB_DIALECT=postgres  # or mysql

# Semaphore Settings
SEMAPHORE_ADMIN=admin
SEMAPHORE_ADMIN_PASSWORD=your_secure_password
SEMAPHORE_ADMIN_NAME="Administrator"
SEMAPHORE_ADMIN_EMAIL=admin@localhost

# Network Settings
SEMAPHORE_ADDRESS=0.0.0.0
SEMAPHORE_PORT=3000

# Optional: TLS/SSL
# SEMAPHORE_TLS=true
# SEMAPHORE_TLS_CERT=/path/to/cert.pem
# SEMAPHORE_TLS_KEY=/path/to/key.pem
```

## Setting Up Local Network Management

### 1. Generate SSH Keys

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/semaphore_key -N ""
```

### 2. Add SSH Public Key to Target Linux Machines

On each Linux machine you want to manage:

```bash
mkdir -p ~/.ssh
cat semaphore_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. In Semaphore UI

1. Go to **Settings** → **SSH Keys**
2. Click **New SSH Key**
3. Upload your private key (`semaphore_key`)
4. Name it (e.g., "Local Network Key")

### 4. Create an Inventory

1. Go to **Inventories**
2. Click **New Inventory**
3. Create hosts file or use provided samples (see `sample-configs/inventory.ini`)

### 5. Create a Project

1. Go to **Projects**
2. Click **New Project**
3. Point to the playbooks directory (local or Git repository)
4. Link it to your inventory

## Sample Playbooks

Pre-configured playbooks are in `sample-configs/playbooks/`:

- `update-servers.yml` - Update system packages
- `install-packages.yml` - Install specific packages
- `manage-users.yml` - Create/manage user accounts
- `configure-hostname.yml` - Set hostname and network
- `install-monitoring.yml` - Install monitoring agents

See the sample-configs directory for detailed examples.

## Troubleshooting

### Container won't start
```bash
docker-compose logs
docker-compose down -v  # Reset volumes
docker-compose up -d
```

### SSH connection issues
```bash
# Test connectivity from Semaphore container
docker-compose exec semaphore ssh -v user@target-machine
```

### Database issues
```bash
# Check database connection
docker-compose logs database
```

### Reset admin password
```bash
docker-compose exec semaphore semaphore user change-password --username admin
```

## Backup & Recovery

### Backup database and configurations

```bash
# Docker backup
docker-compose exec database pg_dump -U semaphore_user semaphore > backup.sql
docker-compose exec semaphore tar czf configs-backup.tar.gz /etc/semaphore

# Manual backup
pg_dump -U semaphore_user semaphore > backup.sql
```

### Restore

```bash
docker-compose exec -T database psql -U semaphore_user semaphore < backup.sql
```

## Next Steps

1. Review sample playbooks in `sample-configs/playbooks/`
2. Test with one target machine first
3. Create your custom playbooks
4. Set up scheduled tasks/webhooks for automation
5. Configure backup strategies

## Support

- Official docs: https://semaphore.rocks/
- GitHub: https://github.com/ansible-semaphore/semaphore
- Community: https://github.com/ansible-semaphore/semaphore/discussions
