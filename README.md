# OData v2 Service API for STC ABAP Tasklist

This project provides a **minimal Proof-of-Concept (PoC) HTTP Service API for the SAP ABAP Task List API**. It is based on the concepts and functionality of ABAP Task Lists for automated configurations.

## Motivation

Infrastructure as Code (IaC) gains attention within SAP Ecosystem. The SAP BTP ecosystem provides with its Terraform Providers (BTP, Cloud Connector, Identity Service in the making) some solid solutions. Ansible is currently the only valid IaC Tool for onPremise SAP ecosystem.

Unfortunately, SAP deprecated their open-source projects around RFC APIs for Python and NodeJS. That causes some serious challenges for the IaC principles, because some mighty modules (e.g. Tasklist) can be executed anymore.

This projects provides a basic HTTP Interface (OData v2) based on the the SAP Gateway Framework. This kinda old-fashioned Gateway approach provides a good backwards compatnbility towards older SAP Systems. The service calls the most important function modules to manage and execute ABAP Tasklists.


## Functionality

The first prototype focuses on implementing the **most important ABAP function modules required to create, parameterize, and execute ABAP Task Lists**. These functions are selected based on their usage within the related **SAP Ansible** `sap_task_list_execute` **module**.

<br/>

- <https://docs.ansible.com/projects/ansible/latest/collections/community/sap_libs/sap_task_list_execute_module.html#ansible-collections-community-sap-libs-sap-task-list-execute-module>
- <https://github.com/sap-linuxlab/community.sap_libs/blob/main/plugins/modules/sap_task_list_execute.py>

The project therefore serves as a lightweight HTTP-based interface for interacting with SAP Task Lists and as a foundation for further automation and integration scenarios.

<br/>

### Scope of the Prototype

The initial version focuses on:

- Executing ABAP Task Lists
- Setting and handling Task List parameters
- Implementing the key function modules used by the SAP Ansible module
- Providing a simple HTTP API for external automation tools
- Establishing a foundation for future, more comprehensive coverage of the ABAP Task List API

The implementation is intentionally limited to the **core functionality required for the initial Proof of Concept**. Future versions can extend the API to cover additional Task List API capabilities and more advanced automation scenarios.

### References

- SAP Learning: [Executing ABAP Task Lists for Automated Configuration](<https://learning.sap.com/courses/technical-implementation-and-operation-i-of-sap-s-4hana-and-sap-business-suite/executing-abap-task-lists-for-automated-configuration>)
- SAP Ansible Collection: `community.sap_libs.sap_task_list_execute`
- SAP LinuxLab – `community.sap_libs` GitHub repository
