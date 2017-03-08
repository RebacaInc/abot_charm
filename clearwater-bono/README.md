# Overview

This is a [Juju charm](https://jujucharms.com/about), which allows deployment and scaling of the [Bono](https://github.com/Metaswitch/sprout/#sprout-and-bono) component of a [Project Clearwater](http://projectclearwater.org) IMS core.

Bono should only be deployed alongside the other Project Clearwater charms and a DNS server - see [our main Juju README](https://github.com/Metaswitch/clearwater-juju/blob/local_charms/README.md) for instructions on this, including a bundle that makes this deployment simple.

# Deployment

## Initial deployment

The Bono service should be initially deployed as part of a Clearwater bundle, following the instructions in [our main README](https://github.com/Metaswitch/clearwater-juju/blob/local_charms/README.md).

Note that the clearwater-bono charm can only be deployed on the `amd64` architecture (although the provided bundle already enforces this constraint).

## Scale out Usage

clearwater-bono can be scaled up through the normal Juju mechanism of `juju add-unit clearwater-bono`.

This will create a new Bono instance, and trigger the DNS server charm to add a DNS record for this Bono. (Unlike Sprout, Homestead, Homer and Ralf nodes, Bono nodes don't have a shared datastore, so don't need any cluster configuration.)

# Using Bono

Once installed, Bono will listen for SIP traffic on port 5060 (both TCP and UDP). Once you have created a SIP subscriber through the Ellis UI, you can use a standard SIP client (e.g. Blink, Boghe or X-Lite) to register against Bono's public IP (which you can find with `juju status clearwater-bono`) and make calls.

Our ["Making your first call" documentation](http://clearwater.readthedocs.org/en/latest/Making_your_first_call/index.html) has more information on this process.

# Configuration

-  `zone:` The home domain of this IMS deployment - this could be a real domain that you own, or an internal-only name like "clearwater.local".
-  `repo`: The URL of the Clearwater package repository server. Our latest relese, updated roughly every two weeks, is at http://repo.cw-ngv.com/juju-clearwater-2.
-  `sas`: (optional) The location of a [Metaswitch SAS server](http://www.metaswitch.com/products/management-systems/service-assurance-server) for diagnostics and call flows.
-  `trusted_peers`: (optional) Comma-separated list of IP addresses of trusted peers, for when Bono is used as an IBCF rather than a P-CSCF.

The `zone`, `sas` and `repo` configuration options should be consistent across all Clearwater nodes in the deployment.

# Files downloaded

When the charm is being installed, several files are downloaded:

- Our standard Chef setup scripts, checked out from https://github.com/Metaswitch/chef.
- The Bono Debian packages, from our package repository server at repo.cw-ngv.com.
- Any dependencies of those Debian packages, from the standard Ubuntu repository servers.

# Contact and Upstream Project Information

Project Clearwater is an open-source IMS core, developed by [Metaswitch Networks](http://www.metaswitch.com) and released under the [GNU GPLv3](http://www.projectclearwater.org/download/license/). You can find more information about it on [our website](http://www.projectclearwater.org/) or [our documentation site](https://clearwater.readthedocs.org).

Clearwater source code and issue list can be found at https://github.com/Metaswitch/. Bono's source code can be found at https://github.com/Metaswitch/sprout/.

If you have problems when using Project Clearwater, read [our troubleshooting documentation](http://clearwater.readthedocs.org/en/latest/Troubleshooting_and_Recovery/index.html) for help, or see [our support page](http://clearwater.readthedocs.org/en/latest/Support/index.html) to find out how to ask mailing list questions or raise issues.
