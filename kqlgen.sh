
# vars
RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
SCRIPT_NAME="$(echo $0 | sed 's|\.\/||g')"
CDATE=$(date +"%Y-%m-%d")
C3DATE=$(date -d -3days +"%Y-%m-%d")
CTIME=$(date -u +"%H:%M")


seq 2 | xargs -Iz echo "--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--"
echo "*************GENERATE KUSTO QUERIES*************"
seq 2 | xargs -Iz echo "--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--"
echo -e "\n\nSTEP:1) PLEASE SELECT THE VALUE OF THE RESOURCE TYPE"
echo -e "\na) AKS \nb) ACR \nc) ACI \nd) ARO"
echo "************"
read -p "$(echo -e $BOLD$YELLOW"Type of resource : "$RESET)" RESOURCETYPE
echo "************"
seq 1 | xargs -Iz echo "--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--"
echo -e "\n\nSTEP:2) PLEASE SELECT THE TIMELINETYPE TYPE"
echo -e "\na) Days Ago (default is 3 days) \nb) Time_between (default is ${CDATE}T${CTIME}Z - ${C3DATE}T${CTIME}Z) \nc) Manual Entry"
echo "************"
read -p "$(echo -e $BOLD$YELLOW"Type of Timeline : "$RESET)" TIMELINETYPE
echo "************"
if [[ "$TIMELINETYPE" = "b" ]]
then
		echo "Time between (datetime(${CDATE}T${CTIME}Z)..datetime(${C3DATE}T${CTIME}Z))"
			TIMEVALUE="between (datetime(${CDATE}T${CTIME}Z)..datetime(${C3DATE}T${CTIME}Z))"
elif [[ "$TIMELINETYPE" = "c" ]]
then
echo -e "\nPlease enter the time value in either of the below mentioned syntax formats"
echo -e "\n'>= ago(9d)' OR  'between (datetime(2022-06-16)..datetime(2022-06-17))'\n"
echo "************"
read -p "$(echo -e $BOLD$YELLOW"ENTER TIME VALUE: "$RESET)" TIMEVALUE
echo "************"
else 
		echo "3 days Ago" 
		TIMEVALUE=">= ago(3d)"
fi
seq 1 | xargs -Iz echo "--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--"
echo -e "\n\nSTEP:3) PLEASE ENTER THE RESOURCE URI"
echo "************"
read -p "$(echo -e $BOLD$YELLOW"RESOURCE URI : "$RESET)" RESOURCEURI
echo "************"
seq 1 | xargs -Iz echo "--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--"
if [[ "$RESOURCETYPE" = "a" ]]
then
	# URI validation
	URI_STRING=$RESOURCEURI
	SLASH_COUNT=$(echo $URI_STRING | tr -dc "/" | wc -m)
	
	if [ $SLASH_COUNT != 8 ]; then
		echo -e "\nError: cluster URI does not have the expected format...\n"
		echo -e "Usage: bash ${SCRIPT_PATH}/${SCRIPT_NAME} <AKS_CLUSTER_URI>\n"
		exit 1
	fi
	mkdir -p ${SCRIPT_PATH}/kusto-queries/AKS 2> /dev/null
	# Extracting info from URI
	SUBSCRIPTION_ID=$(echo $URI_STRING | awk -F'/' '{print $3}')
	RESOURCEGROUP_NAME=$(echo $URI_STRING | awk -F'/' '{print $5}')
	RESOURCE_NAME=$(echo $URI_STRING | awk -F'/' '{print $NF}')
	echo "************"
	echo "Saving AKS KUSTO Queries"
	echo "************"
printf "\n//******INDEX*******
//--AKSPROD-DB QUERIES
//--/--1.QUICK ERROR INSIGHTS 
//--/--2.SCALING UPGRADE PROBLEMS
//--/--3.BLACKBOX MONITORING RELATED QUERIES.
//--/--4.REMEDIATOR EVENTS
//--/--5.CONTROL PLANE EVENTS
//--ARMPROD-DB QUERIES
//--/--1. Who did something?
//--/--2. Find Errors reported by ARM Failed - Deleted - Created
//--AZCRP-DB QUERIES
//--/--1. CRP Kusto Queries



