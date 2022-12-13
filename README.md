[![Docker Image CI](https://github.com/adeslatt/rmats-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/adeslatt/rmats-docker/actions/workflows/docker-image.yml)
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
docker tag 0ca8aaf01be0 pgc-images.sbgenomics.com/[YOUR CAVATICA USERID]/rmats:v4.1.2
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

### (Optional) Running tests on CAVATICA testing the steps before compiling a workflow

The first time I used rMATS was in 2017 and it was with version 3.2.5.  With the CTO of Lifebit, Pablo Prieto, we wrote -- mostly he and Christina Chatzipiantzou -- wrote my first Nextflow workflow.   Pablo took my scripts, a combination of bash awk and written for me by Mohan Bolisetty -- the python script to make a matrix from the columns. 

Testing to see if we can call **`rmats`** with the new version from the **`STAR`** aligned files that we are now working with -- so made a copy of some working bam files and we take it from there.

When working with aligned bam files, you have to pass to rmats a text file containing the locaiton of the bam files.

Now, thanks to the splitting out of the newer version of rMATS into a prep and a post step, we do now get the same output files we were able to get 5 years ago.

Using a copy of a bam file that worked, I trick rMATS a bit into thinking there were two files - just to get the output.  THere isn't much of a difference (though there is some dispute on this) between running rMATS in this way "against" itself to establish the splicing events within a file, versus running a sample against all the samples that you desire to run it against.   In the way that is practiced here, we can create a catalog per sample of those splicing events and get at the dynamics of the splicing landscape.

Sample 1 prep step
```bash
python /opt/conda/bin/rmats.py --b1 /sbgenomics/workspace/test_data/htp.1B2.txt --gtf /sbgenomics/workspace/human_genome/gencode.v33.annotation.gtf -t paired --readLength 150 --variable-read-length --nthread 14 --od /sbgenomics/workspace/htp.1B2.out --tmp /sbgenomics/workspace/htp.1B2.tmp --task prep
```

Sample 2 (copy of sample 1) prep step
```bash
python /opt/conda/bin/rmats.py --b1 /sbgenomics/workspace/test_data/htp.1B2.copy.txt --gtf /sbgenomics/workspace/human_genome/gencode.v33.annotation.gtf -t paired --readLength 150 --variable-read-length --nthread 14 --od /sbgenomics/workspace/htp.1B2.copy.out --tmp /sbgenomics/workspace/htp.1B2.copy.tmp --task prep
```

Now we copy the rmats files from the tmp directories created above

```bash
mkdir -p htp.post.tmp
cp htp.1B2.*/*.rmats htp.post.tmp/
```

And execute the post-rmats task
```bash
 python /opt/conda/bin/rmats.py --b1 /sbgenomics/workspace/test_data/htp.1B2.txt --b2 /sbgenomics/workspace/test_data/htp.1B2.copy.txt --gtf /sbgenomics/workspace/human_genome/gencode.v33.annotation.gtf -t paired --od /sbgenomics/workspace/htp.post.out --tmp /sbgenomics/workspace/htp.post.tmp --readLength 150 --variable-read-length --task post 
 ```
 
 Upon success we have the same output details we used to get with rMATS v.3.2.5, which means we will be able to make the same output matrices we made before utilizing the script [sampleCountSave.sh](https://github.com/lifebit-ai/rmats-nf/blob/master/containers/post-rmats/sampleCountsSave.sh) to establish the sample specific column details for each of the splicing junction types.
 
 ```bash
 There are 60662 distinct gene ID in the gtf file
There are 227912 distinct transcript ID in the gtf file
There are 36733 one-transcript genes in the gtf file
There are 1377112 exons in the gtf file
There are 25243 one-exon transcripts in the gtf file
There are 22482 one-transcript genes with only one exon in the transcript
Average number of transcripts per gene is 3.757080
Average number of exons per transcript is 6.042297
Average number of exons per transcript excluding one-exon tx is 6.670329
Average number of gene per geneGroup is 8.465804
statistic: 0.03493547439575195
loadsg: 0.055367469787597656

==========
Done processing each gene from dictionary to compile AS events
Found 63426 exon skipping events
Found 5099 exon MX events
Found 17812 alt SS events
There are 10773 alt 3 SS events and 7039 alt 5 SS events.
Found 7101 RI events
==========

ase: 1.9506540298461914
count: 4.605753421783447
Processing count files.
Done processing count files.
```

We see that we have **63,426** exon skiping events, **5,099** mutually exclusive exon events, **17,812** alternative Splice Site (**10,773** alternative 3' splice sites, **76,039** alternative 5' splice sites) and a total of **7,101** retained intron events.

The best part is this:

```bash
-rw-r--r--  1 jovyan users  697772 Dec 13 21:24 A3SS.MATS.JCEC.txt
-rw-r--r--  1 jovyan users  695982 Dec 13 21:24 A3SS.MATS.JC.txt
-rw-r--r--  1 jovyan users  445440 Dec 13 21:24 A5SS.MATS.JCEC.txt
-rw-r--r--  1 jovyan users  442444 Dec 13 21:24 A5SS.MATS.JC.txt
-rw-r--r--  1 jovyan users 1046852 Dec 13 21:24 fromGTF.A3SS.txt
-rw-r--r--  1 jovyan users  683471 Dec 13 21:24 fromGTF.A5SS.txt
-rw-r--r--  1 jovyan users  591294 Dec 13 21:24 fromGTF.MXE.txt
-rw-r--r--  1 jovyan users   65733 Dec 13 21:24 fromGTF.novelJunction.A3SS.txt
-rw-r--r--  1 jovyan users   49272 Dec 13 21:24 fromGTF.novelJunction.A5SS.txt
-rw-r--r--  1 jovyan users  197123 Dec 13 21:24 fromGTF.novelJunction.MXE.txt
-rw-r--r--  1 jovyan users    9931 Dec 13 21:24 fromGTF.novelJunction.RI.txt
-rw-r--r--  1 jovyan users 1397573 Dec 13 21:24 fromGTF.novelJunction.SE.txt
-rw-r--r--  1 jovyan users     102 Dec 13 21:24 fromGTF.novelSpliceSite.A3SS.txt
-rw-r--r--  1 jovyan users     102 Dec 13 21:24 fromGTF.novelSpliceSite.A5SS.txt
-rw-r--r--  1 jovyan users     140 Dec 13 21:24 fromGTF.novelSpliceSite.MXE.txt
-rw-r--r--  1 jovyan users     108 Dec 13 21:24 fromGTF.novelSpliceSite.RI.txt
-rw-r--r--  1 jovyan users     104 Dec 13 21:24 fromGTF.novelSpliceSite.SE.txt
-rw-r--r--  1 jovyan users  685113 Dec 13 21:24 fromGTF.RI.txt
-rw-r--r--  1 jovyan users 6234678 Dec 13 21:24 fromGTF.SE.txt
-rw-r--r--  1 jovyan users  121649 Dec 13 21:24 JCEC.raw.input.A3SS.txt
-rw-r--r--  1 jovyan users   77439 Dec 13 21:24 JCEC.raw.input.A5SS.txt
-rw-r--r--  1 jovyan users   74313 Dec 13 21:24 JCEC.raw.input.MXE.txt
-rw-r--r--  1 jovyan users  110309 Dec 13 21:24 JCEC.raw.input.RI.txt
-rw-r--r--  1 jovyan users  724603 Dec 13 21:24 JCEC.raw.input.SE.txt
-rw-r--r--  1 jovyan users  120859 Dec 13 21:24 JC.raw.input.A3SS.txt
-rw-r--r--  1 jovyan users   76486 Dec 13 21:24 JC.raw.input.A5SS.txt
-rw-r--r--  1 jovyan users   72298 Dec 13 21:24 JC.raw.input.MXE.txt
-rw-r--r--  1 jovyan users  107174 Dec 13 21:24 JC.raw.input.RI.txt
-rw-r--r--  1 jovyan users  709421 Dec 13 21:24 JC.raw.input.SE.txt
-rw-r--r--  1 jovyan users  469267 Dec 13 21:24 MXE.MATS.JCEC.txt
-rw-r--r--  1 jovyan users  459341 Dec 13 21:24 MXE.MATS.JC.txt
-rw-r--r--  1 jovyan users  603462 Dec 13 21:24 RI.MATS.JCEC.txt
-rw-r--r--  1 jovyan users  596717 Dec 13 21:24 RI.MATS.JC.txt
-rw-r--r--  1 jovyan users 4132746 Dec 13 21:24 SE.MATS.JCEC.txt
-rw-r--r--  1 jovyan users 4058868 Dec 13 21:24 SE.MATS.JC.txt
-rw-r--r--  1 jovyan users     354 Dec 13 21:24 summary.txt
```
We have all the output files we had previously.
