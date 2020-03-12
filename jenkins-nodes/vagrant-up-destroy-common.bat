
CALL node-settings.bat

if not exist .vagrant (
    SET vagrant_reload_command=vagrant reload
) else (
    SET vagrant_reload_command=echo It is not the first start, no need to reload machine
)

COPY /Y ..\Vagrantfile Vagrantfile

SET VAGRANT_HOME=C:/HashiCorp/vagrant_home
SET box_name=ci_node_ubuntu_%version_of_vm_os_with_underscore%_1c_%version_of_1c_platform_with_underscores%_pg_%version_of_postgresql_with_underscores%

SET jenkins_port=8080

if NOT DEFINED host_machine_ip_or_hostname (
    SET host_machine_ip_or_hostname=%computername%
)

if NOT DEFINED shared_ci_guest_directory (
    SET shared_ci_guest_directory=/home/vagrant/shared_ci
)

if NOT DEFINED shared_ci_host_directory (
    SET shared_ci_host_directory=%~dp0/shared
)

time /T

if %vagrant_action%==up (

    vagrant up
    %vagrant_reload_command%
    vagrant provision --provision-with CheckJenkinsNode

) else if %vagrant_action%==destroy (
    
    vagrant destroy -f && rmdir /s /q .vagrant
    
)


time /T
