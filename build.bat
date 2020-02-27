
cmd /C delete_build_artifacts.bat

SET VAGRANT_HOME=C:/HashiCorp/vagrant_home

echo version_of_1c_platform_with_underscores is %version_of_1c_platform_with_underscores%
echo version_of_vm_os_with_dot is %version_of_vm_os_with_dot%
echo version_of_vm_os_with_underscore is %version_of_vm_os_with_underscore%

SET shutdown_command=sudo systemctl poweroff

SET disk_size_mb=32000

SET iso_checksum_type=none
SET virtual_machine_hostname=vagrant-ci
SET ssh_username=vagrant
SET ssh_password=vagrant
SET iso_url=./iso/ubuntu-%version_of_vm_os_with_dot%-live-server-amd64.iso

grep -v '#' boot_command_%version_of_vm_os_with_underscore%.cfg | sed 's/{{user `ssh_username`}}/%ssh_username%/' | sed 's/{{user `ssh_password`}}/%ssh_password%/' | sed 's/{{user `hostname`}}/%virtual_machine_hostname%/' | tr -d '\n' | tr -d '\r' > boot_command_temp.txt
set /P boot_command=< boot_command_temp.txt
rm -f boot_command_temp.txt

echo Boot command is
echo "%boot_command%"

time /T
rmdir /S /Q output-virtualbox-iso
packer build -force -on-error=ask packer_build.json
if %errorlevel% neq 0 exit /b %errorlevel%
time /T
REM Waiting for box file to be released
ping 127.0.0.1 -n 10 > nul
SET box_name=ci_node_ubuntu_%version_of_vm_os_with_underscore%_1c_%version_of_1c_platform_with_underscores%_pg_%version_of_postgresql_with_underscores%
vagrant box remove %box_name% --force
vagrant box add %box_name% %box_name%_virtualbox.box
time /T
