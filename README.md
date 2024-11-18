## Overview

![architecture-aws](https://github.com/user-attachments/assets/c892d7aa-790c-44a4-895d-976f8be990d2)


### 

This architecture represents a multi-region AWS Cloud WAN setup designed to manage and interconnect multiple environments (Production, Staging, Shared Services, and Hybrid). It uses AWS Cloud WAN as the backbone for global connectivity, enabling secure, scalable, and highly available communication between different VPCs, regions, and on-premises data centers.

The design incorporates inspection capabilities, centralized traffic management, and hybrid connectivity through AWS Direct Connect and VPN for seamless integration of on-premises and cloud workloads. Each element is modular, following best practices to ensure high performance, cost efficiency, and security.


The directory structure ensures a clear separation between global resources, environment-specific configurations, and reusable modules.

## Directory Structure

Here’s an overview of the directory and file structure:

```
.
├── envcommon         # Common configurations shared across environments
├── live              # Environment-specific configurations
│   ├── global        # Global configurations (e.g., Cloud WAN, Accounts)
│   └── production    # Production-specific configurations
│       ├── us-east-1
│       └── eu-central-1
├── modules           # Reusable Terraform modules
└── terragrunt.hcl    # Root Terragrunt configuration
```

### Key Folders

1. **`envcommon`**  
   Contains reusable HCL configurations for various components such as **Inspection VPCs**, **Transit Gateways**, and **VPN Connections**.

2. **`live/global`**  
   Manages global resources, including **Cloud WAN** and account-level settings.

3. **`live/production`**  
   Holds region-specific configurations for the production environment, organized by AWS region.

4. **`modules`**  
   Contains Terraform modules for individual infrastructure components like **VPC**, **Firewall**, and **Transit Gateway**.

---



## Key Components 

1. **Cloud WAN**: Acts as the backbone of the global network.  
2. **Application VPC**  
3. **Transit Gateway with AWS Network Manager Integration**: Centralized routing between multiple VPCs and on-premises networks, integrated with Cloud WAN.  
   - **Transit Gateway Registration**: The Transit Gateway is registered with AWS Network Manager, integrating it into the Cloud WAN Global Network.  
   - **Peering with Cloud WAN Core Network**: A peering connection is established between the Transit Gateway and Cloud WAN Core Network. Tags, such as `Segment = "hybrid"`, are applied to specify the network segment for hybrid connectivity, including on-premises networks.  
   - **Policy Table and Association**: A Transit Gateway Policy Table is created to define routing policies. The policy table is associated with the peering attachment.  

4. **DX Gateway**: Enables high-speed, direct connections from on-premises to AWS.  
5. **Inspection VPC**: Inspects and secures traffic between regions and to/from the internet.  
6. **Firewall**: Enforces security rules for traffic within the Inspection VPC.  
7. **VPN Connection**: Establishes secure tunnels between on-premises networks and AWS.
---

## Component Interactions

1. **Cloud WAN** serves as the central network fabric, connecting various **VPCs**, **Inspection VPCs**, and **Transit Gateways**.
2. **Transit Gateway** integrates with **AWS Network Manager** for centralized management and establishes peering with the **Cloud WAN Core Network**.
3. **Policy Table** within **Transit Gateway** allows advanced traffic control and routing policies between AWS and on-premises.
4. **Inspection VPCs** inspect and secure traffic flows, with additional security enforced by **Firewalls**.
5. **DX Gateways** and **VPN Connections** establish hybrid connectivity, interacting with **Transit Gateways** for routing.

---

| **Source Segment** | **Destination Segment** | **Action** | **Inspection Group** |
| --- | --- | --- | --- |
| Production | Hybrid | `send-via` | `inspection` |
| Production | SharedServices | `send-via` | `inspection` |
| Hybrid | SharedServices | `send-via` | `inspection` |
| Staging | Hybrid | `send-via` | `inspection` |
| Staging | SharedServices | `send-via` | `inspection` |

## Usage Instructions

### 1. **Set Up Terragrunt**

Ensure Terragrunt is installed. To deploy the infrastructure, navigate to the root or a specific environment directory and run:

```bash
terragrunt run-all apply
```

### 2. **Deploying Specific Components**

To deploy a particular component (e.g., `Transit Gateway` in `us-east-1`), navigate to its directory:

```bash
cd live/production/us-east-1/prod/transit_gateway
terragrunt apply
```

### AWS Account Structure for Environment Isolation

This architecture employs a multi-account strategy to ensure secure and efficient management of different environments (`prod`, `stage`) through a centralized **Security Account**. 

- Security account Acts as the central hub for identity and access management across all AWS accounts.
- Each target account (`prod` and `stage`) has specific roles that grant permissions based on the tasks users need to perform.
- Users (developers, administrators, operational staff) authenticate in the Security account.
- Each user is assigned specific permissions within the Security account, which allow them to assume roles in the target accounts (`prod` or `stage`).
- The Security account provides a single point of control for managing access across multiple environments.
- Strong isolation between environments (`prod` and `stage`) prevents accidental or malicious actions from impacting production systems.
