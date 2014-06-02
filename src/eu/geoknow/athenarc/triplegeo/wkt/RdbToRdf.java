/*
 * @(#) RdbToRdf.java 	 version 1.1   2/6/2013
 *
 * Copyright (C) 2013 Institute for the Management of Information Systems, Athena RC, Greece.
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package eu.geoknow.athenarc.triplegeo.wkt;

import eu.geoknow.athenarc.triplegeo.Constants;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.db.IDBConnection;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.tdb.TDBFactory;
import com.hp.hpl.jena.vocabulary.RDF;
import com.hp.hpl.jena.vocabulary.RDFS;
import com.mysql.jdbc.Driver;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;
import com.vividsolutions.jts.io.WKTReader;

import eu.geoknow.athenarc.triplegeo.Constants;
import eu.geoknow.athenarc.triplegeo.db.DbConnector;
import eu.geoknow.athenarc.triplegeo.db.DbConstants;
import eu.geoknow.athenarc.triplegeo.db.MsAccessDbConnector;
import eu.geoknow.athenarc.triplegeo.db.MySqlDbConnector;
import eu.geoknow.athenarc.triplegeo.db.OracleDbConnector;
import eu.geoknow.athenarc.triplegeo.db.PostgresqlDbConnector;
import eu.geoknow.athenarc.triplegeo.db.DB2DbConnector;
import eu.geoknow.athenarc.triplegeo.shape.URLConstants;
import eu.geoknow.athenarc.triplegeo.utils.UtilsConstants;
import eu.geoknow.athenarc.triplegeo.utils.UtilsLib;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.ResultSet;
import java.util.Properties;

import org.geotools.factory.Hints;
import org.geotools.feature.simple.SimpleFeatureImpl;
import org.geotools.geometry.jts.JTS;
import org.geotools.referencing.CRS;
import org.geotools.referencing.ReferencingFactoryFinder;
import org.opengis.referencing.crs.CRSAuthorityFactory;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.MathTransform;


/**
 *
 * @author vsaquicela
 * @author magarcia
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * Modified by: Kostas Patroumpas, 8/2/2013
 * Modified: 10/2/2013, added support for Oracle Spatial and PostGIS databases
 * Modified: 6/3/2013, added support for transformation from a given CRS to WGS84
 * Modified: 15/3/2013, added support for exporting custom geometries to (1) Virtuoso RDF and (2) according to WGS84 Geopositioning RDF vocabulary 
 * Modified: 6/6/2013, added support for IBM DB2 and MySQL databases
 * Last modified by: Kostas Patroumpas, 2/6/2014
 */
public class RdbToRdf {

  Model model;
  IDBConnection conn;
  String nsgeontology ;
  String nsgeoresource ;
  String sourceRS;
  String targetRS;
  String gmlSourceRS;
  String gmlTargetRS;
  static String ignoreStr;
  static RdbToRdf dtr;
  private static MathTransform transform = null;
  private static WKTReader reader = null;
  private String defaultLang = "en";
  static String targetStore = "GeoSPARQL";

  private static final String STRING_TO_REPLACE = "+";
  private static final String REPLACEMENT = "%20";
  private static final String SEPARATOR = "_";
  private static final String BLANK = " ";
  
  
  //Create a temporary folder where intermediate files will be written
  public RdbToRdf(String dir) throws ClassNotFoundException {

    if (!dir.endsWith("/")) {
      dir = dir + "/";
    }

    File f = new File(dir);

    if (!f.isDirectory()) {
      f.mkdir();
    }

    dir = dir + "TDB/";

    f = new File(dir);

    if (f.isDirectory()) {
      if (f.exists()) {
        String[] myfiles = f.list();
        if (myfiles.length > 0) {
          for (int i = 0; i < myfiles.length; i++) {
            File auxFile = new File(dir + myfiles[i]);
            auxFile.delete();
          }
        }
        f.delete();
      }
    }

    f.mkdir();

    model = TDBFactory.createModel(dir);
    model.setNsPrefix("geo", Constants.NSGEO);
    model.setNsPrefix("xsd", Constants.NSXSD);
  }

