host_machine_ip_or_hostname=$1
jenkins_port=$2
node_name=$3

if [ $(echo $host_machine_ip_or_hostname | grep -P "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" | wc -l) -eq 0 ] \
    && [ $(ping -c 1 $host_machine_ip_or_hostname 2>&1 | head -n 1 | grep 'failure in name resolution' | wc -l) -gt 0 ]
then 
    host_machine_ip_or_hostname=$host_machine_ip_or_hostname.local
fi

jenkins_server=$host_machine_ip_or_hostname:$jenkins_port
jenkins_agent_dir=$HOME/jenkins_agent
echo "Jenkins server is $jenkins_server"

mkdir -p $jenkins_agent_dir
cd $jenkins_agent_dir

# if wget fails to get new file old file won't be overwritten
wgetCommand="wget -q -O agent_new.jar http://$jenkins_server/jnlpJars/agent.jar && mv agent_new.jar agent.jar"
# java ... 2>&1 | tee is required because java for some reason uses 2-nd strem for output and without 2>&1 redirection by tee won't work
startAgentCommand="java -Dfile.encoding=UTF-8 -jar agent.jar -jnlpUrl http://$jenkins_server/computer/$node_name/slave-agent.jnlp -workDir $jenkins_agent_dir 2>&1 | tee agent_console.log"

echo "cd $jenkins_agent_dir" > start_jenkins_node.sh
echo "sleep 15" >> start_jenkins_node.sh
echo "$wgetCommand" >> start_jenkins_node.sh
echo "$startAgentCommand" >> start_jenkins_node.sh    

chmod u+x start_jenkins_node.sh

# Terminal=false  leads to the fact that the console window does not appear on the screen, 
# but at the same time the agent launches all programs interactively.
# The aim is to get file like this:
#
# [Desktop Entry]
# Name=MyScript
# GenericName=A descriptive name 
# Comment=Some description about your script 
# Exec=/path/to/my/script.sh 
# Terminal=false 
# Type=Application 
# X-GNOME-Autostart-enabled=true

cd $HOME
mkdir -p .config/autostart
cd .config/autostart

# Nodisplay, Hidden, Comment etc. play no role when you don't run launchers from Dash
# only Type,EXEC and X-GNOME-Autostart-enabled tags would be required. 
# https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s05.html
# Даже когда Hidden=false и NoDisplay=false запуск не приводит к появлению кона консоли без опции Terminal=true
# В то же время когда Terminal=true окно консоли появляется даже если не указывать параметры Hidden и NoDisplay
# echo Hidden=false >> autostart_jenkins_node.desktop 
# echo NoDisplay=false >> autostart_jenkins_node.desktop 
# Terminal=true без прочих опций приводит к появлению на экране обычного белого терпинала Gnome
echo [Desktop Entry] > autostart_jenkins_node.desktop 
echo Name=AutostartJenkinsNode >> autostart_jenkins_node.desktop 
echo Exec=$jenkins_agent_dir/start_jenkins_node.sh >> autostart_jenkins_node.desktop 
echo Terminal=false >> autostart_jenkins_node.desktop 
echo Type=Application >> autostart_jenkins_node.desktop 
echo X-GNOME-Autostart-enabled=true >> autostart_jenkins_node.desktop
