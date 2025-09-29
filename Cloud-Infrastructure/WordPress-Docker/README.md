# WordPress + MariaDB on Docker (Production-Ready)

A minimal, secure WordPress stack with:
- **MariaDB** (persistent volume for data)
- **Isolated Docker network**, restart policies, and healthchecks
- **.env configuration** (no secrets in version control)
- **Automated DB backups** (cron-friendly script)
- Works with **any reverse proxy** (Nginx Proxy Manager, Traefik, Cloudflare)

---

## 📐 Architecture
```
Client → (HTTPS / Reverse Proxy) → wordpress (php-fpm/apache) → mariadb
```

---

## 🚀 Quick Start
```bash
# copy environment template
cp .env.example .env

# launch stack
docker compose up -d
```
Then open: `http://<host>:8080` (or your reverse-proxied HTTPS domain).

---

## 📂 Files
- `docker-compose.yml` – WordPress + MariaDB services  
- `.env.example` – environment config template  
- `backup.sh` – one-shot database backup to `./backups/`  
- `diagram.png` – optional architecture overview  

---

## 🛠 Useful Commands
```bash
# container status
docker compose ps

# follow logs
docker compose logs -f wordpress

# query DB directly
docker compose exec mariadb mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" -e "SHOW DATABASES;"
```

---

## 🗄 Backup / Restore
```bash
# backup now
./backup.sh

# restore (example)
docker compose exec -T mariadb mariadb -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" "$MARIADB_DATABASE" < backups/latest.sql
```

---

## 🔒 Security Notes
- Don’t commit real `.env` files with secrets.  
- Keep DB port internal (compose does **not** expose 3306).  
- Always front the stack with a reverse proxy (TLS, rate limiting, WAF).  
- Keep WordPress core/plugins updated and enable 2FA.  

---

## ✅ Production Checklist
- [ ] HTTPS via reverse proxy (LetsEncrypt / Cloudflare)  
- [ ] Daily DB backups off-box (S3, rsync, etc.)  
- [ ] Strong DB/root passwords  
- [ ] Minimal plugins/themes only  
- [ ] Regular `docker compose pull && up -d`  
