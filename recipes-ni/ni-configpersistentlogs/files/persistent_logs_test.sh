#!/bin/bash
#
# Test whether the scripts to configure persistent logging work.
#

source $(dirname "$0")/ptest-format.sh

ptest_test=$(basename "$0" ".sh")

check_var_log_type()
{
	OUTPUT=$(ls -ald /var/log)
	if [[ ${OUTPUT:0:1} == $1 ]] ; then
		ptest_pass
	else
		ptest_fail
	fi
}

check_default_persistence() {
	check_var_log_type "l"
}

set_enable_persistent_logging()
{
	/usr/local/natinst/bin/nirtcfg --set section=SystemSettings,token=PersistentLogs.enabled,value="$1"
	/etc/init.d/ni-configpersistentlogs
	/etc/init.d/populate-volatile.sh
}

test_enable_persistent_logging() {
	set_enable_persistent_logging "True"
	check_var_log_type "d"
}

test_disable_persistent_logging() {
	set_enable_persistent_logging "False"
	check_var_log_type "l"
}


ptest_change_subtest 1 "check default logging persistence"
check_irq_thread_affinity
ptest_report
first_rc=$ptest_rc
prev_rc=$first_rc

if [ $first_rc -gt 0 ]; then
	echo "REASON: Can't continue testing due to previous failure"
	ptest_skip
else
	ptest_change_subtest 2 "test enable persistent logging"
	test_enable_persistent_logging
	prev_rc=$ptest_rc
fi
ptest_report

if [ $first_rc -gt 0 ]; then
	echo "REASON: Can't continue testing due to previous failure"
	ptest_skip
else
	ptest_change_subtest 3 "test disable persistent logging"
	test_disable_persistent_logging
	prev_rc=$ptest_rc
fi
ptest_report

exit $first_rc
