

## Overview ( Work In Progress )


<img width="1630" alt="hybrid-aws-min" src="https://github.com/user-attachments/assets/705948ea-40d1-4e7d-95be-8d41328aa23d">

### 

This architecture represents a multi-region AWS Cloud WAN setup designed to manage and interconnect multiple environments (Production, Staging, Shared Services, and Hybrid). It uses AWS Cloud WAN as the backbone for global connectivity, enabling secure, scalable, and highly available communication between different VPCs, regions, and on-premises data centers.

The design incorporates inspection capabilities, centralized traffic management, and hybrid connectivity through AWS Direct Connect and VPN for seamless integration of on-premises and cloud workloads. Each element is modular, following best practices to ensure high performance, cost efficiency, and security.



## Key Components 

#### 1. **AWS Cloud WAN**


 - Acts as a global networking layer to interconnect VPCs, regions, and on-premises data centers.
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

 - A centralized security layer for inspecting traffic between segments (Production, Staging, Shared Services, etc.).
 - All traffic is routed through inspection pods where it is analyzed and filtered based on security policies.
 - Ensures compliance and protects against potential threats.
 

| **Source Segment**    | **Destination Segment**  | **Action**                   |
|-----------------------|--------------------------|-----------------------------|
| Production US         | Hybrid                   | Inspected (`send-via`)      |
| Production US         | Shared Services          | Inspected (`send-via`)      |
| Hybrid                | Shared Services          | Inspected (`send-via`)      |
| Staging US            | Hybrid                   | Inspected (`send-via`)      |
| Staging US            | Shared Services          | Inspected (`send-via`)      |
| Production EU         | Production US            | No Traffic                  |
| Staging EU            | Staging US               | No Traffic                  |
| Production            | Internet                 | Inspected (`send-to`)       |
| Staging               | Internet                 | Inspected (`send-to`)       |
| Internet              | Production / Staging                 |  Not implemented       |


---

#### 5. **Traffic Segmentation**
 
- Segments:
    1. Production US Segment: For live production workloads in the US region.
    2. Production EU Segment: For live production workloads in the EU region.
    3. Staging US Segment: For pre-production and testing environments in US region.
    4. Staging EU Segment: For pre-production and testing environments in EU region. 
    5. Shared Services Segment: Contains shared infrastructure services used by all environments.
    6. Hybrid Segment: For workloads that span on-premises and cloud.
- Traffic Flows:
    - Traffic is color-coded based on the segment (e.g., blue for Production, orange for Staging).
    - Traffic between segments follows defined routing policies, with **send-via** actions ensuring inspection and control.

---

#### 7. **AWS Direct Connect and Accelerated VPN**

- AWS Direct Connect Gateway:
    - Provides dedicated, high-throughput, low-latency connectivity from on-premises data centers to AWS regions.
- Accelerated AWS Site-to-Site VPN:
    - Offers a secure connection over the AWS Global Network for additional redundancy and failover.
    - Supports hybrid deployments by connecting US and EU on-premises data centers to their respective AWS regions.

---

#### 8. **Transit Gateways**

- Act as a regional interconnect between VPCs.
- Provide flexible and scalable routing between the Direct Connect Gateways, and on-premises networks.
- AWS Network Manager Integratio
   - Transit Gateway Registration: The Transit Gateway is registered with AWS Network Manager, integrating it into the Cloud WAN Global Network.
   - Peering with Cloud WAN Core Network: A peering connection is established between the Transit Gateway and Cloud WAN Core Network. Tags, such as Segment = "hybrid", are applied to specify the network segment for hybrid connectivity, including on-premises networks.
   - Policy Table and Association: A Transit Gateway Policy Table is created to define routing policies. The policy table is associated with the peering attachment.
---

## Security 

This solution supports companies requiring stringent security compliance by implementing comprehensive traffic inspection and control:

- **North-South Traffic Inspection**:
  - On-Premises Connectivity (Ingress and Egress): All incoming (ingress) and outgoing (egress) traffic between on-premises data centers and AWS passes through centralized Inspection VPCs. This ensures that data moving between on-premises and cloud environments is thoroughly inspected for security threats and compliance adherence.
  - Internet Connectivity (Egress Only): VPCs within AWS have egress-only access to the internet, primarily for purposes like downloading updates or patches. This outbound internet traffic is routed through the Inspection VPCs for security checks. **Ingress from the internet is not implemented in this case**.

- **East-West Traffic Inspection**:
  - Inter-VPC Communication: Traffic between VPCs within AWS (e.g., between Production and Shared Services) is routed through the **Inspection VPCs** via **send-via** policies, allowing deep packet inspection and enforcement of security policies between different environments.

- **Traffic Segmentation and Isolation**:
  - AWS Cloud WAN Segments: The use of segments in AWS Cloud WAN, with defined routing policies, isolates environments (Production, Staging, Hybrid). This prevents unauthorized lateral movement and data leakage between segments.

