# 🛠️ DNS Troubleshooting for `internal.example.com`

## Task Description

Investigate why the internal web dashboard (`internal.example.com`) is unreachable from multiple systems.  
The service appears to be running, but users receive "host not found" errors.  
Focus: **Troubleshoot, verify DNS resolution, and compare it using different DNS servers**.

---

## Steps Performed

### 1. Check Current DNS Configuration

Display the DNS servers currently configured on the system:

```bash
cat /etc/resolv.conf
```

**Output example:**
```
nameserver 10.0.0.1
```

This shows that the system is using an internal DNS server (`10.0.0.1`).

---

### 2. Attempt to Resolve `internal.example.com` Using the Default DNS

Test DNS resolution using the default system DNS:

```bash
dig internal.example.com
```

or

```bash
nslookup internal.example.com
```

**Output example:**
```
;; connection timed out; no servers could be reached
```

or

```
** server can't find internal.example.com: NXDOMAIN
```

Result: **Resolution failed** using the internal DNS server.

---

### 3. Attempt to Resolve `internal.example.com` Using Public DNS (8.8.8.8)

Manually query Google’s public DNS server:

```bash
dig @8.8.8.8 internal.example.com
```

or

```bash
nslookup internal.example.com 8.8.8.8
```

**Output example:**
```
** server can't find internal.example.com: NXDOMAIN
```

Result: **Resolution failed** again, as expected — public DNS servers do not know about internal domains.

---

## Findings

- The internal DNS server listed in `/etc/resolv.conf` (`10.0.0.1`) **failed to resolve** `internal.example.com`.
- Public DNS (`8.8.8.8`) also **failed to resolve** `internal.example.com`, which is expected because public DNS servers do not manage internal company domains.
- Therefore, the issue is likely with the **internal DNS server** being down, misconfigured, or missing the correct DNS records.

---

## Conclusion

✅ DNS misconfiguration or failure detected.  
🛠️ The internal DNS server needs to be fixed or updated to properly resolve `internal.example.com`.

If urgent access is required, a temporary solution could be:
- Manually adding an entry to `/etc/hosts`
- Or restoring the internal DNS service

---

## Bonus (optional)

**Temporary `/etc/hosts` example:**

```bash
sudo nano /etc/hosts
```

Add:
```
10.0.0.50   internal.example.com
```
(Replace `10.0.0.50` with the correct server IP if known.)

---

# 📄 End of Report

