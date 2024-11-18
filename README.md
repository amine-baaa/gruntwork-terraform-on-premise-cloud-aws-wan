## Overview

![architecture-aws](https://github.com/user-attachments/assets/c892d7aa-790c-44a4-895d-976f8be990d2)


This project utilizes **Terraform** with **Terragrunt** to manage and deploy a multi-region network infrastructure. The architecture is modular, enabling easy reuse and integration of components. The key infrastructure elements include **Cloud WAN**, **VPCs**, **Transit Gateways**, **VPN Connections**, **DX Gateways**, **Inspection VPCs**, and **Firewalls**.

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
2. **VPC**: Deploys Virtual Private Clouds in specific AWS regions.  
3. **Transit Gateway with AWS Network Manager Integration**: Centralized routing between multiple VPCs and on-premises networks, integrated with Cloud WAN for advanced management and monitoring.  
   - **Transit Gateway Registration**: The Transit Gateway is registered with AWS Network Manager, integrating it into the Cloud WAN Global Network. This enables centralized management and monitoring of the Transit Gateway.  
   - **Peering with Cloud WAN Core Network**: A peering connection is established between the Transit Gateway and Cloud WAN Core Network. Tags, such as `Segment = "hybrid"`, are applied to specify the network segment for hybrid connectivity, including on-premises networks.  
   - **Policy Table and Association**: A Transit Gateway Policy Table is created to define routing policies. The policy table is associated with the peering attachment, enabling advanced traffic control between Cloud WAN and Transit Gateway.  

4. **DX Gateway**: Enables high-speed, direct connections from on-premises to AWS.  
5. **Inspection VPC**: Inspects and secures traffic between regions and to/from the internet.  
6. **Firewall**: Enforces security rules for traffic within the Inspection VPC.  
7. **VPN Connection**: Establishes secure tunnels between on-premises networks and AWS.  
8. **Customer Gateway**: Represents the on-premises device endpoint for a VPN connection.
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