  /**
   * 
   * Main entry point of the utility for extracting triples from geospatially-enabled DBMSs
   */
  public static void main(String[] args) throws Exception 
  {
	System.out.println("*********************************************************************\n*                      TripleGeo version 1.1                        *\n* Developed by the Institute for Management of Information Systems. *\n* Copyright (C) 2013-2014 Athena Research Center, Greece.           *\n* This program comes with ABSOLUTELY NO WARRANTY.                   *\n* This is FREE software, distributed under GPL license.             *\n* You are welcome to redistribute it under certain conditions       *\n* as mentioned in the accompanying LICENSE file.                    *\n*********************************************************************\n");
			
    if (args.length >= 0)  {
      Properties properties = new Properties();
      
      //Specify properties file for conversion of elements from a database
      properties.load(new FileInputStream(args[0]));   //Argument like "./bin/PostGIS_options.conf"

      System.setProperty("org.geotools.referencing.forceXY", "false");
      
      String tmpDir = properties.getProperty("tmpDir");
      String outputFile = properties.getProperty("outputFile");
      String outFormat = properties.getProperty("format");

      System.out.println("Output format is: " + outFormat);
      
      dtr = new RdbToRdf(tmpDir);

      int dbType = Integer.valueOf(properties.getProperty("dbType"));
      String dbName = properties.getProperty("dbName");
      String dbUserName = properties.getProperty("dbUserName");
      String dbPassword = properties.getProperty("dbPassword");
      String dbHost = properties.getProperty("dbHost");
      int dbPort = Integer.parseInt(properties.getProperty("dbPort"));

      //Determine connection type to the specified DBMS
      DbConnector databaseConnector = null;

      switch(dbType) {
        case DbConstants.MSACCESS:   //Currently NOT supported
          databaseConnector = new MsAccessDbConnector(
                  dbHost, dbPort, dbName, dbUserName, dbPassword);
          break;
        case DbConstants.MYSQL:
          databaseConnector = new MySqlDbConnector(
                  dbHost, dbPort, dbName, dbUserName, dbPassword);
          break;
        case DbConstants.ORACLE:
          databaseConnector = new OracleDbConnector(
                  dbHost, dbPort, dbName, dbUserName, dbPassword);
          break;
        case DbConstants.POSTGRESQL:
          databaseConnector = new PostgresqlDbConnector(
                  dbHost, dbPort, dbName, dbUserName, dbPassword);
          break;
        case DbConstants.DB2:
           databaseConnector = new DB2DbConnector(
                   dbHost, dbPort, dbName, dbUserName, dbPassword);
          break;
      }

      String resourceName = properties.getProperty("resourceName");
      ignoreStr = properties.getProperty("ignore");
      targetStore = properties.getProperty("targetStore");

      //Table and attribute properties
      String tableName = properties.getProperty("tableName");
      String condition = properties.getProperty("condition");
      String labelColumnName = properties.getProperty("labelColumnName");
      String geometryColumnName = properties.getProperty("geometryColumnName");
      String nameColumnName = properties.getProperty("nameColumnName");
      String classColumnName = properties.getProperty("classColumnName");

      // Namespace parameters
      String namespacePrefix = properties.getProperty("nsPrefix");
      if (UtilsLib.isNullOrEmpty(namespacePrefix)) {
        namespacePrefix = "georesource";
      }
      String namespace = properties.getProperty("nsURI");
      if (UtilsLib.isNullOrEmpty(namespace)) {
        namespace = "http://geoknow.eu/resource/";
      }
      String ontologyNSPrefix = properties.getProperty("ontologyNSPrefix");
      if (UtilsLib.isNullOrEmpty(ontologyNSPrefix)) {
        ontologyNSPrefix = "geontology";
      }
      String ontologyNamespace = properties.getProperty("ontologyNS");
      if (UtilsLib.isNullOrEmpty(ontologyNamespace)) {
        ontologyNamespace = "http://www.opengis.net/ont/geosparql#";
      }
      dtr.model.setNsPrefix(ontologyNSPrefix, ontologyNamespace);
      dtr.model.setNsPrefix(namespacePrefix, namespace);
      dtr.nsgeontology = ontologyNamespace;
      dtr.nsgeoresource = namespace;
      
      // Reference systems parameters
      dtr.gmlSourceRS = properties.getProperty("gmlSourceRS");
      dtr.gmlTargetRS = properties.getProperty("gmlTargetRS");
      dtr.sourceRS = properties.getProperty("sourceRS");
      dtr.targetRS = properties.getProperty("targetRS");

      //Check if a coordinate transform is required for geometries
      if (dtr.sourceRS != null)
  	    try {
  	        boolean lenient = true; // allow for some error due to different datums
  	        
  	        Hints hints = new Hints(Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE);
  	        CRSAuthorityFactory factory = ReferencingFactoryFinder.getCRSAuthorityFactory("EPSG", hints);
  	        CoordinateReferenceSystem sourceCRS = factory.createCoordinateReferenceSystem(dtr.sourceRS);
  	        CoordinateReferenceSystem targetCRS = factory.createCoordinateReferenceSystem(dtr.targetRS);    
  	        transform = CRS.findMathTransform(sourceCRS, targetCRS, lenient);
  	        
  	        //Needed for parsing original geometry in WTK representation
      	    int srid = Integer.parseInt(dtr.sourceRS.substring( dtr.sourceRS.indexOf(':')+1, dtr.sourceRS.length()));
  	        GeometryFactory geomFactory = new GeometryFactory(new PrecisionModel(), srid);
  	        reader = new WKTReader(geomFactory);
  	      
  	        System.out.println("Transformation will take place from " + dtr.sourceRS + " to " + dtr.targetRS + " reference system.");
  	        
  		} catch (Exception e) {
//  			e.printStackTrace();
  		}
      else
      	System.out.println("No transformation will take place. Input data is expected in WGS84 reference system.");

      // Other parameters
      dtr.defaultLang = properties.getProperty("defaultLang");
      if (UtilsLib.isNullOrEmpty(dtr.defaultLang)) {
        dtr.defaultLang = "en";
      }
      dtr.executeParser(databaseConnector, tableName, resourceName, condition, outputFile, outFormat,
              labelColumnName, geometryColumnName, nameColumnName, classColumnName);
      
      //Remove all temporary files as soon as processing is finished
      UtilsLib.removeDirectory(tmpDir);
    } else {
      System.out.println("Incorrect arguments number. Properties file required.");
    }
  }

