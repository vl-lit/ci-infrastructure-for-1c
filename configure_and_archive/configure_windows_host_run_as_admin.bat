chcp 65001

SET JENKINS_INSTALL_PATH=C:\Program Files (x86)\Jenkins
SET APACHE_VERSION=2.4.41
SET APACHE_PARENT_DIR=C:/
SET APACHE_PORT=80
SET VIRTUAL_BOX_VERSION=6.0.14


@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco install vscode -y --force
choco install virtualbox --params "/NoDesktopShortcut" --version=%VIRTUAL_BOX_VERSION% -y --force
choco install packer -y --force
choco install vagrant -y --force
REM По умолчанию через choco инструменты HashiCorp ставятся в каталог C:\HashiCorp, создадим подкаталог для боксов в нем
mkdir C:\HashiCorp\vagrant_home

choco install git --params "/GitAndUnixToolsOnPath /NoAutoCrlf" -y --force
choco install apache-httpd --version=%APACHE_VERSION% --params '"/serviceName:Apache2.4 /installLocation:%APACHE_PARENT_DIR% /port:%APACHE_PORT%"' -y --force

choco install jenkins -y --force
cmd /C deploy_jenkins_jobs_and_nodes_files_run_as_admin.bat
"C:\Program Files\Git\usr\bin\sed.exe" -i "s/<arguments>-/<arguments>-Dfile.encoding=UTF-8 -Dpermissive-script-security.enabled=true -/" "%JENKINS_INSTALL_PATH%/jenkins.xml"
net stop Jenkins
net start Jenkins
