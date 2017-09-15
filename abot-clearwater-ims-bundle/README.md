# Overview

Abot-Clearwater-ims bundle deploys abot-ims-basic along with Clearwater IMS solution, which supports deployment and testing of a [Project Clearwater](http://www.projectclearwater.org) IMS core using the Test Orchestration solution ABOT developed by Rebaca.

# Usage

Before deploying this bundle, you should bootstrap a Juju environment, as documented in the https://jujucharms.com/docs/stable/getting-started. The testing of this bundle on MAAS as well as OpenStack is complete. If you get it working on a different cloud service, please let us know!

Clearwater is a reasonably complex system (especially compared to typical beginner Juju examples like Wordpress + MySQL) - deploying a Clearwater IMS core involves deploying and configuring six or seven charms, and adding relations between them.  You can find the Clearwater IMS bundle at [https://github.com/Metaswitch/clearwater-juju.git]. 
To know more about ABOT please visit charmstore (https://jujucharms.com/u/abotcharm/abot-ims-basic/trusty).

We have now created a Juju bundle that will tie all these charms and their relations together, allowing the deployment of a full system in a single step.
          
>juju deploy [bundle_name]

Please wait for all the associated charms to be readiy by issuing the following command
>watch juju status 


# Configuration

See [bundle.yaml](bundle.yaml), which lists the main configuration fields with comments about their meanings.

# Testing

To test the Clearwater IMS setup using ABOT run the following actions from Juju client(once all the charms are in ready state).

####Configure ABOT to run IMS in Cache mode:
 
>juju run-action [abot-ims-basic unit name] configure-cx-client auth-type=cache
 
####Add user: 

>juju run-action [abot-ims-basic unit name] run tagnames=ims-user-add
 
####Run a generic single test:

>juju run-action [abot-ims-basic unit name] run tagnames=sip-register

####Run a generic test suite:

>juju run-action [abot-ims-basic unit name] run tagnames=sip-tests
     

#Running a benchmark
List of benchmarks available at any time by executing juju run-action <abot-ims-basic-unit> benchmark. To run benchmark action execute the following command from juju client.

##Run benchmark action with default parameter. 
  
>juju run-action [abot-ims-basic-unit-name] benchmark
    
##Run benchmark action with configurable parameters

There are some configurable parameter in benchmark action, which are number of calls (num-calls), call rate per second (call-rate), sip scenario (sip-scenario) and max call duration in minutes (timeout-in-minutes). Currently number of calls is limited to 10000 and calls per second is limited to 500. 
Benchmark action supports two sip scenarios, sip register and sip invite. 

Default values are as follows:

-  `number of calls(num-calls)`:1000
-  `calls per second(call-rate)`:5
-  `sip scenario(sip-scenario)`:register
-  `max call duration in minutes(timeout-in-minutes)`:10 minutes.
**The timeout-in-minutes value is not expected to be specified as in most of the cases it is expected that the calls will get over within 10 minutes.**

Command to execute benchmark action with 500 number of calls and 50 calls per second, sip register as sip scenario.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=500 call-rate=50 sip-scenario=register

Command to execute benchmark action with 500 number of calls and 50 calls per second, sip invite as sip scenario.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=500 call-rate=50 sip-scenario=invite
  
Command to execute benchmark action with 1000 number of calls and 100 calls per second, sip register as sip scenario.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=1000 call-rate=100
  
Command to execute benchmark action with 2000 number of calls and 200 calls per second, sip register as sip scenario.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=2000 call-rate=200
  
Command to execute benchmark action with 5000 number of calls and 500 calls per second, sip register as sip scenario.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=5000 call-rate=500

Command to execute benchmark action with 5000 number of calls and 50 calls per second, sip invite as sip scenario, for a max call duration of 15 minutes.

>juju run-action [abot-ims-basic-unit-name] benchmark num-calls=5000 call-rate=50 sip-scenario=invite timeout-in-minutes=15

# Contact and Upstream Project Information

Project Clearwater is an open-source IMS core, developed by [Metaswitch Networks](http://www.metaswitch.com) and released under the [GNU GPLv3](http://www.projectclearwater.org/download/license/). You can find more information about it on [our website](http://www.projectclearwater.org/) or [our documentation site](https://clearwater.readthedocs.org).

Clearwater source code and issue trackers is present at https://github.com/Metaswitch/.

If you have problems when using Project Clearwater, read [our troubleshooting documentation](http://clearwater.readthedocs.org/en/latest/Troubleshooting_and_Recovery/index.html) for help, or see [our support page](http://clearwater.readthedocs.org/en/latest/Support/index.html) to find out how to ask mailing list questions or raise issues.

Abot-ims-basic is a Test Automation Framework for network services that uses the behavior-oriented testing model. 
This enables users to define test cases as feature files based on a domain-specific language. These feature files could subsequently be executed in automated manner on multiple environments. To reach us please visit https://www.rebaca.com/contact-us.

