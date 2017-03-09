# Charms Overview

Abot-OAI-EPC bundle deploys abot-epc-basic along-with Oai-hss, Oai-epc and Mysql charms, which support deployment and scaling of OAI charms along with ABot developed by Rebaca.

ABot should typically be deployed alongside the System Under Test (SUT) - such that it can execute tests against the latter. One of the possible SUTs is the OAI EPC, which is an open source initiative of Eurecom.

ABot enables users to create **feature files** based on a **Cucumber** framework. Cucumber is a Behavior Driven Development (BDD) framework, which is used to write tests for different types of applications. It allows automation of functional validation in an easily readable and understandable format (like plain English). It is used to test the system rather than testing the particular piece of code.

The feature files authored by the user(s) can subsequently be used for testing different types of applications/protocols that are running on the System Under Test (SUT). The feature files follow a specified grammar and include instructions that translate into sending messages to the SUT, and receiving back responses using different protocols and verification of the results as defined.

The current protocol drivers (adapters) provided with ABot are SSH, SFTP, HTTP as well as S1AP.  

Each feature file can be associated with one (or more) tags; thereby enabling it to be selectively invoked. **Execution of feature file(s) associated with one (or more) specified tags is driven through a Juju action after deployment of the ABot charm.**

The result of each test execution is displayed in a web-based reporting UI; this is currently accessible on port 80.
 
# Usage

Before deploying this bundle, you should bootstrap a Juju environment, as documented in the https://jujucharms.com/docs/stable/getting-started. The testing of this charm on MAAS cloud is complete, and there are plans to test it on Amazon and OpenStack in the near future. If you get it working on a different cloud service, please let us know!

OAI is a relatively simpler bundle consisting of Mysql, Oai-hss, Oai-epc and Abot-EPC-basic, together forming the SUT for feature file execution. The ABot OAI EPC bundle has been integrated and tested on MAAS cloud. You can find the ABot OAI EPC bundle at [https://jujucharms.com/u/abotcharm/abot-oai-epc-bundle/]. To know more about ABot please visit charmstore (https://jujucharms.com/u/abotcharm/abot-epc-basic/xenial/).

The ABot OAI EPC bundle ties up all the above-mentioned charms and their relations together, allowing the deployment of a full system in a single step.
          
>juju deploy [bundle_name]


# Configuration

See [bundle.yaml](bundle.yaml), which lists the main configuration fields with comments about their meanings.

# Files downloaded

When the above-mentioned charms are being installed, the following files are downloaded from their respected paths:

- The ABot Debian package, from the public package repository server hosted at Rebaca.
- Any dependencies related to Debian packages (particularly Java and Maven), are downloaded from the standard Ubuntu repository servers.
- Any dependency related to OAI charms are downloaded from their respective repositories.

# Test Case Execution

- After deployment of the ABot OAI EPC bundle, the following actions can be quickly executed to verify whether the bundle works fine:
> juju run-action abot-epc-basic/[abot-unit-number] run

- The following script needs to be executed from the Juju controller in order to generate and add the ssh keys to all the ABot OAI EPC bundle units.
> charm pull cs:~abotcharm/xenial/abot-epc-basic
> ./abot-epc-basic/lib/scripts/add-keys.sh

- In order to execute a particular feature file or a set of feature files we need to execute the following commands mentioned below, replacing the tag name mentioned below with the required tag name. Also in the following commands we need to replace the [abot-unit-number] with the current abot-unit-number.
> juju run-action abot-epc-basic/[abot-unit-number] run tagnames=[tag name]

- In order to run EPC attach test case feature file:
> juju run-action abot-epc-basic/8 run tagnames=Attach_Procedure_AttachWithIMSI

- In order to run EPC MAC Failure test case feature file:
> juju run-action abot-epc-basic/8 run tagnames=Auth_NotAccept_by_UE_GUTIattach_MAC_code_failure

- In order to run EPC SQN Failure test case feature file:
> juju run-action abot-epc-basic/8 run tagnames=Auth_NotAccept_by_UE_SQN_failure

- In order to run EPC negative test cases in multiple feature files: 
> juju run-action abot-epc-basic/8 run tagnames=negTCs

- In order to run 3GPP TS 24.301 test cases in multiple feature files:
> juju run-action abot-epc-basic/8 run tagnames=TS_24_301

- The following action will execute all test cases (feature files) for which the tags have been added through the previous command. Please note that the tags can be run from a specified filename as well.
>  juju run-action abot-epc-basic/[abot-unit-number] run tagnames=[feature file name without extension]

- Execute tags from the file titled ***negTCs***. This file includes tags for negative call scenarios; such as *sync failure*, *MAC failure* and so on.
>  juju run-action abot-epc-basic/[abot-unit-number] run tagnames=negTCs

#Adding new Test Cases (Feature Files)

- **New Feature Files should be added into the following folder** on the Juju controller node
>charm pull cs:~abotcharm/trusty/abot-ims-basic
> $PWD/abot-epc-basic/lib/featureFiles
   
- The Juju charm upgrade action should be invoked to propagate these new feature files onto the deployed service node.  
>juju upgrade-charm  --path=$PWD/abot-epc-basic abot-epc-basic

- Once the upgrade is successful, the test case execution steps can be followed to execute one or more feature files.

# Viewing Test Report

- The report UI can then be viewed by accessing the below mentioned URL.
    http://[abot-ip]/app
    E.g.: http://192.168.15.87/app/

- This pulls up the Cucumber report of the latest execution.
- Accessing any of the feature files present in the report shows the step-wise execution status for that feature file.
