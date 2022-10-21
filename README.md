# rmats-docker
Build a Container for rmats from bioconda

Steps to build this docker container.
1. Look up on [anaconda](https://anaconda.org/) the tool you wish to install
2. create an `environment.yml` file either manually or automatically
3. Use the template `Dockerfile` modifying if necessary (in our case we have no custom files for the `src` directory so we do not use that)
4. Build the Docker Image
5. Set up GitHub Actions

### Build

To build your image from the command line:
* Can do this on [Google shell](https://shell.cloud.google.com) - docker is installed and available

```bash
docker build -t rmats .
```

To test this tool from the command line 

Set up an environment variable capturing your current command line:
```bash
PWD=$(pwd)
```

Then mount and use your current directory and call the tool now encapsulated within the environment.
```bash
docker run -it -v $PWD:$PWD -w $PWD rmats RNASeq-MATS.py -h
```

## (Optional) Deposit your container in the your [CAVATICA](cavatica.sbgenomics.com)  Docker Registry

If you are working with Kids First or INCLUDE data, and you are registered with either the [Kids First DRC](https://kidsfirstdrc.org/) or the [INCLUDE Data Hub](https://includedcc.org/), you have access to a platform as a service, CAVATICA by Seven Bridges.

If you do, you Docker Image Repository Specific to you is at the location of pgc-images.sbgenomics.com/[YOUR CAVATICA USERNAME]

There are three steps to building and using a container

1. build
2. tag
3. push

We have built and we did tag this (I built the above on my desktop which is a mac, but it could have been built within a google shell.  Examples of how to do this are found in the [Elements of Style in Workflow Creation and Maintenance, Day 3](https://github.com/NIH-NICHD/Kids-First-Elements-of-Style-Workflow-Creation-Maintenance/blob/main/classes/Building-A-Nextflow-Script/README.md#preamble-to-building-workflows-using-containers)

### Tag

To tag the image just built, you need the image id, to get that simply use the command **`docker images`**.

```bash
docker images
REPOSITORY                                           TAG       IMAGE ID       CREATED          SIZE
rmats                                                latest    0ca8aaf01be0   16 minutes ago   1.53GB
```

Now we re-tag it for pushing to our own personal [CAVATICA](cavatica.sbgenomics.com) docker container registry.

```bash
docker tag 0ca8aaf01be0 pgc-images.sbgenomics.com/[YOUR CAVATICA USERID]/rmats/v4.1.2
```

### Docker registry login

There is actually another step required before you can do your push to the registry.  You need to authenticate.

Navigate to the CAVATICA Developers Tab.

Select Authentication Token, if you have not done so, generate that token.

Then Copy the token and paste it in the proper location in the command below (after -p for password)

```bash
docker login pgc-images.sbgenomics.com -u [YOUR CAVATICA USERNAME] -p [YOUR AUTHENTICATION TOKEN]
```

### Push

Now that we have

* tagged :whitecheck our docker image and

* we have authenticated :whitecheck 

```bash
docker push pgc-images.sbgenomics.com/[YOUR CAVATICA USERNAME]/rmats/v4.1.2
```

You know things are going correctly when you see something to the effect of:


```bash
The push refers to repository [pgc-images.sbgenomics.com/deslattesmaysa2/rmats/v4.1.2]
ea25457229f1: Pushed 
17280cc0fa6b: Pushed 
ab2731ec3f53: Pushed 
6fa1f4185aa2: Pushed 
ad6562704f37: Pushed 
latest: digest: sha256:3b1976baa7c4aaa2afd25098c41c754e2579060b6c1da32282c45ac8a10293a9 size: 1373
```

