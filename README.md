# Testing DC/OS EE autoscaler for Marathon apps

One small edit need to be performed to use this rest based test of the Autoscaler.

### DC/OS Configuration:

* Log into the cluster with the DC/OS CLI
* Make sure the Autoscaler service account has been set-up, by running:
	``` bash
 	  ./create-service-account.sh scaler myapp
 	```
* The autoscaler must be deployed: 
	``` bash
	  dcos marathon app add marathon-autoscaler.json
 	```
* Deploy Marathon-LB: 
	``` bash
	  dcos package install marathon-lb
 	```
* Verify that the autoscaler and marathon-lb are running: 
	``` bash
	  dcos marathon task list
 	```

### Edit the ./test/node.json file

Go to line 63 and change <Your Public Agent IP> to the IP address of your public agent (an example is below):
``` bash
     "HAPROXY_0_VHOST": "52.21.123.115",
```

### Run the test script

``` bash
     ./node_scale.sh
```
### Loading the REST Endpoint in DC/OS using Apache Bench

Assuming you are using CentOS, install ab using: 
``` bash
     yum install httpd-tools
```
### Loading the Autoscaler

You can hit the REST endpoint outside of the cluster or internally and or externally.  Simulate internal load
as microservice calling each other.  External traffic is best simulated from different AWS Regions to simulate
your users in varying regions of the country or world.

Internal
``` bash
ab -t 360 -k -n 10000 -r  node.marathon.l4lb.thisdcos.directory:8080/hello
```

External
``` bash
  ab -t 3600 -n 100000 -c 200   http://52.21.123.115/api/hello
```
Note:  This is a very simple API that only reports the Environment. Use this as a model, but it is best to use an application from your environment.

Closing Comments, this is a time investment.  Expect to experiment, both with the autoscaler, and understandoing your app under load.  This is why in my blog
post I suggest approaching this as a team - Ops, Developer, QA, and Business Stakeholder to arrive at the optimal performance in your cluster.