  /**
   * 
   * Parse each record in order to create the necessary triples (including geometric and non-spatial attributes)
   */
  private void executeParser(DbConnector dbConn, String tableName, String resource,
                            String condition, String outputFile, String outFormat, String labelColumnName,
                            String geometryColumnName, String nameColumnName, String classColumnName) throws Exception {
    int totalRows;

    System.out.println(UtilsLib.getGMTime() + " Started processing features...");
    long t_start = System.currentTimeMillis();
    long dt = 0;
    
    //Identify additional attributes for name and type of each feature
    String auxColumns = "";
    if ((!classColumnName.trim().equals("")) && (!nameColumnName.trim().equals("")))
    	auxColumns = classColumnName + ", " + nameColumnName + ", ";
    
    //Check if criteria have been specified for selection of qualifying records
    if (condition.trim().equalsIgnoreCase(""))
    	condition = "";       //All table contents will be exported
    else
    	condition = " WHERE ( " + condition + ")";
    
    //Count records
    String sql = "SELECT count(*) AS total FROM " +  tableName + condition; // +" order by " + labelColumnName;
  
    ResultSet rs = dbConn.executeQuery(sql);
    rs.next();
    totalRows = rs.getInt("total");    //total records to be exported
    System.out.println(UtilsLib.getGMTime() + " Number of database records to be processed: " + totalRows);
    int numRec = 1;
  
      //Formulate SQL query according to the spatial syntax of each DBMS
      if (dbConn.getClass().getSimpleName().contains("Oracle"))
      {
      //ORACLE
      sql = " SELECT " + labelColumnName + " e , " + auxColumns
            + "SDO_UTIL.TO_WKTGEOMETRY(" + geometryColumnName + ") WktGeometry FROM "
            + tableName + condition;
      }
      else if (dbConn.getClass().getSimpleName().contains("Postgres"))
      {    
      //PostGIS
      sql = "SELECT e." + labelColumnName + " e , " + auxColumns
    		  + "ST_AsText(" + geometryColumnName + ") WktGeometry FROM "
              + tableName + " e " + condition; 
      }
      else if (dbConn.getClass().getSimpleName().contains("MySql"))
      {    
      //MySQL
      sql = "SELECT e." + labelColumnName + " e , " + auxColumns
    		  + "AsText(" + geometryColumnName + ") WktGeometry FROM "
              + tableName + " e " + condition; 
      }
      else if (dbConn.getClass().getSimpleName().contains("DB2"))
      {    
      //IBM DB2
      sql = "SELECT e." + labelColumnName + " e , " + auxColumns
    		  + "db2gse.ST_AsText(" + geometryColumnName + ") WktGeometry FROM "
              + tableName + " e " + condition; 
      }
    
      //Execute SQL query in the DBMS and fetch all results
      rs = dbConn.executeQuery(sql);

      //Iterate through all records
      while (rs.next()) 
      {
        String wkt = rs.getString("WktGeometry");

        //Parse geometric representation
       	parseWKT2RDF(resource, rs.getString("e"), wkt);
        
        //Process non-spatial attributes for name and type
        if ((!classColumnName.trim().equals("")) && (!nameColumnName.trim().equals("")))
        	handleNonGeometricAttributes(resource, rs.getString("e"), rs.getString(nameColumnName), rs.getString(classColumnName));
        
        //Notify progress
        if (numRec%1000 ==0)
       	 System.out.println(UtilsLib.getGMTime() + " Processed " +  numRec + " records..." + "\r");
        
        numRec++;
      }

    //Measure execution time
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Parsing completed for " + (numRec-1) + " records in " + dt + " ms.");
    System.out.println(UtilsLib.getGMTime() + " Starting to write triplets to file...");
    
    //Count the number of statements
    long numStmt = dtr.model.listStatements().toSet().size();
    
    //Export model to a suitable format
    FileOutputStream out = new FileOutputStream(outputFile);
    dtr.model.write(out, outFormat);  
    
    //Final notification
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Process concluded in " + dt + " ms. " + numStmt + " triples successfully exported to " + outFormat + " file: " + outputFile + ".");
  }


