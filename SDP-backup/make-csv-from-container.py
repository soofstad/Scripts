# coding=utf-8
# Generates a csv-file from running containers on the nodes specified in the docker-nodes.txt.
# The CSV-file is intended to be used as input for the backup_sdp.bash script.
import subprocess
import sys
import json

with open('docker-nodes.txt') as nodefile:
    nodes = nodefile.readlines()

def ssh(host, command):

    message = subprocess.Popen(
        ["ssh", "%s" % host, command],
        shell=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    result = message.stdout.readlines()
    if not result:
        error = message.stderr.readlines()
        print >> sys.stderr, "ERROR: %s" % error
        exit(1)
    else:
        return result


user = "root@"
with open('py_targets.csv', 'w') as targetfile:
    for node in nodes:
        vhost = user + node
        vhost = vhost.strip("\n")
        node = node.strip("\n")
        cmd = "docker ps --format='{{.Names}}'"
        containers = ssh(vhost, cmd)
        mount_format = ""

        for container in containers:
            container = container.strip("\n")
            cmd = "docker inspect --format='{{{{json .Mounts}}}}' {container}".format(container=container)
            mounts_json = json.loads(ssh(vhost, cmd)[0])

            for mount in mounts_json:
                if 'Type' in mount and mount['Type'] is not None:
                    if mount['Type'].lower() == 'bind':
                        mount_source = mount['Source']
                        print "Adding '{mount_source}' on node '{node}' container '{container}' to backuplist...".format(mount_source=mount_source, node=node, container=container)
                        mount_format += "\"{mount_source}\" ".format(mount_source=mount_source)

                    else:
                        non_bind = mount['Source']
                        print "Skipping volume {non_bind} on {node} on container {container} as it's not a 'bind' type".format(non_bind=non_bind, node=node, container=container)

        targetfile.write('{node};{node};;{mount_format};\n'.format(node=node, mount_format=mount_format))