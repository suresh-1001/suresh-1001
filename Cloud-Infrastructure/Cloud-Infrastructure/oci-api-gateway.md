# ☁️ OCI API Gateway Setup

This guide explains how to expose secure APIs in **Oracle Cloud Infrastructure (OCI)** using **API Gateway**, SSL, and Cloudflare DNS.  
_All IPs, domains, and tokens are placeholders — replace with your actual values._

---

## 1) Prerequisites
- OCI tenancy with permissions to create **API Gateways** and **Deployments**
- Configured **VCN** with a **public subnet**
- Domain managed in **Cloudflare** (example: `example.com`)
- Optional: SSL via **OCI Certificates** or **NGINX Proxy Manager** (DNS challenge)

---

## 2) Create API Gateway
1. In **OCI Console** → **Developer Services → API Gateway**  
2. Create a new gateway:
   - **VCN/Subnet:** select your public subnet  
   - **Endpoint Type:** `Public`  
   - **Logging:** `Enabled`

![Step 1 – OCI Console](./OCI-img.png)

---

## 3) Create Deployment
Example JSON spec to expose a backend service in Compute/Kubernetes:

```json
{
  "routes": [
    {
      "path": "/v1/*",
      "methods": ["GET", "POST"],
      "backend": {
        "type": "HTTP_BACKEND",
        "url": "http://10.0.0.50:8080"
      }
    }
  ]
}
