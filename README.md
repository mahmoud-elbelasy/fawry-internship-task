# Task1. mygrep.sh - A Mini Grep Implementation

## Overview
`mygrep.sh` is a Bash script that implements a simplified version of the `grep` command. It searches for a specified string (case-insensitive) in a text file and outputs matching lines, with support for specific command-line options. This project fulfills the requirements of a custom command-line utility with error handling, option parsing, and a style mimicking the standard `grep` command.

## Features
- **Basic Functionality**:
  - Searches for a string (case-insensitive) in a text file.
  - Prints lines that match the search string.
- **Command-Line Options**:
  - `-n`: Displays line numbers for each matching line.
  - `-v`: Inverts the match, printing lines that do **not** contain the search string.
  - Supports combinations like `-vn` or `-nv` (behaves the same as `-v -n`).
  - `--help`: Displays usage information.
- **Error Handling**:
  - Validates input (e.g., missing search string, non-existent file).
  - Provides clear error messages and exits with appropriate status codes.
- **Executable**:
  - Script is executable (`chmod +x mygrep.sh`) and accepts input via command-line arguments.

## Usage
```bash
./mygrep.sh [OPTIONS] SEARCH_STRING FILE
```

### Options
- `-n`: Show line numbers with matching lines.
- `-v`: Print lines that do not match the search string.
- `--help`: Display usage information.

### Examples
1. Basic search for "hello":
   ```bash
   ./mygrep.sh hello testfile.txt
   ```
   Output:
   ```
   Hello world
   HELLO AGAIN
   ```

2. Search with line numbers:
   ```bash
   ./mygrep.sh -n hello testfile.txt
   ```
   Output:
   ```
   1:Hello world
   4:HELLO AGAIN
   ```

