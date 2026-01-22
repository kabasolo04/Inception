# 📘 User Documentation - Inception Project

## Welcome! 👋

This guide will help you set up and use the Inception WordPress infrastructure. No Docker expertise required - just follow the steps!

---

## 🎯 Quick Start

### Prerequisites

- **Operating System:** Linux (Ubuntu/Debian recommended)
- **Required Software:** 
  - Docker (20.10+)
  - Docker Compose (2.0+)
  - Make
  - OpenSSL
- **Permissions:** sudo access for host file modification

### Installation Check

```bash
# Verify Docker is installed
docker --version
docker compose version

# Verify Make is installed
make --version
```

---

## 🚀 Getting Started

### Step 1: Clone the Project

```bash
git clone <repository-url>
cd Inception
```

### Step 2: Automatic Setup (Recommended)

```bash
make setup
```

This single command will:
- Add `kabasolo.42.fr` to your `/etc/hosts` file
- Generate environment variables in `srcs/.env`
- Create secure random passwords in `secrets/` folder

### Step 3: Review Credentials

Open `secrets/credentials.txt` and verify your WordPress users:

```
WP_USER_NAME=kabasolo
WP_USER_EMAIL=kolodbikaabasolo@gmail.com
WP_USER_PASSWORD=<randomly-generated>
WP_ADMIN_USER=koldo
WP_ADMIN_EMAIL=kolodbikaabasolo@gmail.com
WP_ADMIN_PASSWORD=<randomly-generated>
```

**💡 Tip:** Save these credentials somewhere safe! You'll need them to log into WordPress.

### Step 4: Launch Your Infrastructure

```bash
make up
```

This command will:
- Build all Docker images (NGINX, WordPress, MariaDB)
- Create containers and network
- Initialize the database
- Install WordPress
- Generate SSL certificates

**⏱️ Note:** First build takes 2-5 minutes depending on your internet speed.

### Step 5: Access Your Website

Open your browser and navigate to:

```
https://kabasolo.42.fr
```

**🔒 SSL Warning:** You'll see a security warning because we're using a self-signed certificate. This is normal for development. Click "Advanced" → "Proceed to kabasolo.42.fr".

---

## 📝 Logging In

### WordPress Admin Dashboard

1. Navigate to: `https://kabasolo.42.fr/wp-admin`
2. Username: `koldo` (or value from `WP_ADMIN_USER`)
3. Password: Check `secrets/credentials.txt` for `WP_ADMIN_PASSWORD`

### Regular User Account

1. Navigate to: `https://kabasolo.42.fr/wp-login.php`
2. Username: `kabasolo` (or value from `WP_USER_NAME`)
3. Password: Check `secrets/credentials.txt` for `WP_USER_PASSWORD`

---

## 🎮 Managing Your Infrastructure

### Common Commands

| Command | What It Does | When To Use |
|---------|--------------|-------------|
| `make up` | Start everything from scratch | First time or after `make down` |
| `make start` | Resume stopped containers | After `make stop` |
| `make stop` | Pause containers (keeps data) | Temporary pause |
| `make down` | Stop and remove containers | Clean shutdown |
| `make clean` | Remove containers + volumes | Reset but keep images |
| `make fclean` | Full cleanup | Start completely fresh |
| `make re` | Rebuild everything | After changing Dockerfiles |

### Typical Workflows

#### Daily Use

```bash
# Morning - Start your work
make start

# Evening - Stop for the day
make stop
```

#### Fresh Install

```bash
# Complete reset and rebuild
make fclean
make setup
make up
```

#### Testing Changes

```bash
# After modifying configuration
make re
```

---

## 🔍 Checking Status

### Are My Containers Running?

```bash
docker ps
```

You should see three containers:
- `nginx`
- `wp-php`
- `mariadb`

### View Live Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs -f

# Specific service
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wp-php
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

**💡 Tip:** Press `Ctrl+C` to stop viewing logs.

---

## ⚙️ Configuration

### Changing the Domain Name

1. Edit the Makefile:
   ```makefile
   HOST := yournewdomain.42.fr
   ```

2. Recreate setup:
   ```bash
   make fclean
   make setup
   make up
   ```

### Changing WordPress Title

Edit `srcs/.env`:
```bash
WP_TITLE=My Awesome Site
```

Then restart:
```bash
make down
make up
```

### Changing Database Settings

Edit `srcs/.env`:
```bash
DB_NAME=my_database
DB_USER=my_user
```

**⚠️ Warning:** Changing these after initial setup requires rebuilding!

---

## 📊 Where Is My Data?

Your WordPress files and database are stored on your host machine:

- **WordPress Files:** `/home/<your-username>/data/web/`
- **Database Files:** `/home/<your-username>/data/database/`

These folders persist even when containers are stopped. To completely remove them:

```bash
make fclean
```

---

