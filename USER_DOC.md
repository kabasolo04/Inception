# 📘 User Documentation - Inception Project

**Repository:** [https://github.com/kabasolo04/Inception](https://github.com/kabasolo04/Inception)

## Welcome! 👋

This guide provides **basic usage instructions** for administrators managing the Inception WordPress infrastructure.

---

## 🎯 Quick Reference

### Start the Stack

```bash
make up      # First time or after 'make down'
make start   # Resume stopped containers
```

### Stop the Stack

```bash
make stop    # Pause (keeps data)
make down    # Stop and remove containers
```

### Access Points

- **Website:** https://kabasolo.42.fr
- **Admin Panel:** https://kabasolo.42.fr/wp-admin

---

## � Starting the Stack

### First Time Setup

If this is your first time, the infrastructure needs to be built:

```bash
make up
```

**⏱️ This takes 2-5 minutes** - it builds Docker images, creates containers, initializes the database, and installs WordPress.

### Subsequent Starts

If you've stopped the stack and want to resume:

```bash
make start
```

**⏱️ This takes a few seconds** - containers already exist and just need to start.

---

## 🛑 Stopping the Stack

### Temporary Stop (Preserves Data)

```bash
make stop
```

Use this for **daily shutdown**. All your data remains intact.

### Complete Shutdown

```bash
make down
```

Stops and removes containers. **Data persists** in volumes.

---

## 🌐 Accessing the Website

### Main Website

Open your browser:
```
https://kabasolo.42.fr
```

**🔒 SSL Certificate Warning:**
- You'll see a security warning (self-signed certificate)
- Click **"Advanced"** → **"Proceed to kabasolo.42.fr"**
- This is normal for development environments

### Check Data Persistence

Your data is stored in:

```bash
# WordPress files
ls -lh ~/data/web/

# Database files
ls -lh ~/data/database/
```

These directories should exist and contain files when the stack is running.
# Check specific container
docker ps | grep nginx
docker ps | grep wp-php
docker ps | grep mariadb
```

### Verify Website Accessibility

```bash
# Test HTTPS connection
curl -k https://kabasolo.42.fr

# Should return HTML content
```

### Check Logs for Errors

```bash
# View all logs
docker compose -f srcs/docker-compose.yml logs

# View specific service logs
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wp-php
docker compose -f srcs/docker-compose.yml logs mariadb

# Follow logs in real-time
docker compose -f srcs/docker-compose.yml logs -f
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

Stop tCommon Issues

### Can't Access Website

**Check:**
1. Containers running: `docker ps` (should show 3 containers)
2. Domain configured: `cat /etc/hosts | grep kabasolo`
3. Port available: `sudo lsof -i :443`

**Fix:** Restart the stack
```bash
make down
make up
```

### SSL Certificate Warning

This is **normal** for self-signed certificates in development.

**To proceed:**
- Chrome/Edge: "Advanced" → "Proceed to kabasolo.42.fr"
- Firefox: "Advanced" → "Accept the Risk and Continue"

### Database Connection Error

**Check credentials match:**
```bash
docker exec -it wp-php cat /run/secrets/db_password
docker exec -it mariadb cat /run/secrets/db_password
```

**Fix:** Restart services
```bash
make down && make up
```

### Forgot Password

View your credentials:
```bash
cat secrets/credentials.txt
```

### Port Already in Use

Find conflicting process:
```bash
sudo lsof -i :443
```

Stop it or rebuild Inception:
```bash
make down && make up
```

---

## 📞 Support

When reporting issues, include:

```bash
# Container status
docker ps -a

# Recent logs
docker compose -f srcs/docker-compose.yml logs --tail=30
```

---

**That's it! Your WordPress stack is ready to use. 🎉