3. Invert match with line numbers:
   ```bash
   ./mygrep.sh -vn hello testfile.txt
   ```
   Output:
   ```
   2:This is a test
   3:another test line
   5:Don't match this line
   6:Testing one two three
   ```
   ![Screenshot 2025-04-28 022733](https://github.com/user-attachments/assets/3733d3d9-26c3-465c-8a90-76f7802aa765)


# Task2. DNS Troubleshooting for `internal.example.com`

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

- The internal DNS server listed in `/etc/resolv.conf` (`127.0.0.53`) **successfully resolved** `internal.example.com`.
- Public DNS (`8.8.8.8`) **failed to resolve** `internal.example.com`, as expected.
- Therefore, the internal DNS setup is correct.

---

## Conclusion

✅ Internal DNS resolution is working properly.\
🛠️ Public DNS servers are not supposed to resolve internal domains, so this behavior is expected.

If users are still facing issues, further investigation into local DNS client configuration or network connectivity is required.

---
## Step 2: Diagnose Service Reachability
To confirm whether the web service on `internal.example.com` (port 80 or 443) is reachable on the resolved IP, use the following tools and commands:

**Test Connectivity with `curl`**:
   ```bash
   curl -v http://internal.example.com
   curl -v https://internal.example.com
   ```
![Screenshot from 2025-04-28 19-34-33](https://github.com/user-attachments/assets/fff16032-91a5-4d8d-b857-5c349af81fae)

![Screenshot from 2025-04-28 19-37-11](https://github.com/user-attachments/assets/b0894b99-d15d-4d88-b8aa-b14ebbd2f70e)


   - Attempts to connect to the web service and displays verbose output.
   - Success: HTTP response code (e.g., 200 OK).
   - Failure: Errors like `Connection refused` or `Could not resolve host`.

**Test Port Reachability with `telnet`**:
   ```bash
   telnet internal.example.com 80
   telnet internal.example.com 443
   ```
   - Checks if the port is open and reachable.
   - Success: `Connected to internal.example.com`.
   - Failure: `Connection refused` or timeout.

     
   ![Screenshot from 2025-04-28 19-38-40](https://github.com/user-attachments/assets/e3784fe0-4971-40e3-80ea-04e27b444c00)


### Expected Output
- If the service is reachable, `curl` returns a valid HTTP response, and `telnet` confirms the connection.
- If unreachable, errors indicate issues at the DNS, network, or service layer.

## Step 3: Trace the Issue – List All Possible Causes
Below is a comprehensive list of potential reasons why `internal.example.com` might be unreachable, even if the service is running, categorized by DNS and network/service layers:

### DNS-Related Issues
1. **Incorrect DNS Resolution**:
   - The DNS server returns an incorrect or outdated IP address.
2. **DNS Server Unreachable**:
   - The configured DNS server (e.g., in `/etc/resolv.conf`) is down or unreachable.
3. **DNS Misconfiguration**:
   - The DNS zone for `internal.example.com` is misconfigured (e.g., missing A record).
4. **Local Resolver Cache**:
   - Cached DNS results are stale or incorrect.

### Network-Related Issues
5. **Firewall Blocking Traffic**:
   - A local or network firewall blocks outgoing connections to port 80/443 or the resolved IP.
6. **Network Routing Issues**:
   - Routing tables prevent packets from reaching the target IP.
7. **Service IP Unreachable**:
   - The resolved IP is not reachable due to network segmentation or NAT issues.

### Service-Related Issues
8. **Web Service Not Running**:
   - The web server (e.g., Apache, Nginx) is stopped or crashed.
9. **Service Listening on Wrong Interface/Port**:
   - The web service is not bound to the expected IP or port (e.g., listening on `127.0.0.1` instead of `0.0.0.0`).
10. **Server-Side Firewall**:
    - A firewall on the server blocks incoming connections to port 80/443.
11. **SSL/TLS Misconfiguration**:
    - For HTTPS (port 443), an invalid or expired SSL certificate causes connection failures.

### Other Issues
12. **Local Hosts File Override**:
    - An entry in `/etc/hosts` overrides DNS resolution with an incorrect IP.
13. **Client-Side Proxy/VPN**:
    - A proxy or VPN misroutes or blocks traffic to `internal.example.com`.

## Step 4: Propose and Apply Fixes
For each potential issue identified above, the following sections explain how to confirm it as the root cause and provide the exact Linux commands to fix it.

### 1. Incorrect DNS Resolution
- **Confirm**:
  ```bash
  dig internal.example.com
  ```
  - Compare the resolved IP with the expected IP (e.g., `192.168.1.100`).
  - Check against a public DNS like Google’s:
  ```bash
  dig @8.8.8.8 internal.example.com
  ```
- **Fix**:
  - Update the DNS A record in the DNS server configuration (requires admin access to the DNS server).
  - Example (for BIND):
  ```bash
  sudo vi /etc/bind/db.example.com
  # Update: internal IN A 192.168.1.100
  sudo systemctl restart named
  ```

### 2. DNS Server Unreachable
- **Confirm**:
  ```bash
  ping $(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
  ```
  - If no response, the DNS server is down or unreachable.
- **Fix**:
  - Update `/etc/resolv.conf` to use a reachable DNS server (e.g., Google’s):
  ```bash
  sudo sh -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
  ```

### 3. DNS Misconfiguration
- **Confirm**:
  ```bash
  dig internal.example.com
  ```
  - Look for `NXDOMAIN` or no A record in the response.
- **Fix**:
  - Correct the DNS zone file (similar to Issue 1).
  - Example:
  ```bash
  sudo vi /etc/bind/db.example.com
  # Add: internal IN A 192.168.1.100
  sudo systemctl restart named
  ```

### 4. Local Resolver Cache
- **Confirm**:
  ```bash
  sudo systemd-resolve --statistics
  ```
  - Check for cached entries. Clear cache to test:
  ```bash
  sudo systemd-resolve --flush-caches
  dig internal.example.com
  ```
- **Fix**:
  - Flush the DNS cache:
  ```bash
  sudo systemd-resolve --flush-caches
  ```

### 5. Firewall Blocking Traffic
- **Confirm**:
  ```bash
  sudo iptables -L OUTPUT -v -n | grep '80\|443'
  sudo ufw status
  ```
  - Look for rules dropping traffic to port 80/443 or the target IP.
- **Fix**:
  - Allow outgoing traffic to port 80/443:
  ```bash
  sudo ufw allow out 80/tcp
  sudo ufw allow out 443/tcp
  sudo ufw enable
  sudo ufw reload
  ```

![image](https://github.com/user-attachments/assets/656601ce-ebad-4167-b781-bf311ce6b5f1)





## Bonus: Configure Local /etc/hosts and Persist DNS Settings
### Local /etc/hosts Entry
To bypass DNS for testing:
- **Command**:
  ```bash
  sudo sh -c 'echo "127.0.0.1 internal.example.com" >> /etc/hosts'
  ```
- **Verification**:
  ```bash
  ping internal.example.com
  ```
  - Confirms the IP resolves to `127.0.0.1` without DNS.
    ![image](https://github.com/user-attachments/assets/0eac14d5-9155-4449-a521-b8b7b4f37860)




---

# 📄 End of Report

