# Local Docker Swarm Bootstrap

`swarm-bootstrap` provides a convenient way to create a local swarm for testing, evaluation,
and demo purposes. It exploits [Docker in Docker](https://hub.docker.com/_/docker/), originally
developed by Docker engineer and containerizer of all things, [Jérôme Petazzoni](https://twitter.com/jpetazzo).

What this means is that instead of creating a bunch of virtual machines (typically using
[Docker Machine](https://docs.docker.com/machine/overview/)) we can simply start a number
of Docker engines running inside of their own containers on the host. This provides a very
fast and lightweight way to create "nodes" to form a swarm for running and testing services.

However, the script isn't meant to be run on the host. Instead, it is meant to be run
from a container on the host that share the same network as the rest of the containers
to simplify provisioning and allow nodes to be accessed using their names. Therefore, the
first step in making things work will be to create a bridge network called `hostnet`.

One of the containers will be used to host a registry service that the other containers
will use to access any local images you build that haven't been pushed to the public Docker
hub. This is because we're creating a swarm that is isolated from the host and doesn't have
access to the host's local image cache. The other containers will be used to provide
managers and workers for the swarm.  The swarm will use its own overlay network called `swarmnet`.

The script is parameterized to create a configurable number of managers and workers.
By default, it will create three managers and two workers.

The following are the steps required to make this all work:

1. Create a bridge network on the host

```
$ docker network create hostnet
```

2. Start bootstrap

The bootstrap script defaults to 3 managers and 2 workers, but this can be overridden with
environment variables as shown below. The container needs to use the `hostnet` network and
needs the Docker socked to be mounted so that it can create containers on the host that will
comprise the cluster.

```
$ docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock --network hostnet -e MANAGERS=5 -e WORKERS=3 subfuzion/swarm-bootstrap
```

The bootstrap script accepts arguments, which it will pass to docker when creating the container for the first swarm manager.
This is particularly convenient for specifying ports you want published on the host. For example:

```
$ docker run -t --rm -v /var/run/docker.sock:/var/run/docker.sock --network hostnet -e MANAGERS=5 -e WORKERS=3 subfuzion/swarm-bootstrap -p 8080:8080 -p 3000:3000
```

