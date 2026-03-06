# Semaphore Local - Ansible Automation for Local Networks

A complete setup for running Semaphore (open-source Ansible UI) locally to manage and automate Linux machines in your network.

## 📋 What's Included

- **Docker Compose configuration** for easy Semaphore deployment
- **Sample Ansible playbooks** for common Linux administration tasks
- **Inventory templates** for defining your network topology
- **Setup and helper scripts** for quick initialization
- **Complete documentation** for setup and usage

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- SSH access to target Linux machines (or local VMs)
- Git

### 1. Install and Start

```bash
cd semaphore-local

# Make scripts executable
chmod +x scripts/*.sh

# Run setup
./scripts/setup.sh
```

Semaphore will be available at `http://localhost:3000`

**Default credentials:**
- Username: `admin`
- Password: `changeme` (⚠️ Change immediately!)

### 2. Generate SSH Keys

```bash
./scripts/setup-ssh-keys.sh
```

This creates `~/.ssh/semaphore_key` for authenticating with target machines.

### 3. Configure Your Inventory

Edit `sample-configs/inventory/inventory.ini` and add your machines:

```ini
[webservers]
web01.local    ansible_host=192.168.1.10
web02.local    ansible_host=192.168.1.11

[dbservers]
db01.local     ansible_host=192.168.1.20
```

### 4. Add SSH Key to Semaphore

1. Log into Semaphore UI
2. Go to **Settings** → **SSH Keys**
3. Click **New SSH Key**
4. Upload your private key (`~/.ssh/semaphore_key`)

### 5. Create Project & Run Playbook

1. **Projects** → **New Project**
2. Link to playbooks directory: `sample-configs/playbooks/`
3. **Inventories** → Create inventory from your `.ini` file
4. Run a playbook!

## 📁 Directory Structure

```
semaphore-local/
├── docker-compose.yml              # Docker Compose configuration
├── SETUP_INSTRUCTIONS.md           # Detailed setup guide
├── sample-configs/
│   ├── playbooks/                  # Sample Ansible playbooks
│   │   ├── update-servers.yml      # System package updates
│   │   ├── install-packages.yml    # Install packages
│   │   ├── manage-users.yml        # User account management
│   │   ├── configure-hostname.yml  # Hostname/network config
│   │   └── install-monitoring.yml  # Monitoring agent setup
│   ├── inventory/
│   │   ├── inventory.ini           # INI format inventory
│   │   └── inventory.yml           # YAML format inventory
│   └── templates/                  # Configuration templates
└── scripts/
    ├── setup.sh                    # Main setup script
    ├── setup-ssh-keys.sh           # SSH key generation
    ├── cleanup.sh                  # Cleanup script
    └── test-inventory.sh           # Test host connectivity
```

## 📚 Sample Playbooks

### 1. Update System Packages
```bash
# Updates all packages on target systems
./sample-configs/playbooks/update-servers.yml
```

### 2. Install Packages
```bash
# Installs common utilities like curl, git, htop, etc.
./sample-configs/playbooks/install-packages.yml
```

### 3. Manage Users
```bash
# Creates or modifies user accounts
./sample-configs/playbooks/manage-users.yml
```

### 4. Configure Hostname
```bash
# Sets hostname and network configuration
./sample-configs/playbooks/configure-hostname.yml
```

### 5. Install Monitoring
```bash
# Installs Prometheus node_exporter for monitoring
./sample-configs/playbooks/install-monitoring.yml
```

## 🔧 Common Tasks

### Test SSH Connectivity

```bash
# Test if all inventory hosts are reachable
./scripts/test-inventory.sh

# Or use Ansible directly
ansible all -i sample-configs/inventory/inventory.ini -m ping
```

### View Semaphore Logs

```bash
docker-compose logs -f semaphore
```

### Access Database

```bash
# PostgreSQL CLI
docker-compose exec database psql -U semaphore_user -d semaphore
```

### Reset to Default State

```bash
./scripts/cleanup.sh
docker-compose up -d
```

### Stop Services

```bash
docker-compose stop
```

### Restart Services

```bash
docker-compose restart
```

## 🔐 Security Best Practices

1. **Change Admin Password Immediately**
   - Log in → Settings → Users → Change Password

2. **Use Strong SSH Keys**
   - Generate 4096-bit RSA keys minimum
   - Never share private keys

3. **Network Isolation**
   - Keep Semaphore on internal network only
   - Use firewall rules to restrict access

