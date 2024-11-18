

## Overview ( Work In Progress )

![hybrid](https://github.com/user-attachments/assets/f448431a-1650-4d91-ac3c-f52445e05bc3)




### 

This architecture represents a multi-region AWS Cloud WAN setup designed to manage and interconnect multiple environments (Production, Staging, Shared Services, and Hybrid). It uses AWS Cloud WAN as the backbone for global connectivity, enabling secure, scalable, and highly available communication between different VPCs, regions, and on-premises data centers.

The design incorporates inspection capabilities, centralized traffic management, and hybrid connectivity through AWS Direct Connect and VPN for seamless integration of on-premises and cloud workloads. Each element is modular, following best practices to ensure high performance, cost efficiency, and security.


The directory structure ensures a clear separation between global resources, environment-specific configurations, and reusable modules.


## Key Components 

#### 1. **AWS Cloud WAN**

- **Role**:
    - Acts as a global networking layer to interconnect VPCs, regions, and on-premises data centers.
- **Purpose**:
    - Facilitates simplified and scalable network operations across multiple AWS regions and beyond.

---

#### 2. **Regions: us-east-1 and eu-east-1**

- Each region hosts multiple VPCs for different workloads. The regions are interconnected via AWS Cloud WAN.

---

#### 3. **VPCs**

- **Types**:
    1. **Inspection VPCs**:
        - Contain **Firewall Subnets** with firewall endpoints for deep packet inspection and security filtering.
        - Ensure that traffic between VPCs and segments passes through a centralized security layer.
    2. **Application VPCs**:
        - Contain **App Subnets** hosting workloads (e.g., Instances for applications).
        - Attached to Cloud WAN for network connectivity.
    3. **Shared Services VPCs**:
        - Used for centralized services (e.g., logging, monitoring, IAM).
- **Subnets**:
    - **CWAN Subnet**: Connects VPCs to the Cloud WAN.
    - **App Subnet**: Hosts application instances.
    - **Firewall Subnet**: Houses the inspection and firewall components for securing traffic.
    - **NAT Gateway Subnet**: Enables outbound internet traffic for instances within the VPC.

---

#### 4. **Network Function Group (Inspection)**

- **Role**:
    - A centralized security layer for inspecting traffic between segments (Production, Staging, Shared Services, etc.).
- **Functionality**:
    - All traffic is routed through inspection pods where it is analyzed and filtered based on security policies.
    - Ensures compliance and protects against potential threats.
 

| **Source Segment** | **Destination Segment** | **Action** | **Inspection Group** |
| --- | --- | --- | --- |
| Production | Hybrid | `send-via` | `inspection` |
| Production | SharedServices | `send-via` | `inspection` |
| Hybrid | SharedServices | `send-via` | `inspection` |
| Staging | Hybrid | `send-via` | `inspection` |
| Staging | SharedServices | `send-via` | `inspection` |



---

#### 5. **Traffic Segmentation**

- **Segments**:
    1. **Production Segment**: For live production workloads.
    2. **Staging Segment**: For pre-production and testing environments.
    3. **Shared Services Segment**: Contains shared infrastructure services used by all environments.
    4. **Hybrid Segment**: For workloads that span on-premises and cloud.
- **Traffic Flows**:
    - Traffic is color-coded based on the segment (e.g., blue for Production, orange for Staging).
    - Traffic between segments follows defined routing policies, with **send-via** actions ensuring inspection and control.

---

#### 7. **AWS Direct Connect and Accelerated VPN**

- **AWS Direct Connect Gateway**:
    - Provides dedicated, high-throughput, low-latency connectivity from on-premises data centers to AWS regions.
- **Accelerated AWS Site-to-Site VPN**:
    - Offers a secure connection over the AWS Global Network for additional redundancy and failover.
    - Supports hybrid deployments by connecting US and EU on-premises data centers to their respective AWS regions.

---

#### 8. **Transit Gateways**

- **Role**:
    - Act as a regional interconnect between VPCs.
    - Provide flexible and scalable routing between the Direct Connect Gateways, and on-premises networks.
- **AWS Network Manager Integratio**
   - Transit Gateway Registration: The Transit Gateway is registered with AWS Network Manager, integrating it into the Cloud WAN Global Network.
   - Peering with Cloud WAN Core Network: A peering connection is established between the Transit Gateway and Cloud WAN Core Network. Tags, such as Segment = "hybrid", are applied to specify the network segment for hybrid connectivity, including on-premises networks.
   - Policy Table and Association: A Transit Gateway Policy Table is created to define routing policies. The policy table is associated with the peering attachment.
---

## Component Interactions

1. **Cloud WAN** serves as the central network fabric, connecting various **VPCs**, **Inspection VPCs**, and **Transit Gateways**.
2. **Transit Gateway** integrates with **AWS Network Manager** for centralized management and establishes peering with the **Cloud WAN Core Network**.
3. **Policy Table** within **Transit Gateway** allows advanced traffic control and routing policies between AWS and on-premises.
4. **Inspection VPCs** inspect and secure traffic flows, with additional security enforced by **Firewalls**.
5. **DX Gateways** and **VPN Connections** establish hybrid connectivity, interacting with **Transit Gateways** for routing.

---

### AWS Account Structure for Environment Isolation

This architecture employs a multi-account strategy to ensure secure and efficient management of different environments (`prod`, `stage`) through a centralized **Security Account**. 

- Security account Acts as the central hub for identity and access management across all AWS accounts.
- Each target account (`prod` and `stage`) has specific roles that grant permissions based on the tasks users need to perform.
- Users (developers, administrators, operational staff) authenticate in the Security account.
- Each user is assigned specific permissions within the Security account, which allow them to assume roles in the target accounts (`prod` or `stage`).
- The Security account provides a single point of control for managing access across multiple environments.
- Strong isolation between environments (`prod` and `stage`) prevents accidental or malicious actions from impacting production systems.

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
