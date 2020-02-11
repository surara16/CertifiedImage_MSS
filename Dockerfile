# Each instruction in this file generates a new layer that gets pushed to your local image cache
#

#
# Lines preceeded by # are regarded as comments and ignored
#


FROM registry.access.redhat.com/ubi8/ubi
RUN echo `id`

#### LABEL
LABEL MAINTAINER Suraj@in.ibm.com \
      vendor: IBM \
      version: Version of the image \
      release: A number used to identify the specific build for this image \
      summary: A short overview of the application or component in this image \
      description: A long description of the application or component in this image

#### Disabling "SU" permision 
RUN usermod -s /sbin/nologin root
RUN echo "auth requisite  pam_deny.so" >> /etc/pam.d/su

#### Install prepare infrastructure
RUN yum -y update && \
  yum -y install wget && \
  yum -y install tar && \
  yum -y install git

#### Creating Directory
RUN mkdir opt/java
RUN mkdir opt/tomcat

#### Prepare environment
ENV JAVA_HOME /opt/java
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

#### Install Oracle Java8
ENV JAVA_VERSION 8u191
ENV JAVA_BUILD 8u191-b12
ENV JAVA_DL_HASH 2787e4a523244c269598db4e85c51e0c

#RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
#http://download.oracle.com/otn-pub/java/jdk/${JAVA_BUILD}/${JAVA_DL_HASH}/jdk-${JAVA_VERSION}-linux-x64.tar.gz && \

#### Changing Working Directory
WORKDIR /opt/java

#### Coping JDK tar file
COPY ./JavaTar/jdk-13.0.2_linux-x64_bin.tar.gz /opt/java

#### Running untar Command a nd moving it to ${JAVA_HOME}
RUN tar -xvf jdk-13.0.2_linux-x64_bin.tar.gz && \
    rm jdk*.tar.gz && \
    mv jdk*/*  ${JAVA_HOME}



#### Install Tomcat
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.30
ENV SCRIPT /opt/tomcat/apache-tomcat-${TOMCAT_VERSION}

#WORKDIR /opt/tomcat
#### Downloading Tomact Tar File
RUN wget http://mirror.linux-ia64.org/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
#COPY ./apache-tomcat-9.0.11/apache-tomcat-9.0.11-deployer.tar.gz /opt/tomcat

RUN tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz  && \
  rm apache-tomcat*.tar.gz && \
  mv apache-tomcat*/* ${CATALINA_HOME}

RUN chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD ./apache-tomcat-9.0.11/create_admin_user.sh $CATALINA_HOME/scripts/create_admin_user.sh
ADD ./apache-tomcat-9.0.11/tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
RUN chmod +x $CATALINA_HOME/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat && \
 useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
 chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /opt/tomcat

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["./scripts/tomcat.sh"]



        