  /**
   * 
   * Handling non-spatial attributes (CURRENTLY supporting 'name' and 'type' attributes only)
   */
  public void handleNonGeometricAttributes(String resType, String featureAttribute, String featureName, String featureClass) throws UnsupportedEncodingException, FileNotFoundException 
  {
	    try 
	    {
	        if (!featureAttribute.equals(ignoreStr)) 
	        {
	          String encodingType =
	                  URLEncoder.encode(resType,
	                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                  REPLACEMENT);
	          String encodingResource =
	                  URLEncoder.encode(featureAttribute,
	                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                  REPLACEMENT);
	          String aux = encodingType + SEPARATOR + encodingResource;
	 
	          //Insert literal for name (name of feature)
	          if ((!featureName.equals(ignoreStr)) && (!featureName.equals("")))  //NOT NULL values only
	          {
	        	  insertResourceNameLiteral(
	        			  dtr.nsgeoresource + aux,
	        			  dtr.nsgeoresource + Constants.NAME,
	        			  featureName, 
	        			  defaultLang );
	          }
	          
	          //Insert literal for class (type of feature)
	          if ((!featureClass.equals(ignoreStr)) && (!featureClass.equals("")))  //NOT NULL values only
	          {
	        	  encodingResource =
	                      URLEncoder.encode(featureClass,
	                                        UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                      REPLACEMENT);
	              //Type according to application schema
	              insertResourceTypeResource(
	            		  dtr.nsgeoresource + aux,
	            		  dtr.nsgeoresource + encodingResource);
	          
	          }
	        }
	    }
	    catch(Exception e) {}
}

  
  /**
   * 
   * Convert WKT representation of a geometry into suitable triples
   */
  private void parseWKT2RDF(String t, String resource, String s) 
  {
    try {

    	if (transform != null)
    	{
	      Geometry o = reader.read(s);
	      
	      //Attempt to transform geometry into the target CRS
	        try {
				o = JTS.transform(o, transform);
			} catch (Exception e) {
				e.printStackTrace();
			}
	        
		   //Get WKT representation
		   s = o.toText();
    	}
    		
      String encType = URLEncoder.encode(t, "utf-8").replace("+", REPLACEMENT);
      String encResource = URLEncoder.encode(resource, "utf-8").replace("+", REPLACEMENT);
      String aux = encType + "_" + encResource;

      insertResourceTypeResource(dtr.nsgeoresource + aux, dtr.nsgeoresource
                                   + URLEncoder.encode(t, "utf-8").replace("+", REPLACEMENT));
      insertLabelResource(dtr.nsgeoresource + aux, resource, dtr.defaultLang);

      //Distinguish geometric representation according to the target store (e.g., Virtuoso, GeoSPARQL compliant etc.)
      if (targetStore.equalsIgnoreCase("wgs84_pos"))
    	  insertWGS84Point(aux, s);
      else if (targetStore.equalsIgnoreCase("Virtuoso"))
    	  insertVirtuosoPoint(aux, s);
      else
    	  insertWKTGeometry(aux, s);
      
      //Type according to GeoSPARQL feature
      insertResourceTypeResource(
    		  dtr.nsgeoresource + aux,
              dtr.nsgeontology + Constants.FEATURE );
      
    } catch (Exception e) {
      System.out.println(e.getMessage());
    }

  }


