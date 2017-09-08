# Charms Overview

This is a [Juju charm](https://jujucharms.com/about), which allows deployment of the Rebaca Automation Behaviour-oriented Testing Framework(ABOT).

ABOT should typically be deployed alongside the System Under Test(SUT) - such that it can execute tests against the latter. One of the possible SUTs is the ClearWater IMS developed by Metaswitch.

ABOT enables users to create **feature files** based on **Cucumber** framework. Cucumber is a Behavior Driven Development (BDD) framework which is used to write tests for different types of applications. It allows automation of functional validation in easily readable and understandable format (like plain English). It is used to test the system rather than testing the particular piece of code.

The feature files authored by user(s) can subsequently be used for testing different types of applications/protocols that are running on the System Under Test(SUT). The feature files follows a specified grammar and includes instructions that translate into sending messages to the SUT and receiving back responses using different protocols and verification of the results as defined.

The current protocol drivers(adapters) provided with Abot are SSH, SFTP, HTTP as well as SIP.  As such, it should be possible to execute tests on any SUT that supports the above protocols. 

In the absence of an SUT, it is also possible to write feature files for executing local commands on the deployed unit and validating the return values. 

Each feature file can be associated with one(or more) tags; thereby enabling it to be selectively invoked. **Execution of feature file(s) associated with one(or more) specified tags is driven through a Juju action after deployment of the Abot charm.**

The result of each test execution is displayed in a web-based reporting UI; which is currently accessible on port 80.
 

## Deployment

# Initial deployment

The Abot service should be deployed as a standalone charm on a single unit; typically after the deployment of the System Under Test(SUT).

As such, assuming that the SUT is the Clearwater IMS( https://github.com/thomnico/juju-nfv-clearwater-restcomm/tree/trusty), the Abot charm should be deployed after the deployment of the Clearwater IMS bundle, following the instructions provided in the ClearWater github repository.

The typical command for deploying Abot is as follows:


> juju deploy cs:~abotcharm/trusty/abot-ims-basic

Subsequently, it needs to be exposed using the following command.

> juju expose abot-ims-basic

## Adding Relations with ClearWater IMS charms

The following relations should be added if the ClearWater IMS bundle is also installed in the setup.
> juju add-relation abot-ims-basic dns
> juju add-relation abot-ims-basic clearwater-bono
> juju add-relation abot-ims-basic:hss-prov clearwater-homestead:homestead-prov-user
> juju add-relation clearwater-homestead:hss abot-ims-basic:hss-abot


# Using Abot

Once installed, Abot comes with a set of feature files that can be run against an existing Clearwater IMS setup(if it exists); after setting a few configuration parameters. 


# Configuration

These parameters are specific to the IMS Test System; and do not need to be specified if we are not validating an IMS.

-  `sip_server`: SIP proxy server FQDN of the IMS Test System. An example value would be bono.clearwater.local. **This is automatically set once the relation with ClearWater bono(SIP proxy server) is invoked.**
-  `sip_domain`: SIP domain associated with the IMS Test System. An example value would be clearwater.local. **This is automatically set once the relation with ClearWater bono(SIP proxy server) is invoked.**
-  `ims_hss_mirror_ip`: The IP address of the HSS Mirror of the IMS Test System. **This is automatically set once the relation with ClearWater Homestead is invoked.**
-  `ims_cscf_ip`: The IP address of the P-CSCF.component of the IMS Test System. In the context of Clearwater IMS, this is the IP address of the node running clearwater-bono service. **This is automatically set once the relation with ClearWater bono(SIP proxy server) is invoked.**
-  `clearwater_sipp_ip`: (optional) The IP address of the SIPP component of the IMS Test System(if any). In the context of Clearwater IMS, this is the IP address of the node running clearwater-sipp service.

# Files downloaded

When the charm is being installed, several files are downloaded:

- The ABOT Debian package, from our public package repository server hosted at Rebaca.
- Any dependencies of those Debian packages (particularly Java and Maven), from the standard Ubuntu repository servers.

# Test Case Execution

 - After deployment of Abot charm, the following actions can be quickly executed to verify whether the charm works fine.
> juju action do  abot-ims-basic/[abot-unit-number] run

 - The report UI can then be viewed by clicking on the link that appears under the specific unit of the service in the Juju GUI
 


- The following action(s) will add new tags for subsequent execution. Pls. note that the unit number below should be replaced with the proper value from the given deployment. Also, pls. note that the tag-names specified below are sample ones and should be replaced by the actual tags associated with newly authored feature files.
  
> juju run-action abot-ims-basic/[abot-unit-number] configure-cx-client auth-type=cache
> juju run-action abot-ims-basic/[abot-unit-number] add-tags tagnames=sip-single-call
> juju run-action  abot-ims-basic/[abot-unit-number] add-tags tagnames=sip-subscribe-notify,sip-messaging

- Pls. note that the new tags may also be added to specific filenames; for future retrieval. 
> juju run-action  abot-ims-basic/[abot-unit-number] add-tags tagnames=sip-register,sip-ssh-test,ims-user-add,sip-single-call,sip-multi-call,sip-unregister   filename=normal_cases
> juju run-action  abot-ims-basic/[abot-unit-number] add-tags tagnames=sip-call-busy,sip-call-no-answer,sip-call-reject,sip-call-unavailable,sip-call-cancel,sip-malformed_request,sip-invalid-register,sip-single-call-error  filename=negative_cases


- The following action will execute all test cases(feature files) for which the tags have been added through the previous command. Pls. note that the tags can be run from a specified filename as well.

>  juju run-action abot-ims-basic/[abot-unit-number] run

- Execute tags from the file titled ***normal_cases***. This file includes tags for normal/successful call scenarios.
>  juju run-action abot-ims-basic/[abot-unit-number] run filename=normal_cases

- Execute tags from the file titled ***normal_cases***. This file includes tags for normal/successful call scenarios.
>  juju run-action   abot-ims-basic/[abot-unit-number] run filename=normal_cases

- Execute tags from the file titled ***negative_cases***. This file includes tags for negative call scenarios; such as *user busy*, *no answer*, *cancel* and so on.
>  juju action do  abot/[abot-unit-number] run filename=negative_cases

# Adding new Test Cases(Feature Files)

- **New Feature Files should be added into the following folder** on the Juju controller node
   ~/charms/trusty/abot/lib/featureFiles
   
- The Juju charm upgrade action should be invoked to propagate these new feature files onto the deployed service node.
  

> juju upgrade-charm  abot-ims-absic

- Once the upgrade is successful, the test case execution steps can be followed to execute one or more feature files.

# Viewing Test Report

- Login to the Juju GUI and select Abot service
- Select the specific unit of the service and click on the link.
- Click of the test report link that appears under the IP Address header for the given Abot unit.
- This should show up the Cucumber report of the last executed test.
