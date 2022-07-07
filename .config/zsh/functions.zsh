################################################################################
# Follow the logs from a deployed service
################################################################################
function hkl() {
	service=$1
	context=${2:-'dev'}
	namespace=${3:-'helios'}

	if [ -z "$1" ] 
	then
		echo "USAGE: hkl <service> <context> <namespace>"
		exit 1
	fi

	kx $context
	kubectl logs -n $namespace deployment/$service -f | grep "^{" | jq -r '{date: .timestamp, level: .level?, message: .message, exception: .exception?}'
}


################################################################################
# Follow the error logs from a deployed service
################################################################################
function hkle() {
	service=$1
	context=${2:-'dev'}
	namespace=${3:-'helios'}

	if [ -z "$1" ] 
	then
		echo "USAGE: hkl <service> <context> <namespace>"
		exit 1
	fi

	kx $context
	kubectl logs -n $namespace deployment/$service -f | grep "^{" | jq -r '{date: .timestamp, level: .level?, message: .message, exception: .exception?} | select(.level == "ERROR")'
}

################################################################################
# Switch the kubectl context with friendly args like "dev", "stg", and "prd"
################################################################################
function kx() {
	dev_context='gke_assuring-cockatoo-c4d6_us-west4_primary'
	stg_context='gke_mint-moray-ca98_us-west4_primary'
	prd_context='gke_moved-gobbler-a6b8_us-west4_primary'

	if [ $1=="dev" ] 
	then
		kubectl config use-context $dev_context
	elif [ $1=="stg" ]
	then
		kubectl config use-context $stg_context
	elif [ $1=="prd" ]
	then
		kubectl config use-context $prd_context
	else
		kubectl config use-context $1
	fi
}
