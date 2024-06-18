check_file_exists() {
	if [[ ! -f "$1" ]]; then
		echo "File doesn't exist"
		exit 1
	fi

	if [[ ! -r "$1" ]]; then
		echo "File isn't readable"
		exit 1
	fi
}

validate_profile() {
	local errors=0
	if ! grep -qE '^profile\s+\S+\s+' "$profile_file"; then
		echo -e "${error}Error: Profile does not start with the correct header.${reset}"
		errors=$((errors+1))
	fi

	if ! grep -qE '^\s*\}\s*$' <(tail -n 1 "$profile_file"); then
		echo -e "${error}Error: No closing brace for the profile${reset}"
		errors=$((errors+1))
	fi

	if ! grep -qE 'network (inet (tcp|udp|icmp) |raw|packet),' "$profile_file"; then
		echo -e "${warning}Warning: No network rules in profile${reset}"
	fi

	if ! grep -qE 'capability'  "$profile_file"; then
		echo -e "${warning}Warning: No capability rules in profile${reset}"
	fi

	if grep -E '([*?])' "$profile_file" | grep -vqE 'deny'; then
		echo -e "${warning}Warning: Wildcard usage may be overly permissive, consider specifying resources:"
		grep -E '([*?])' "$profile_file" | grep -vE 'deny' | sed '$s/^/ - /' 
	fi

	# file [/path/to/file_or_directory] permissions
	# /etc/nginx/nginx.conf r
	#
	# mount
	# umount
	# audit [/path/to/file_or_directory] [permissions]
	# 
	# deny [/path/to/file_or_directory] [permissions]
	#
	# "{PROC}/mem rwklx

	if [[ $errors -eq 0 ]]; then
		echo -e "${reset}AppArmor profile is valid"
	else
		echo -e "${error}AppArmor profile validation failed with $errors error(s)${reset}"
	fi
}

warning='\033[33m'
error='\033[31m'
reset='\033[0m'

profile_file="$1"

check_file_exists "$profile_file"

validate_profile "$profile_file"
