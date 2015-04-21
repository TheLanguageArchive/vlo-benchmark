The instructions below describe the installation of the applications necessary
for browsing: the VLO web application, the Solr server, and the meta data
importer.

1. The archive

   The VLO importer and web application are contained in an
   archive. In the case of version 3.0, the archive is named

   	vlo-3.0-Distribution.tar.gz

   Deploying the VLO application means:
   - unpacking the archive in a suitable location
   - unpacking the war files contained in the archive
   - adapt the application's context files
   and 
   - adapt the VloConfig.xml main configuration file.
   - optionally executing upgrade steps described in the UPGRADE file

2. Archive unpacking

   Unpack the archive, for example 

  	 vlo-3.0-Distribution.tar.gz

   in a temporary directory: 'temp'. Next, stop the Tomcat server: 

   	/etc/init.d/tomcat6 stop 

   After the server has stopped, copy the contents of the vlo_parent-2.13 
   directory just created to a permanent directory, 'vlo', for example. In the
   tree starting in vlo, the configuration of the application is stored. Also, 
   from the 

   	vlo/bin
   
   directory, you can run the importer application. Since this application
   relies on the Solr server, we first need to install the Solr web application.

   Recursively assign ownership of the entire unpacked distribution to the appropriate
   user (i.e. 'vlouser' on catalog.clarin.eu).

3. Solr server installation

   The VLO importer and web application use Solr as their database
   server. To install this server, assuming that the Tomcat server 
   has not started yet, copy the Solr server web application archive 
   to the Tomcat server web application directory. This could for 
   example be

   	/var/lib/tomcat6/webapps

   Step into this directory, lets call it 'apps',

   	cd apps
   	cp temp/vlo-3.0/war/vlo-solr-3.0.war .

   If it does not exist, create the vlo_solr directory, and unpack the web 
   application archive in it: 

   	cd vlo_solr
   	unzip ../vlo-solr-3.0.war  

   After unzipping, remove the vlo-solr-3.0.war file. Next, if necessary, 
   modify the solr/home parameter in the 
 
   	apps/META-INF/context.xml

   file to the path where the solr server finds its configuration and stores 
   its data:

   	vlo/config/solr 

   Solr needs a location to store its index data. This needs to be configured
   through a Java system property 'solr.data.dir'. Configure this in your
   Tomcat instance, for example by adding the following to 
   ${catalina.home}/bin/setenv.sh:
   
    export JAVA_OPTS="$JAVA_OPTS -Dsolr.data.dir=/var/vlo/solr/data"

   The directory does not have to exist, but its parent does and the Tomcat
   user needs write access in that location.
   
   Copy the new context.xml file to the Tomcat configuration:

   	cp apps/META-INF/context.xml \ 
   		$CATALINA_HOME/conf/Catalina/localhost/vlo_solr.xml

   If you would like logging to be configured different from the type of 
   logging packaged, please modify 

   	apps/WEB-INF/classes/log4j.properties
   
   If necessary, change the ownership of the files in the tree starting in 

   	vlo/config/solr

   to that of the Tomcat user. This will enable the Solr server can store data 
   in it. Now the Solr server has been installed, the importer and web 
   application could use it. Next we will install the VLO web application.

4. Web application installation

   Similar to the Solr archive, unpack 

   	temp/vlo-3.0/war/vlo-web-app-3.0.war in 
   
   the  

   	apps/vlo 

   directory.

   Because the packaged configuration is suitable to very specific (development)
   circumstances only, in most cases it does fit the production environment. You
   can specify an alternative, external configuration file, preferably the same 
   file as the one used by the importer (see 5). Please modify 

   	apps/META-INF/context.xml

   by adding a reference to an external configuration file. By modifying this
   file, you can adapt the VLO configuration to your needs. You might, for
   example, need to assign another value to the solrUrl parameter also. This 
   parameter is used to let the VLO web application know where it can reach the
   Solr server.

   Instead of changing the value of the solrUrl parameter in the external 
   configuration file, you could also supply an alternative value by adding 
   the parameter to 

   	apps/META-INF/context.xml

   directly. The comments in this file will tell you how to add the parameter.

   Like in the case of the Solr server, copy the apps/META-INF/context.xml 
   context file to:

   	/var/lib/tomcat6/conf/Catalina/localhost/vlo.xml

   or to another, comparable path. 

   If you like, you can change the web application's way of logging. This time, 
   modifications should be applied to:

   	apps/WEB-INF/classes/log4j.properties

   Now the web application has been installed and configured, we only need to 
   have a look at the VLO importer's configuration.

5. Importer configuration

   As mentioned in the description of the web application installation, a 
   typical setup needs an external configuration file. For consistency reasons
   both the web application and application that imports data into the Solr
   data base should use one and the same configuration file. So if, for example, 
   the web application's configuration is in 

   	$VLO_CONFIG/VloConfig.xml, use 

   	./vlo_solr_importer.sh $VLO_CONFIG/VloConfig.xml

   to run the importer in 'bin'. A default configuration file is supplied as
   'config/VloConfig.xml'. The importer script will default to this location
   if no location is specified on the command line.

   Most likely, in the configuration file, the dataRoot values need to be 
   changed. This is what a dataRoot definition could look like:

	   <originName>MPI self harvest</originName>
		 <rootFile>/var/www/vlomd/self/</rootFile>            
		 <prefix>http://m12404423/vlomd/</prefix>
		 <tostrip>/var/www/vlomd/</tostrip>
		 <deleteFirst>false</deleteFirst>
	   </DataRoot>

   A dataRoot element describes the meta data files. The toStrip part of the
   description is left out of the rootFile part to create a http link to the
   meta data; the links starts with the prefix.

   Apart from the dataRoot values, the solrUrl parameter might need to be
   changed. Please note that the context path value defined in

   	$CATALINA_HOME/conf/Catalina/localhost/vlo_solr.xml 

   or in a file equivalent to this one, should be reflected in the value of 
   this parameter.

   Whenever the definition of the database changes, it is recommended to clear
   the database before starting an importer run. To do this, make sure that the
   'deletaAllFirst' parameter equals true before the run. After that, the 
   original value of the parameter could be restored. 

6. Importing data

   Before starting data import, first start the Tomcat server:

   	/etc/init.d/tomcat6 start

   To be sure the Solr server is working as it should, inspect the Tomcat log 
   file directory, and in that directory, check the solr.log and vlo.log files. 

   Next, you can run the importer by starting the 

   	./vlo_solr_importer.sh

   script in the vlo/bin directory. Messages are logged to the console. Because 
   meta data is not static, it is recommended to run the importer a couple of 
   times a week. Please note that, given the current (04.2014) set of data, a  
   run typically takes between two and four hours.
