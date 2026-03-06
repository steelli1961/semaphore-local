# Quick Start Guide - Semaphore Local

Get Semaphore running in 5 minutes!

## Step 1: Start Services (1 minute)

```bash
cd semaphore-local
./scripts/setup.sh
```

This will:
- Download and start Docker containers
- Initialize the database
- Start the Semaphore web UI

## Step 2: Access Semaphore (30 seconds)

Open your browser:
- **URL**: `http://localhost:3000`
- **Username**: `admin`
- **Password**: `changeme`

⚠️ **CHANGE THE PASSWORD IMMEDIATELY!**

## Step 3: Setup SSH Keys (2 minutes)

```bash
./scripts/setup-ssh-keys.sh
```

This creates SSH keys for authentication with target machines.

## Step 4: Configure Targets (1 minute)

Edit your inventory file with your network machines:

```bash
nano sample-configs/inventory/inventory.ini
```

Example:
```ini
[webservers]
web01.local    ansible_host=192.168.1.10
web02.local    ansible_host=192.168.1.11

[dbservers]
db01.local     ansible_host=192.168.1.20
```

## Step 5: Add SSH Key to Semaphore (1 minute)

1. In Semaphore UI: **Settings** → **SSH Keys**
2. Click **New SSH Key**
3. Upload `~/.ssh/semaphore_key`
4. Give it a name (e.g., "Local Network")

## Step 6: Run Your First Playbook

### Create Project
1. **Projects** → **New Project**
2. Name: "Local Infrastructure"
3. Repository: `/home/semaphore/playbooks` (or local path)
4. Click **Create**

### Create Inventory
1. **Inventories** → **New Inventory**
2. Name: "Local Network"
3. Create hosts from your inventory file
4. Click **Create**

### Create Template & Run
1. **Templates** → **New Template**
2. Select your project
3. Select playbook: `update-servers.yml`
4. Select inventory: "Local Network"
5. Click **Create**
6. Click **Run**

Watch the execution in real-time!

## Common Tasks

### Test if Hosts are Reachable
```bash
./scripts/test-inventory.sh
```

### View Logs
```bash
docker-compose logs -f
```

### Stop Services
```bash
docker-compose down
```

### Reset Everything
```bash
./scripts/cleanup.sh
```

## Pre-Built Playbooks

All in `sample-configs/playbooks/`:

| Playbook | Purpose |
|----------|---------|
| `update-servers.yml` | Update system packages |
| `install-packages.yml` | Install common tools |
| `manage-users.yml` | Create/manage users |
| `configure-hostname.yml` | Set hostname/network |
| `install-monitoring.yml` | Install monitoring agent |

## Troubleshooting

**Can't connect to hosts?**
- Verify SSH key permissions: `chmod 600 ~/.ssh/semaphore_key`
- Test manually: `ssh -i ~/.ssh/semaphore_key user@target-machine`
- Check firewall on target machines allows SSH (port 22)

**Semaphore won't start?**
```bash
docker-compose logs
docker-compose down -v
docker-compose up -d
```

**Database error?**
```bash
docker-compose restart database
```

## Next Steps

1. ✅ Explore the Semaphore UI
2. ✅ Create more playbooks for your use cases
3. ✅ Set up scheduled tasks for maintenance
4. ✅ Add more team members/users
5. ✅ Integrate with Git for version control

## Key Docs

- Full setup: See [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- Complete guide: See [README-LOCAL.md](README-LOCAL.md)
- Official docs: https://semaphore.rocks/

---

**You're ready to go!** 🚀

Access Semaphore now: http://localhost:3000