4. **Backup Database**
   ```bash
   docker-compose exec database pg_dump -U semaphore_user semaphore > backup.sql
   ```

5. **Limit User Permissions**
   - Create dedicated Ansible user on target machines
   - Use `sudo` only when necessary

## 🐛 Troubleshooting

### Containers Won't Start

```bash
# Check logs
docker-compose logs

# Reset everything
docker-compose down -v
docker-compose up -d
```

### SSH Connection Failed

```bash
# Test SSH manually
ssh -i ~/.ssh/semaphore_key user@target-machine

# Check permissions
ls -la ~/.ssh/semaphore_key  # Should be 600
ls -la ~/.ssh/semaphore_key.pub  # Should be 644
```

### Database Connection Error

```bash
# Check database logs
docker-compose logs database

# Verify database is running
docker-compose ps database
```

### Playbook Execution Failed

1. Check Semaphore UI for error details
2. View task logs in Semaphore
3. Test playbook locally: `ansible-playbook sample-configs/playbooks/update-servers.yml -i inventory.ini`

## 📖 Usage Examples

### Example 1: Update All Production Servers

1. In Semaphore UI: **Projects** → Select your project
2. Click **Run/Execute** on `update-servers.yml`
3. Select inventory: `production`
4. Click **Start Task**
5. Monitor progress in real-time

### Example 2: Install Monitoring on New Servers

1. Add new servers to inventory file
2. In Semaphore: **Inventories** → Update
3. **Projects** → Run `install-monitoring.yml`
4. Select new inventory
5. Verify metrics at `http://target-ip:9100/metrics`

### Example 3: Create Batch User Accounts

Edit `manage-users.yml` to add users you want, then run it across your infrastructure.

## 🌐 Network Setup Example

For a typical setup:

```ini
[webservers]
nginx01.local      ansible_host=192.168.1.10
nginx02.local      ansible_host=192.168.1.11

[dbservers]
postgres01.local   ansible_host=192.168.1.20
mysql01.local      ansible_host=192.168.1.21

[appservers]
app01.local        ansible_host=192.168.1.30
app02.local        ansible_host=192.168.1.31

[monitoring]
prometheus01.local ansible_host=192.168.1.40
```

Then you can target:
- All machines: `all`
- By role: `webservers`, `dbservers`, etc.
- Production only: `production`
- Specific host: `web01.local`

## 📊 Advanced Features

### Scheduled Tasks

In Semaphore UI:
1. **Projects** → Select project
2. **Templates** → Create/Edit
3. **Cron** → Set schedule for regular runs

### Integration with Git

1. Create a Git repository with your playbooks
2. In Semaphore: **Projects** → Create/Edit
3. Set **Repository** to your Git repo URL
4. Set **Branch** to the branch with your playbooks

### Custom Plugins

Extend playbooks with custom Ansible modules or plugins by adding them to the playbooks directory structure.

## 🛠️ Customization

### Add Your Own Playbooks

1. Create `.yml` file in `sample-configs/playbooks/`
2. Follow Ansible best practices
3. Upload to Semaphore or link Git repository
4. Create template and run

### Modify Inventory Groups

Edit `sample-configs/inventory/inventory.ini` to add your groups:

```ini
[mygroup]
host1.local  ansible_host=192.168.1.100
host2.local  ansible_host=192.168.1.101
```

## 📞 Support & Resources

- **Official Semaphore Docs**: https://semaphore.rocks/
- **GitHub**: https://github.com/ansible-semaphore/semaphore
- **Ansible Docs**: https://docs.ansible.com/
- **Community**: GitHub Discussions

## 📝 License

This setup guide follows the same license as Semaphore (MIT License).

---

**Quick Reference Commands:**

```bash
# Setup
./scripts/setup.sh                    # Initial setup
./scripts/setup-ssh-keys.sh          # Generate SSH keys

# Docker Compose
docker-compose up -d                  # Start all services
docker-compose down                   # Stop all services
docker-compose logs -f                # View logs
docker-compose restart semaphore      # Restart Semaphore

# Testing
./scripts/test-inventory.sh           # Test host connectivity
ansible -i inventory.ini all -m ping  # Direct Ansible ping

# Cleanup
docker-compose down -v                # Remove everything
./scripts/cleanup.sh                  # Guided cleanup
```

---

**Get Started:** `./scripts/setup.sh` → Open `http://localhost:3000` → 🚀
