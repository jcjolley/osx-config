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

	case "$1" in
		dev)
			kubectl config use-context $dev_context
			;;
		stg)
			kubectl config use-context $stg_context
			;;
		prd)
			kubectl config use-context $prd_context
			;;
		*)
			echo "Usage: $0 <context>"
			echo "Context must be one of (dev, stg, prd)"
			exit 1
			;;
	esac
}

function pod_errors() {
	while true; do
		contexts=('dev' 'stg' 'prd')
		for cx in $contexts; do
			kx $cx 2>&1 >/dev/null
			pods=$(kubectl get pods -n helios 2>&1 | tail -n +4)
			error_pods=$(rg -v "(Running|Terminating)" <<< "$pods")
			if [ -n "$error_pods" ]; then
				clear
				echo "$(date) - Environment: $cx"
				echo $error_pods
			fi
		done
		sleep 10
	done 
}