- **Centralized Security Enforcement**:
  - Inspection VPCs: Serve as chokepoints for all traffic flows—north-south (on-premises ingress and egress, internet egress) and east-west—enabling consistent application of security policies across the network.
  - Firewalls and Security Appliances: Deployed within Inspection VPCs to inspect, log, and control traffic based on compliance requirements.

- **Secure Hybrid Connectivity**:
  - AWS Direct Connect and VPN: Provide secure, encrypted pathways for on-premises traffic, maintaining data integrity and confidentiality between on-premises networks and AWS.

- **Multi-Account Structure with Centralized Security**:
  - Security Account: Acts as a central point for identity and access management, ensuring consistent security policies and simplifying compliance auditing across all environments.
  - Environment Isolation: Strong separation between `prod` and `stage` accounts prevents accidental or malicious actions from impacting production systems.

By thoroughly inspecting and controlling both north-south (on-premises ingress and egress, internet egress) and east-west traffic the architecture enforces strict security measures. This comprehensive approach ensure all data flows are secure, monitored, and adhere to best practices.

 --- 
 
### AWS Account Structure for Environment Isolation

This architecture employs a multi-account strategy to ensure secure and efficient management of different environments (`prod`, `stage`) through a centralized **Security Account**. 

- Security account Acts as the central hub for identity and access management across all AWS accounts.
- Each target account (`prod` and `stage`) has specific roles that grant permissions based on the tasks users need to perform.
- Users (developers, administrators, operational staff) authenticate in the Security account.
- Each user is assigned specific permissions within the Security account, which allow them to assume roles in the target accounts (`prod` or `stage`).
- The Security account provides a single point of control for managing access across multiple environments.
- Strong isolation between environments (`prod` and `stage`) prevents accidental or malicious actions from impacting production systems.

 --- 
### GDPR 

This architecture ensures compliance with GDPR Chapter V by keeping personal data stored and processed entirely within the EU region and by performing traffic inspection within each region. Specifically:

- **Complete Isolation**: The **Production EU Segment** is entirely separate from the **Production US Segment**, with no network connectivity between them. Since these segments are fully isolated, data cannot flow from the EU to the US.

- **Regional Inspection**: Each region implements its own **Inspection VPCs**, ensuring that all traffic inspection and security controls occur locally. This means that EU data is inspected and managed solely within the EU region, without involving any resources or networks from other regions.

- **Data Residency Assurance**: By segregating environments at the network level and performing regional inspections, the architecture guarantees that all EU data is stored, processed (compute), and secured within the EU region, meeting GDPR's data residency requirements.

This design allows companies to store, process, and inspect personal data exclusively within the EU, preventing any unintended transfers outside the region and helping them comply with GDPR Chapter V regulations on international data movement.

___
### Module Overview and Implementation Steps

#### 1. Set Up Cloud WAN Core Network and Segments

- :white_check_mark: Define a core network with 4 segments: Production, Hybrid, Staging, Shared Services,
- :white_check_mark: Create Inspection Network Function group. 
- :arrows_counterclockwise: ( WIP ) Fix Network function group segments actions used to route traffic ( `send-via`, `send-to` )

#### 2. Automate Attachments to Segments

- :white_check_mark: Automatically attach any VPC tagged with `segment:prod` to the Production segment and any VPC tagged with `segment:stage` to the Staging segment.
- :white_check_mark: Automatically attach any VPC with the tag `inspection:true` to the Network Function Group.
- :white_check_mark: Automatically attach any Transit Gateway with the tag `hybrid:true` to the Hybrid segment.

#### 3. Create Inspection VPC

- :white_check_mark: Create an Inspection VPC with the following subnets: Firewall, Cloud WAN, Public
- :white_check_mark: Configure route tables for each subnet according to their function.
- :white_check_mark: Attach Inspection VPC to AWS WAN Core Network.

#### 4. Create Application VPC

- :white_check_mark: Create an Application VPC with the following subnets: Private Subnet, WAN Subnet
- :white_check_mark: Attach Application VPC to AWS WAN Core Network.

#### 5. Deploy AWS Network Firewall

- :white_check_mark: Deploy a firewall to the Firewall Subnets in the Inspection VPC.
- :white_check_mark: Create a Network Firewall Policy with demo stateful and stateless rules.
- :white_check_mark: Associate the policy with the AWS Network Firewall in the Inspection VPC.

#### 6. Set Up Transit Gateway

- :white_check_mark: Create Transit Gateway.
- :white_check_mark: Register Transit Gateway with Cloud WAN.
- :white_check_mark: Create Peering attachment with core network.

#### 7. Set Up Direct Connect Gateway

- :white_check_mark: Create Direct Connect Gateway.
- :white_check_mark: Associate Direct Connect Gateway with Transit Gateway.

#### 8. Set Up Customer Gateway and VPN

- :white_check_mark: Create Customer Gateway.
- :white_check_mark: Create a VPN connection between the Customer Gateway and the Transit Gateway.

