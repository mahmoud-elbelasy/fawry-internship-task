# 🛠️ DNS Troubleshooting for `internal.example.com`

## Task Description

Investigate why the internal web dashboard (`internal.example.com`) is unreachable from multiple systems.  
The service appears to be running, but users receive "host not found" errors.  


---

## Steps Performed

### 1. Check Current DNS Configuration

Display the DNS servers currently configured on the system:

```bash
cat /etc/resolv.conf
```

**Output:**
```
nameserver 127.0.0.53
```
![Screenshot 2025-04-28 155723](https://github.com/user-attachments/assets/1686dbf0-4c6a-4eb9-a629-87c95c53b119)


This shows that the system is using an internal DNS server (`127.0.0.53`).

---

### 2. Attempt to Resolve `internal.example.com` Using the Default DNS

Test DNS resolution using the default system DNS:

```bash
dig internal.example.com
```


**Output:**
![photo_2025-04-28_16-50-44](https://github.com/user-attachments/assets/f0a96ee9-bc88-40b1-b65f-8847728feead)



Result: **Resolution succeeded** using the internal DNS server.

---

### 3. Attempt to Resolve `internal.example.com` Using Public DNS (8.8.8.8)

Manually query Google’s public DNS server:

```bash
dig @8.8.8.8 internal.example.com
```


**Output :**
```
** server can't find internal.example.com: NXDOMAIN
```
![Screenshot 2025-04-28 155845](https://github.com/user-attachments/assets/892e86c1-a37d-4541-9da5-08c1c1a9fbdf)

Result: **Resolution failed** again, as expected — public DNS servers do not know about internal domains.

---

## Findings

- The internal DNS server listed in `/etc/resolv.conf` (`10.0.0.1`) **successfully resolved** `internal.example.com`.
- Public DNS (`8.8.8.8`) **failed to resolve** `internal.example.com`, as expected.
- Therefore, the internal DNS setup is correct.

---

## Conclusion

✅ Internal DNS resolution is working properly.\
🛠️ Public DNS servers are not supposed to resolve internal domains, so this behavior is expected.

If users are still facing issues, further investigation into local DNS client configuration or network connectivity is required.

---


---

# 📄 End of Report