  /**
   * 
   * Insert a typical WKT geometry into the Jena model (suitable for GeoSPARQL compliant stores)
   */
  private void insertWKTGeometry(String resource, String wkt) 
  {
	  //Detect geometry type from the WKT representation (i.e., getting the text before parentheses)
	  String geomType = " ";
	  int a = wkt.indexOf("(");
	  if (a>0)
		  geomType = wkt.substring(0, a).trim();
	  
		insertResourceTriplet(dtr.nsgeoresource + resource, URLConstants.NS_GEO + "hasGeometry",
				dtr.nsgeoresource + UtilsConstants.FEAT + resource); 
		        
	    insertResourceTypeResource(dtr.nsgeoresource + UtilsConstants.FEAT + resource,
		           URLConstants.NS_SF + geomType);
    
	    insertLiteralTriplet(
    		dtr.nsgeoresource + UtilsConstants.FEAT + resource,
            URLConstants.NS_GEO + Constants.WKT,
            wkt, 
            URLConstants.NS_GEO + Constants.WKTLiteral);
  }


  /**
   * 
   * Insert a Point geometry according to Virtuoso RDF specifics into the Jena model
   */
  private void insertVirtuosoPoint(String resource, String pointWKT) 
  {  
    insertLiteralTriplet(
        dtr.nsgeoresource + resource,
        Constants.NSPOS + Constants.GEOMETRY,
        pointWKT,
        Constants.NSVIRT + Constants.GEOMETRY
        );
 
  }
  
  /**
   * 
   * Insert a Point geometry according to WGS84 Geoposition RDF vocabulary into the Jena model
   */
  private void insertWGS84Point(String resource, String pointWKT) 
  {
    //Clean point WKT so as to retain its numeric coordinates only
	String[] parts = pointWKT.replace("POINT (","").replace(")","").split(BLANK);
	 
    insertLiteralTriplet(
    	dtr.nsgeoresource + resource,
        Constants.NSPOS + Constants.LONGITUDE,
        parts[0],     //X-ordinate as a property
        Constants.NSXSD + "decimal"
        );
    
    insertLiteralTriplet(
    		dtr.nsgeoresource + resource,
            Constants.NSPOS + Constants.LATITUDE,
            parts[1],   //Y-ordinate as a property
            Constants.NSXSD + "decimal"
            );
 
  }
  
  /**
   * 
   * Insert a triple for the 'name' attribute of a feature
   */
  private void insertResourceNameLiteral(String s, String p, String o, String lang) 
  {
	  	Resource resource = model.createResource(s);
	    Property property = model.createProperty(p);
	    if (lang != null) {
	      Literal literal = model.createLiteral(o, lang);
	      resource.addLiteral(property, literal);
	    } else {
	      resource.addProperty(property, o);
	    }
	  }
  
  
  /**
   * 
   * Insert a triple for the 'type' (i.e., class or characterization attribute) of a feature
   */
  private void insertResourceTypeResource(String r1, String r2) 
  {
    Resource resource1 = model.createResource(r1);
    Resource resource2 = model.createResource(r2);
    model.add(resource1, RDF.type, resource2);
  }

  /**
   * 
   * Insert a triple for a literal value
   */
  private void insertLiteralTriplet(String s, String p, String o, String x) 
  {
    Resource resourceGeometry = model.createResource(s);
    Property property = model.createProperty(p);
    if (x != null) {
      Literal literal = model.createTypedLiteral(o, x);
      resourceGeometry.addLiteral(property, literal);
    } else {
      resourceGeometry.addProperty(property, o);
    }
  }

  /**
   * 
   * Handle resource triples
   */
  private void insertResourceTriplet(String s, String p, String o) {
    Resource resourceGeometry = model.createResource(s);
    Property property = model.createProperty(p);
    Resource resourceGeometry2 = model.createResource(o);
    resourceGeometry.addProperty(property, resourceGeometry2);
  }

  /**
   * 
   * Insert a resource for a label
   */
  private void insertLabelResource(String resource, String label, String lang) {
    Resource resource1 = model.createResource(resource);
    model.add(resource1, RDFS.label, model.createLiteral(label, lang));
  }


}