## 🆘 Troubleshooting

### Problem: Can't Access Website

**Symptom:** Browser shows "Site can't be reached"

**Solutions:**

1. Check containers are running:
   ```bash
   docker ps
   ```

2. Verify domain in hosts file:
   ```bash
   cat /etc/hosts | grep kabasolo
   ```
   Should show: `127.0.0.1 kabasolo.42.fr`

3. Test NGINX is listening:
   ```bash
   sudo lsof -i :443
   ```

### Problem: SSL Certificate Error Won't Go Away

**Symptom:** Browser keeps showing security warning

**Solution:**

This is normal for self-signed certificates. To proceed:
- **Chrome/Edge:** Click "Advanced" → "Proceed to kabasolo.42.fr (unsafe)"
- **Firefox:** Click "Advanced" → "Accept the Risk and Continue"

### Problem: Database Connection Error

**Symptom:** WordPress shows "Error establishing database connection"

**Solutions:**

1. Check MariaDB is running:
   ```bash
   docker ps | grep mariadb
   ```

2. Verify database credentials match:
   ```bash
   # Check WordPress knows the password
   docker exec -it wp-php cat /run/secrets/db_password
   
   # Check MariaDB has the same password
   docker exec -it mariadb cat /run/secrets/db_password
   ```

3. Restart services:
   ```bash
   make down
   make up
   ```

### Problem: Port 443 Already in Use

**Symptom:** Error "port is already allocated"

**Solution:**

Find what's using the port:
```bash
sudo lsof -i :443
```

Stop the conflicting service or change Inception's port in docker-compose.yml.

### Problem: Permission Denied on Data Folders

**Symptom:** Can't write to `/home/<user>/data/`

**Solution:**

```bash
sudo chown -R $USER:$USER ~/data/
```

### Problem: Forgot WordPress Password

**Solution:**

Check your credentials file:
```bash
cat secrets/credentials.txt
```

Or reset by rebuilding:
```bash
make fclean
make setup
make up
```

---

## 🔐 Security Notes

### Passwords

- Never commit the `secrets/` folder to git
- Store credentials securely (password manager recommended)
- Passwords are randomly generated 12-16 character base64 strings

### SSL/TLS

- Uses self-signed certificates (fine for development)
- For production, use Let's Encrypt or proper CA certificates
- TLS 1.2 and 1.3 enabled

### Network

- Only port 443 exposed to host machine
- Database and WordPress communicate via internal Docker network
- No direct database access from outside

---

## 💡 Tips & Best Practices

### Backups

Your data persists in `/home/<user>/data/`. To backup:

```bash
# Backup WordPress files
tar -czf wordpress-backup.tar.gz ~/data/web/

# Backup database
tar -czf database-backup.tar.gz ~/data/database/
```

### Performance

- First load may be slow as WordPress generates cache
- Subsequent loads are faster
- Consider increasing PHP memory limit in `srcs/requirements/wordpress/php.ini`

### Development

- Edit WordPress files directly in `~/data/web/`
- Changes reflect immediately (no rebuild needed)
- Theme/plugin changes persist across restarts

### Updating WordPress

WordPress will auto-update via the admin panel. Docker containers don't need rebuilding for WP updates.

---

## 📞 Getting Help

### Useful Commands for Support

When asking for help, provide output from:

```bash
# System info
docker --version
docker compose version
uname -a

# Container status
docker ps -a

# Recent logs
docker compose -f srcs/docker-compose.yml logs --tail=50
```

### Log Files Location

Inside containers:
- **NGINX:** `/var/log/nginx/`
- **PHP-FPM:** `/var/log/php8/`
- **MariaDB:** `/var/log/mysql/`

---

## 🎓 Learning More

### Understanding the Stack

- **NGINX:** Web server handling HTTPS requests
- **WordPress:** Content management system
- **MariaDB:** Database storing WordPress data
- **PHP-FPM:** Executes PHP code for WordPress

### Docker Concepts

- **Container:** Isolated running instance of an image
- **Image:** Template for creating containers
- **Volume:** Persistent storage for container data
- **Network:** Virtual network connecting containers
- **Secret:** Secure way to store passwords

---

## ✅ Checklist for Success

Before starting:
- [ ] Docker installed and running
- [ ] Make is available
- [ ] Have sudo access
- [ ] Ports 443 is free

After `make setup`:
- [ ] `secrets/` folder exists
- [ ] `srcs/.env` file created
- [ ] `/etc/hosts` contains kabasolo.42.fr

After `make up`:
- [ ] Three containers running (`docker ps`)
- [ ] Can access https://kabasolo.42.fr
- [ ] Can log into WordPress admin
- [ ] Data folders exist in `~/data/`

---

## 🎉 You're All Set!

Your WordPress infrastructure is now running! Start creating content, installing themes, and building your site.

**Happy coding! 🚀**