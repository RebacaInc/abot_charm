#!/bin/bash

#Run the oaisim service
/bin/sh -c '/srv/openair5G/cmake_targets/tools/run_enb_ue_virt_s1 -c /srv/openair5G/targets/PROJECTS/GENERIC-LTE-EPC/CONF/enb.band7.generic.conf -K /tmp/enb_ue_virt_s1_itti.log > /srv/.out 2> /srv/.err' &
