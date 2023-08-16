
exception_log=' {
	date: .timestamp?, 
	level: .level?, 
	message: .message?, 
	exception: ( 
		.exception? | if . != null then {
			exceptionType: .exceptionType?,
			message: .message?,
			frames: (
				.frames? 
				| if . != null then map( 
					{class: .class?, method: .method?, line: .line?}
					| select(.class? | test("clearwater"))
					| [.class?, .method?, .line?]
					| join(":") 
				) else . end
			)
		} else . end
	),
	stackTrace: .stackTrace?
}'

no_exception_log='{
	date: .timestamp?, 
	level: .level?, 
	message: .message?, 
}'

################################################################################
# Follow the logs from a deployed service
################################################################################
function hkl() {
	service=$1
	context=${2:-'prd1'}
	namespace=${3:-'helios'}

	if [ -z "$1" ] 
	then
		echo "USAGE: hkl <service> <context> <namespace>"
		exit 1
	fi

	kubectx $context 2>&1 >/dev/null
	kubectl logs -n $namespace deployment/$service -f 2>&1 \
		| egrep "^{" --line-buffered \
		| jq --unbuffered -r "if .exception? != null then $exception_log else $no_exception_log end" -C \
	        | sed 's/\\n/\n/g; s/\\t/\t/g'
}


################################################################################
# Follow the error logs from a deployed service
################################################################################
function hkle() {
	service=$1
	context=${2:-'prd1'}
	namespace=${3:-'helios'}

	if [ -z "$1" ] 
	then
		echo "USAGE: hkl <service> <context> <namespace>"
		exit 1
	fi

	kubectx $context 2>&1 >/dev/null
	kubectl logs -n $namespace deployment/$service -f 2>&1 \
		| egrep "^{" --line-buffered \
		| jq --unbuffered -r "select(.level? == \"ERROR\") | $exception_log" -C \
	        | sed 's/\\n/\n/g; s/\\t/\t/g'
}

################################################################################
# Switch the kubectl context with friendly args like "dev", "stg", and "prd"
################################################################################
function kx() {
	dev_context='beta'
	stg_context='stg1'
	prd_context='prd1'

	case "$1" in
		dev)
			kubectx $dev_context
			;;
		stg)
			kubectx $stg_context
			;;
		prd)
			kubectx $prd_context
			;;
		*)
			echo "Usage: $0 <context>"
			echo "Context must be one of (beta, stg1, prd1)"
			exit 1
			;;
	esac
}

################################################################################
# Show any pods with errors
################################################################################
function pod_errors() {
	while true; do
		contexts=('dev' 'stg' 'prd')
		for cx in $contexts; do
			kx $cx 2>&1 >/dev/null
			pods=$(kubectl get pods -n helios 2>&1 | tail -n +4)
			error_pods=$(rg -v "(ContainerCreating|Running|Terminating)" <<< "$pods")
			if [ -n "$error_pods" ]; then
				clear
				echo "$(date) - Environment: $cx"
				echo $error_pods
			fi
		done
		sleep 10
	done 
}