//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//*******************************************************
// AKSPROD-DB QUERIES
//*******************************************************
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//1. QUICK ERROR INSIGHTS (These queries are very useful for identifying issues with scaling or upgrades.)
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
// This helps to see ALL the errors/messages for the AKS clusters in the resource group
//*******************************************************
union cluster(\"Aks\").database(\"AKSprod\").FrontEndContextActivity, cluster(\"Aks\").database(\"AKSprod\").AsyncContextActivity
| where subscriptionID has \"$SUBSCRIPTION_ID\"
| where resourceName has \"$RESOURCE_NAME\"
| where level != \"info\"
| where PreciseTimeStamp $TIMEVALUE
| project PreciseTimeStamp, operationID, correlationID, level, suboperationName, msg


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//2. SCALING UPGRADE PROBLEMS (These queries are very useful for identifying issues with scaling or upgrades.)
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
// This helps to see the recent scale/upgrade operations
//*******************************************************
union cluster(\"Aks\").database(\"AKSprod\").FrontEndContextActivity, cluster(\"Aks\").database(\"AKSprod\").AsyncContextActivity
| where subscriptionID contains \"$SUBSCRIPTION_ID\"
| where resourceName contains \"$RESOURCE_NAME\"
| where msg contains \"intent\" or msg contains \"Upgrading\" or msg contains \"Successfully upgraded cluster\" or msg contains \"Operation succeeded\" or msg contains \"validateAndUpdateOrchestratorProfile\" 
// or msg contains \"unique pods in running state\"
| where PreciseTimeStamp $TIMEVALUE
| project PreciseTimeStamp, operationID, correlationID, msg

//*******************************************************
// Shows the scale errors/messages for an AKS cluster using the operationID from the previous query
//*******************************************************
union cluster(\"Aks\").database(\"AKSprod\").FrontEndContextActivity, cluster(\"Aks\").database(\"AKSprod\").AsyncContextActivity
| where operationID == \"11533014-c401-46e9-9d59-c0a98f341800\"
// | where level != \"info\"
| project PreciseTimeStamp, level, msg


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//3. BLACKBOX MONITORING RELATED QUERIES. (Black-box monitoring tests externally visible application behavior without knowledge of the internals of the system. This type of monitoring is a common approach to measuring customer-centric SLIs, SLOs, and SLAs.)
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
//Get FQDN of the AKS cluster (This query is useful if ASC isn't responding or throwing errors on the ManagedCluster resource as some queries are dependent on the FQDN and we can use the below query to get the FQDN)
//*******************************************************
cluster(\"aks\").database(\"AKSprod\").BlackboxMonitoringActivity
| where subscriptionID == \"$SUBSCRIPTION_ID\" and resourceGroupName contains \"$RESOURCE_NAME\"
| where PreciseTimeStamp $TIMEVALUE
| summarize by fqdn, resourceGroupName, resourceName, underlayName

//*******************************************************
//Cluster Health (The below query requires that you add in your FQDN from above. It then returns many useful pieces of information from Black Box Monitoring.)
//*******************************************************
cluster(\"aks\").database(\"AKSprod\").BlackboxMonitoringActivity
| where fqdn == \"replacefqdn\"
| where ([\"state\"] != \"Healthy\" or podsState != \"Healthy\" or resourceState != \"Healthy\" or addonPodsState != \"Healthy\")
| where PreciseTimeStamp $TIMEVALUE
| project fqdn, PreciseTimeStamp, agentNodeName, state, reason, podsState, resourceState, addonPodsState, agentNodeCount, provisioningState, msg, resourceGroupName, resourceName, underlayName  
// | order by PreciseTimeStamp asc
// | render timepivot by fqdn, reason, agentNodeName, addonPodsState
| render timepivot by fqdn, agentNodeName, addonPodsState, reason  
// | summarize count() by reason 
// | sort by reason

//*******************************************************
//Problems with Underlay (This is a useful query for understanding the Underlay Health.)
//*******************************************************
cluster(\"aks\").database(\"AKSprod\").BlackboxMonitoringActivity
| where PreciseTimeStamp $TIMEVALUE and underlayName == \"hcp-underlay-canadacentral-c1\"
| where reason != \"\"
| summarize count() by reason | top 10 by count_ desc


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//4. REMEDIATOR EVENTS
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
//This can help to check any Remediator Events. 
//*******************************************************
cluster(\'Aks\').database(\'AKSprod\').RemediatorEvent 
| where PreciseTimeStamp $TIMEVALUE
| where subscriptionID == \"$SUBSCRIPTION_ID\"
//| where msg contains \"begin\"
| project PreciseTimeStamp, reason, msg, ccpNamespace


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//5. CONTROL PLANE EVENTS
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
//This can help to check the cluster autoscaler operations.
//*******************************************************
union cluster(\"Aks\").database(\"AKSccplogs\").ControlPlaneEvents, cluster(\"Aks\").database(\"AKSccplogs\").ControlPlaneEventsNonShoebox
| where TIMESTAMP $TIMEVALUE
| where namespace == \"insertnamespace\" // get it from ETCD logs in jarvis
| where category contains \"cluster-autoscaler\"
| project PreciseTimeStamp, category, log=tostring(parse_json(properties).log)

//*******************************************************
// Kube api audit logs
//*******************************************************
union cluster(\'Aks\').database(\'AKSccplogs\').ControlPlaneEvents, cluster(\'Aks\').database(\'AKSccplogs\').ControlPlaneEventsNonShoebox
//| where PreciseTimeStamp $TIMEVALUE
| where PreciseTimeStamp $TIMEVALUE
| where resourceId has \"$SUBSCRIPTION_ID\" and resourceId has \"$RESOURCE_NAME\"
| where category == 'kube-audit'
| extend Pod = extractjson('$.pod', properties, typeof(string))
| extend Log = extractjson('$.log', properties , typeof(string))
| extend _jlog = parse_json(Log)
| extend requestURI = tostring(_jlog.requestURI)
| extend verb = tostring(_jlog.verb)
| extend user = tostring(_jlog.user.username)
// | where verb !in ('get', 'list', 'watch')
//| where properties contains '/pods/'
//| where properties has '<NAME_OF _THE_POD>'
| mv-expand podCond = _jlog.requestObject.status.conditions | extend ownerType = tostring(_jlog.requestObject.metadata.ownerReferences[0].kind) | extend ownerName =tostring(_jlog.requestObject.metadata.ownerReferences[0].name) | extend podCondType = tostring(podCond.type)
| extend podCondStatus = tostring(podCond.status) | extend podCondReason = tostring(podCond.reason)
| extend podCondMessage = tostring(podCond.message)
| project PreciseTimeStamp, requestURI, verb, user, podCondType, podCondStatus, podCondReason, podCondMessage, Log
// | render timeline 

//*******************************************************
//check PDB blocking operations
//*******************************************************
union cluster(\'Aks\').database(\'AKSccplogs\').ControlPlaneEvents, cluster('Aks').database('AKSccplogs').ControlPlaneEventsNonShoebox
| where namespace == \"5e8506c84ec02c0001b3881e\"
| where TIMESTAMP $TIMEVALUE
| extend p = todynamic(properties)
| where p.log has \"Cannot evict pod as it would violate the pod's disruption budget\"
| project PreciseTimeStamp, p.log
| extend namespace=parsejson(tostring(p_log))
| project namespace.objectRef.namespace, p_log
| limit 10
//| summarize count() by tostring(namespace_objectRef_namespace)

//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//*******************************************************
// ARMPROD-DB QUERIES
//*******************************************************
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//1. Who did something? (Many times we are asked who performed an action on a cluster. Was it Microsoft? Was it the customer? Use the below query to find out:)
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
// claims name shows WHO requested or performed the action
//*******************************************************
cluster(\"ARMProd\").database(\"ARMProd\").EventServiceEntries 
| where subscriptionId == \"$SUBSCRIPTION_ID\"
| where resourceUri contains \"$RESOURCE_NAME\"
// | where claims contains \"1d78a85d-813d-46f0-b496-dd72f50a3ec0\"
// | where ActivityId == \"3817a3d4-7045-4db5-bc7f-45dbffe2166a\"
| where operationName contains \"delete\"
// | where TIMESTAMP $TIMEVALUE 
// | where claims contains \"baead28c-2ce7-4550-83a5-5e6a2deb02b8\"
// | where status == \"Failed\" 
| project PreciseTimeStamp, claims, authorization, properties, resourceUri, operationName //, httpRequest, correlationId, operationId, Deployment, operationName
// | project PreciseTimeStamp, resourceUri  , issuer, issuedAt


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//2. Find Errors reported by ARM Failed - Deleted - Created (Get the serviceRequestID for tracing in CRP tables)
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
// Find Errors reported by ARM Failed - Deleted - Created (Get the serviceRequestID for tracing in CRP tables)
//*******************************************************
cluster(\"ARMProd\").database(\"ARMProd\").EventServiceEntries 
| where subscriptionId == \"$SUBSCRIPTION_ID\"
| where resourceUri contains \"$RESOURCE_NAME\"
| where TIMESTAMP $TIMEVALUE
| where status == \"Failed\" 
| project PreciseTimeStamp, correlationId , operationId, operationName, properties



//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//*******************************************************
// AZCRP-DB QUERIES
//*******************************************************
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--


//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//1. CRP Kusto Queries
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
//  Use the activityID from the previous query. 
//*******************************************************
cluster(\"Azcrp\").database(\"crp_allprod\").ContextActivity 
| where subscriptionId == \"$SUBSCRIPTION_ID\"
| where activityId == \"5695c14a-84f9-46e3-bf90-79b263e073d4\" 
// | where message contains \"$RESOURCE_NAME\"
// | where PreciseTimeStamp $TIMEVALUE
| project PreciseTimeStamp, activityId, traceLevel, message\n"> ${SCRIPT_PATH}/kusto-queries/AKS/MC_${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql

printf "\nKusto queries for the cluster have been save in:\n\t${SCRIPT_PATH}/aks-kusto-queries/MC_${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
\nIf you are using Windows subsystem layer you can get to that path from %%userprofile%%\\AppData\\Local\\Packages and look for the distribution folder
\texample for Ubuntu: CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\n
\nThen look for \"LocalState - rootfs\"
format C:\\\Users\\NAME\\AppData\\Local\\Packages\\DISTRO_FOLDER\\LocalState\\\rootfs\n\n"

elif [ "$RESOURCETYPE" = "b"  ]
then
	# URI validation
	URI_STRING=$RESOURCEURI
	SLASH_COUNT=$(echo $URI_STRING | tr -dc "/" | wc -m)
	if [ $SLASH_COUNT != 8 ]; then
		echo -e "\nError: Resource URI does not have the expected format...\n"
		echo -e "Usage: bash ${SCRIPT_PATH}/${SCRIPT_NAME} <ACR_REGISTRY_URI>\n"
		exit 1
	fi
	
	mkdir -p ${SCRIPT_PATH}/kusto-queries/ACR 2> /dev/null
	
	# Extracting info from URI
	SUBSCRIPTION_ID=$(echo $URI_STRING | awk -F'/' '{print $3}')
	RESOURCEGROUP_NAME=$(echo $URI_STRING | awk -F'/' '{print $5}')
	RESOURCE_NAME=$(echo $URI_STRING | awk -F'/' '{print $NF}')
	echo "************"
	echo "Saving ACR KUSTO Queries"
	echo "************"
	printf "\n//For incoming requests to build service
	BuildServiceHttpIncomingRequest
	| where PreciseTimeStamp $TIMEVALUE
	| where Tenant == "centralus"
	//Below is the registry name
	| where RequestUri has "mlopsdevws096cc503"
	| sort by PreciseTimeStamp asc
	//For incoming builds - cj1 was the name
	BuildServiceIncomingEvent
	| where PreciseTimeStamp $TIMEVALUE
	| where Tenant == "centralus"
	| where EventId startswith "mlopsdevws096cc503.azurecr.io_cj1"

	//Registry info, including create time - ASC not working
	RegistryMasterData
	| where env_time  $TIMEVALUE
	| where RegistryName == "mlopsdevws096cc503"\n"> ${SCRIPT_PATH}/kusto-queries/ACR/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
printf "\nKusto queries for the cluster have been save in:\n\t${SCRIPT_PATH}/aks-kusto-queries/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
\nIf you are using Windows subsystem layer you can get to that path from %%userprofile%%\\AppData\\Local\\Packages and look for the distribution folder
\texample for Ubuntu: CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\n
\nThen look for \"LocalState - rootfs\"
format C:\\\Users\\NAME\\AppData\\Local\\Packages\\DISTRO_FOLDER\\LocalState\\\rootfs\n\n"

elif [ "$RESOURCETYPE" = "c" ]
then
	# URI validation
	URI_STRING=$RESOURCEURI
	SLASH_COUNT=$(echo $URI_STRING | tr -dc "/" | wc -m)
	if [ $SLASH_COUNT != 8 ]; then
		echo -e "\nError: Resource URI does not have the expected format...\n"
		echo -e "Usage: bash ${SCRIPT_PATH}/${SCRIPT_NAME} <ACI_REGISTRY_URI>\n"
		exit 1
	fi
	
	mkdir -p ${SCRIPT_PATH}/kusto-queries/ACI 2> /dev/null
	
	# Extracting info from URI
	SUBSCRIPTION_ID=$(echo $URI_STRING | awk -F'/' '{print $3}')
	RESOURCEGROUP_NAME=$(echo $URI_STRING | awk -F'/' '{print $5}')
	RESOURCE_NAME=$(echo $URI_STRING | awk -F'/' '{print $NF}')
	echo "************"
	echo "Saving ACI KUSTO Queries"
	echo "************"
	printf "\n//For incoming requests to build service
	BuildServiceHttpIncomingRequest
	| where PreciseTimeStamp $TIMEVALUE
	| where Tenant == "centralus"
	//Below is the registry name
	| where RequestUri has "mlopsdevws096cc503"
	| sort by PreciseTimeStamp asc
	//For incoming builds - cj1 was the name
	BuildServiceIncomingEvent
	| where PreciseTimeStamp $TIMEVALUE
	| where Tenant == "centralus"
	| where EventId startswith "mlopsdevws096cc503.azurecr.io_cj1"

	//Registry info, including create time - ASC not working
	RegistryMasterData
	| where env_time  $TIMEVALUE
	| where RegistryName == "mlopsdevws096cc503"\n"> ${SCRIPT_PATH}/kusto-queries/ACI/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
printf "\nKusto queries for the cluster have been save in:\n\t${SCRIPT_PATH}/aks-kusto-queries/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
\nIf you are using Windows subsystem layer you can get to that path from %%userprofile%%\\AppData\\Local\\Packages and look for the distribution folder
\texample for Ubuntu: CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\n
\nThen look for \"LocalState - rootfs\"
format C:\\\Users\\NAME\\AppData\\Local\\Packages\\DISTRO_FOLDER\\LocalState\\\rootfs\n\n"

elif [ "$RESOURCETYPE" = "d" ]
then
	# URI validation
	URI_STRING=$RESOURCEURI
	SLASH_COUNT=$(echo $URI_STRING | tr -dc "/" | wc -m)
	if [ $SLASH_COUNT != 8 ]; then
		echo -e "\nError: Resource URI does not have the expected format...\n"
		echo -e "Usage: bash ${SCRIPT_PATH}/${SCRIPT_NAME} <ACI_REGISTRY_URI>\n"
		exit 1
	fi
	
	mkdir -p ${SCRIPT_PATH}/kusto-queries/ARO 2> /dev/null
	
	# Extracting info from URI
	SUBSCRIPTION_ID=$(echo $URI_STRING | awk -F'/' '{print $3}')
	RESOURCEGROUP_NAME=$(echo $URI_STRING | awk -F'/' '{print $5}')
	RESOURCE_NAME=$(echo $URI_STRING | awk -F'/' '{print $NF}')
	echo "************"
	echo "Saving ARO KUSTO Queries"
	echo "************"
	printf "\n//******INDEX*******

//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//*******************************************************
// AROUSA-DB QUERIES
//*******************************************************
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--
//1. QUICK ERROR INSIGHTS
//--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--/--

//*******************************************************
// List all clusters with logs available
//*******************************************************
cluster(\"Arousa\").database(\"AROClusterLogs\").ClusterLogs
| where PreciseTimeStamp $TIMEVALUE
| where SubscriptionID == \"$SUBSCRIPTION_ID\"
| distinct ResourceName
| sort by ResourceName asc\n"> ${SCRIPT_PATH}/kusto-queries/ARO/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
printf "\nKusto queries for the cluster have been save in:\n\t${SCRIPT_PATH}/aks-kusto-queries/${RESOURCEGROUP_NAME}_${RESOURCE_NAME}.kql
\nIf you are using Windows subsystem layer you can get to that path from %%userprofile%%\\AppData\\Local\\Packages and look for the distribution folder
\texample for Ubuntu: CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\n
\nThen look for \"LocalState - rootfs\"
format C:\\\Users\\NAME\\AppData\\Local\\Packages\\DISTRO_FOLDER\\LocalState\\\rootfs\n\n"


else
	echo "************"
	echo "Wrong Option"
	echo "************"
fi

