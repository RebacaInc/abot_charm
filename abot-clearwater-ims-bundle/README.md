# Overview

Abot-Clearwater-ims bundle deploys abot-ims-basic along-with Clearwater IMS solution, which support deployment and scaling of a [Project Clearwater](http://www.projectclearwater.org) IMS core along with ABOT developed by Rebaca.

# Usage

Before deploying this charm, you should bootstrap a Juju environment, as documented in the https://jujucharms.com/docs/stable/getting-started. The testing of this charm on MAAS cloud is complete, and there are plans to test it on Amazon and OpenStack in the near future. If you get it working on a different cloud service, please let us know!

Clearwater is a reasonably complex system (especially compared to typical beginner Juju examples like Wordpress + MySQL) - deploying a Clearwater IMS core involves deploying and configuring six or seven charms, and adding relations between them.  Clearwater ABOT has been integrated and tested on MAAS cloud. You can find the Clearwater IMS bundle at [https://github.com/Metaswitch/clearwater-juju.git]. To know more about ABOT please visit charmstore (https://jujucharms.com/u/abotcharm/abot-ims-basic/trusty).

We have now created a Juju bundle that will tie all these charms and their relations together, allowing the deployment of a full system in a single step.
          
>juju deploy [bundle_name]


# Configuration

See [bundle.yaml](bundle.yaml), which lists the main configuration fields with comments about their meanings.

# Testing

To test the Clearwater IMS setup using ABOT run the following action from Juju client.
Download abot-ims-basic charm locally [ cs:~abotcharm/trusty/abot-ims-basic ]  and circulate SSH key of abot-ims-basic into all Clearwater unit.

####Circulate SSH key of abot-ims-basic into all Clearwater unit
>charm pull cs:~abotcharm/trusty/abot-ims-basic
>./abot-ims-basic/lib/scripts/add-keys.sh

####Configure ABOT to run IMS in Cache mode [To run SIP only tests]:
 
>juju run-action [abot-ims-basic unit name] configure-hss-client auth-type=cache
 
####Add user: 

>juju run-action [abot-ims-basic unit name] run tagnames=ims-user-add
 
####Run a generic single test [SIP only]:

>juju run-action [abot-ims-basic unit name] run tagnames=sip-register

####Run a generic test suite [SIP only]:

>juju run-action [abot-ims-basic unit name] run tagnames=sip-tests
     
####Configure ABOT to run IMS in HSS mode [To run Diameter and SIP tests]:       

>juju run-action [abot-ims-basic unit name] configure-hss-client auth-type=hss

####Run a single IMS test feature file [Diameter and SIP]:

>juju run-action [abot-ims-basic unit name] run tagnames= Initial_Registration_UE_With_ISIM_SIP_Digest_24_229_5_1_1_2_1

####Run a test suite based on 3gpp clause based testing [Diameter and SIP]:

>juju run-action [abot-ims-basic unit name] run tagnames=TS_24_229

#Running a benchmark
List of benchmarks available at any time by executing juju run-action <abot-ims-basic-unit> benchmark. To run benchmark action execute the following command from juju client.

###Configure ABOT to run IMS in Cache mode [To run SIP only tests]:

>juju run-action [abot-ims-basic unit name] configure-hss-client auth-type=cache
    
###Run benchmark action with default parameter. 
  
>juju run-action [abot-ims-basic-unit-name] benchmark
    
###Run benchmark action with configurable parameters

There are some configurable parameter in benchmark action, which are number of calls (num-calls), call rate per second (call-rate), sip scenario (sip-scenario) and max call duration in minutes (timeout-in-minutes). Currently number of calls is limited to 10000 and calls per second is limited to 500. 
Benchmark action supports two sip scenarios, sip register and sip invite. 
Default values of number of calls (num-calls) is 1000, calls per second (call-rate) is 5, sip scenario (sip scenario) is register, and max call duration in minutes (timeout-in-minutes) is 10 minutes.
The timeout-in-minutes value is not expected to be specified as in most of the cases it is expected that the calls will get over within 10 minutes

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

