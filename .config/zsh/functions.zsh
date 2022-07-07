function hkl() {
	kubectl logs -n helios deployment/$1 -f
}
