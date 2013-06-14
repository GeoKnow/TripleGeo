/*
 * @(#) ShpConnector.java 	 version 1.0   12/6/2013
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
package eu.geoknow.athenarc.triplegeo.shape;

import com.hp.hpl.jena.datatypes.xsd.XSDDatatype;
import com.hp.hpl.jena.rdf.model.Literal;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Property;
import com.hp.hpl.jena.rdf.model.RDFWriter;
import com.hp.hpl.jena.rdf.model.Resource;
import com.hp.hpl.jena.tdb.TDBFactory;
import com.hp.hpl.jena.vocabulary.RDF;
import com.hp.hpl.jena.vocabulary.RDFS;
//import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Geometry;
//import com.vividsolutions.jts.geom.LineString;
import com.vividsolutions.jts.geom.MultiLineString;
import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.geom.Point;
//import com.vividsolutions.jts.geom.Polygon;
import eu.geoknow.athenarc.triplegeo.Constants;
import eu.geoknow.athenarc.triplegeo.utils.Configuration;
import eu.geoknow.athenarc.triplegeo.utils.UtilsConstants;
import eu.geoknow.athenarc.triplegeo.utils.UtilsLib;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.geotools.data.DataStore;
import org.geotools.data.DataStoreFinder;
import org.geotools.data.FeatureSource;
import org.geotools.factory.Hints;
import org.geotools.feature.FeatureCollection;
import org.geotools.feature.FeatureIterator;
import org.geotools.feature.simple.SimpleFeatureImpl;
import org.geotools.referencing.CRS;
import org.geotools.referencing.ReferencingFactoryFinder;
//import org.opengis.geometry.MismatchedDimensionException;
//import org.opengis.referencing.FactoryException;
//import org.opengis.referencing.NoSuchAuthorityCodeException;
import org.opengis.referencing.crs.CRSAuthorityFactory;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.MathTransform;
//import org.opengis.referencing.operation.TransformException;
import org.geotools.geometry.jts.JTS;

/**
 * Class to convert shapefiles to RDF.
 *
 * @author jonbaraq
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * Modified by: Kostas Patroumpas, 8/2/2013
 * Modified: 6/3/2013, added support for transformation from a given CRS to WGS84
 * Modified: 15/3/2013, added support for exporting custom geometries to (1) Virtuoso RDF and (2) according to WGS84 Geopositioning RDF vocabulary  
 * Last modified by: Kostas Patroumpas, 12/6/2013
 */

public class ShpConnector {

  private static final Logger LOG = Logger.getLogger(ShpConnector.class.getName());

  private static final String STRING_TO_REPLACE = "+";
  private static final String REPLACEMENT = "%20";
  private static final String SEPARATOR = "_";
  private static final String BLANK = " ";

  private Model model;
  private Configuration configuration;
  private FeatureCollection featureCollection;
  private MathTransform transform = null;

  public ShpConnector(Configuration configuration) throws IOException 
  {
    this.configuration = configuration;
    model = getModelFromConfiguration(configuration);
    featureCollection = getShapeFileFeatureCollection(configuration.inputFile, configuration.featureString);
    System.setProperty("org.geotools.referencing.forceXY", "true");
  }

  /**
   * Loads the shape file from the configuration path and returns the
   * feature collection associated according to the configuration.
   *
   * @param shapePath with the path to the shapefile.
   * @param featureString with the featureString to filter.
   *
   * @return FeatureCollection with the collection of features filtered.
   */
  private FeatureCollection getShapeFileFeatureCollection(String shapePath, String featureString) throws IOException 
  {
    File file = new File(shapePath);

    // Create the map with the file URL to be passed to DataStore.
    Map map = new HashMap();
    try {
      map.put("url", file.toURL());
    } catch (MalformedURLException ex) {
      Logger.getLogger(ShpConnector.class.getName()).log(Level.SEVERE, null, ex);
    }
    if (map.size() > 0) {
      DataStore dataStore = DataStoreFinder.getDataStore(map);
      FeatureSource featureSource = dataStore.getFeatureSource(featureString);
      return featureSource.getFeatures();
    }
    return null;
  }

  /**
   * Returns a Jena RDF model populated with the params from the configuration.
   *
   * @param configuration with all the configuration parameters.
   *
   * @return a Jena RDF model populated with the params from the configuration.
   */
  private Model getModelFromConfiguration(Configuration configuration) 
  {
    UtilsLib.removeDirectory(configuration.tmpDir);
    Model tmpModel = TDBFactory.createModel(configuration.tmpDir);
    tmpModel.removeAll();
    tmpModel.setNsPrefix("geontology", configuration.ontologyNS);
    tmpModel.setNsPrefix("georesource", configuration.nsUri);
    tmpModel.setNsPrefix("geo", URLConstants.NS_GEO);
    tmpModel.setNsPrefix("sf", URLConstants.NS_SF);
    tmpModel.setNsPrefix("dc", URLConstants.NS_DC);
    tmpModel.setNsPrefix("xsd", URLConstants.NS_XSD);
    
    //Check if a coordinate transform should be made
    if (configuration.sourceCRS != null)
	    try {
	        boolean lenient = true; // allow for some error due to different datums
	        
	        Hints hints = new Hints(Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE);
	        CRSAuthorityFactory factory = ReferencingFactoryFinder.getCRSAuthorityFactory("EPSG", hints);
	        CoordinateReferenceSystem sourceCRS = factory.createCoordinateReferenceSystem(configuration.sourceCRS);
	        CoordinateReferenceSystem targetCRS = factory.createCoordinateReferenceSystem(configuration.targetCRS);    
	        transform = CRS.findMathTransform(sourceCRS, targetCRS, lenient);
	        System.out.println("Transformation will take place from " + configuration.sourceCRS + " to " + configuration.targetCRS + " reference system.");
	        
		} catch (Exception e) {
			e.printStackTrace();
		}
    else
    	System.out.println("No transformation will take place. Input data is expected in WGS84 reference system.");
  
    return tmpModel;
  }

  
 /**
   * 
   * Handling non-spatial attributes only
   **/
  public void handleNonGeometricAttributes(SimpleFeatureImpl feature) throws UnsupportedEncodingException, FileNotFoundException {

	    try 
	    {
	        String featureAttribute = "featureWithoutID";
	        String featureName = "featureWithoutName";
	        String featureClass = "featureWithoutClass";

	        //Feature id
	        if (feature.getAttribute(configuration.attribute) != null) {
	          featureAttribute = feature.getAttribute(configuration.attribute).toString();
	        }

	        //Feature name
	        if (feature.getAttribute(configuration.featname) != null) {
	          featureName = feature.getAttribute(configuration.featname).toString();
	        }
	        //Feature classification
	        if (feature.getAttribute(configuration.featclass) != null) {
	          featureClass = feature.getAttribute(configuration.featclass).toString();
	        }
	   
	        if (!featureAttribute.equals(configuration.ignore)) 
	        {
	          String encodingType =
	                  URLEncoder.encode(configuration.type,
	                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                  REPLACEMENT);
	          String encodingResource =
	                  URLEncoder.encode(featureAttribute,
	                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                  REPLACEMENT);
	          String aux = encodingType + SEPARATOR + encodingResource;
	 
	          //Insert literal for name (name of feature)
	          if ((!featureName.equals(configuration.ignore)) && (!featureName.equals("")))  //NOT NULL values only
	          {
	        	  insertResourceNameLiteral(
	        			  configuration.nsUri + aux,
	        			  configuration.nsUri + Constants.NAME,
	        			  featureName, 
	        			  configuration.defaultLang );
	          }
	          
	          //Insert literal for class (type of feature)
	          if ((!featureClass.equals(configuration.ignore)) && (!featureClass.equals("")))  //NOT NULL values only
	          {
	        	  encodingResource =
	                      URLEncoder.encode(featureClass,
	                                        UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
	                                                                      REPLACEMENT);
	              //Type according to application schema
	              insertResourceTypeResource(
	                      configuration.nsUri + aux,
	                      configuration.nsUri + encodingResource);
	          
	          }
	        }
	    }
	    catch(Exception e) {}

}

  
  /**
   * 
   * Writes the RDF model into a file
   */
  public void writeRdfModel() throws UnsupportedEncodingException, FileNotFoundException 
  {
    FeatureIterator iterator = featureCollection.features();
    int position = 0;
    long t_start = System.currentTimeMillis();
    long dt = 0;
    try 
    {
      System.out.println(UtilsLib.getGMTime() + " Started processing features...");
 
      while(iterator.hasNext()) {
        SimpleFeatureImpl feature = (SimpleFeatureImpl) iterator.next();
        Geometry geometry = (Geometry) feature.getDefaultGeometry();

        //Attempt to transform geometry into the target CRS
        if (transform != null)
	        try {
				geometry = JTS.transform(geometry, transform);
			} catch (Exception e) {
				e.printStackTrace();
			}

        String featureAttribute = "featureWithoutID";

        //Process non-spatial attributes for name and type
        handleNonGeometricAttributes(feature);
        		
        if (feature.getAttribute(configuration.attribute) != null) {
          featureAttribute = feature.getAttribute(configuration.attribute).toString();
        }

        if (!featureAttribute.equals(configuration.ignore)) 
        {
          String encodingType =
                  URLEncoder.encode(configuration.type,
                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
                                                                  REPLACEMENT);
          String encodingResource =
                  URLEncoder.encode(featureAttribute,
                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
                                                                  REPLACEMENT);
          String aux = encodingType + SEPARATOR + encodingResource;
       
          //Type according to application schema
          insertResourceTypeResource(
                  configuration.nsUri + aux,
                  configuration.nsUri + URLEncoder.encode(
                          configuration.type, UtilsConstants.UTF_8).replace(
                                  STRING_TO_REPLACE, REPLACEMENT));
          
          //Type according to GeoSPARQL feature
          insertResourceTypeResource(
                  configuration.nsUri + aux,
                  configuration.ontologyNS + Constants.FEATURE );
          
          insertLabelResource(configuration.nsUri + aux,
                              featureAttribute, configuration.defaultLang);
          if (geometry.getGeometryType().equals(Constants.POINT)) {
            insertPoint(aux, geometry);
          } else if (geometry.getGeometryType().equals(Constants.LINE_STRING)) {
            insertLineString(aux, geometry);
          } else if (geometry.getGeometryType().equals(Constants.POLYGON)) {
            insertPolygon(aux, geometry);
          } else if (geometry.getGeometryType().equals(Constants.MULTI_POLYGON)) {
            MultiPolygon multiPolygon = (MultiPolygon) geometry;
            for (int i = 0; i < multiPolygon.getNumGeometries(); ++i) {
              Geometry tmpGeometry = multiPolygon.getGeometryN(i);
              if (tmpGeometry.getGeometryType().equals(Constants.POLYGON)) {
                insertPolygon(aux, tmpGeometry);
              } else if (tmpGeometry.getGeometryType().equals(Constants.LINE_STRING)) {
                insertLineString(aux, tmpGeometry);
              }
            }
          } else if (geometry.getGeometryType().equals(Constants.MULTI_LINE_STRING)) {
            MultiLineString multiLineString = (MultiLineString) geometry;
            for (int i = 0; i < multiLineString.getNumGeometries(); ++i) {
              Geometry tmpGeometry = multiLineString.getGeometryN(i);
              if (tmpGeometry.getGeometryType().equals(Constants.POLYGON)) {
                insertPolygon(aux, tmpGeometry);
              } else if (tmpGeometry.getGeometryType().equals(Constants.LINE_STRING)) {
                insertLineString(aux, tmpGeometry);
              }
            }
          }
        } else {
          LOG.log(Level.INFO, "writeRdfModel: Not processing feature attribute in position {0}", position);
        }
        
        if (position%1000 ==0)
        	 System.out.print(UtilsLib.getGMTime() + " Processed " +  position + " records..." + "\r");
        ++position;
      }
    }
    finally {
      iterator.close();
    }
    
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Parsing completed for " + position + " records in " + dt + " ms.");
    System.out.println(UtilsLib.getGMTime() + " Starting to write triplets to file...");
    
    //Count the number of statements
    long numStmt = model.listStatements().toSet().size();
    
    //Export model to a suitable format
    FileOutputStream out = new FileOutputStream(configuration.outputFile);
    model.write(out, configuration.outFormat);
    
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Process concluded in " + dt + " ms. " + numStmt + " triples successfully exported to " + configuration.outFormat + " file: " + configuration.outputFile + ".");
  }

  
  /**
   * Export POINT geometries according to Virtuoso RDF specs
   * 
   * @param specs should indicate either 'Virtuoso' or 'wgs84_pos'
   */
  public void writePointRdfModel(String specs) throws UnsupportedEncodingException, FileNotFoundException 
  {
    FeatureIterator iterator = featureCollection.features();
    int position = 0;
    long t_start = System.currentTimeMillis();
    long dt = 0;
    
    try 
    {
      System.out.println(UtilsLib.getGMTime() + " Started processing features...");
        
      while(iterator.hasNext()) {
        SimpleFeatureImpl feature = (SimpleFeatureImpl) iterator.next();
        Geometry geometry = (Geometry) feature.getDefaultGeometry();

        //Attempt to transform geometry into the target CRS
        if (transform != null)
	        try {
				geometry = JTS.transform(geometry, transform);
			} catch (Exception e) {
				e.printStackTrace();
			}

        String featureAttribute = "featureWithoutID";

        //Process non-spatial attributes for name and type
        handleNonGeometricAttributes(feature);
        
        if (feature.getAttribute(configuration.attribute) != null) {
          featureAttribute = feature.getAttribute(configuration.attribute).toString();
        }

        if (!featureAttribute.equals(configuration.ignore)) 
        {
          String encodingType =
                  URLEncoder.encode(configuration.type,
                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
                                                                  REPLACEMENT);
          String encodingResource =
                  URLEncoder.encode(featureAttribute,
                                    UtilsConstants.UTF_8).replace(STRING_TO_REPLACE,
                                                                  REPLACEMENT);
          String aux = encodingType + SEPARATOR + encodingResource;
        
          //Type according to application schema
          insertResourceTypeResource(
                  configuration.nsUri + aux,
                  configuration.nsUri + URLEncoder.encode(
                          configuration.type, UtilsConstants.UTF_8).replace(
                                  STRING_TO_REPLACE, REPLACEMENT));
          
          //Label using the given attribute (usually an id)
          insertLabelResource(configuration.nsUri + aux,
                              featureAttribute, configuration.defaultLang);

          //Point geometries ONLY
          if (geometry.getGeometryType().equals(Constants.POINT)) 
          {
        	  if (specs.equals("Virtuoso"))
        		  insertVirtuosoPoint(aux, geometry);
        	  else if (specs.equals("wgs84_pos"))
        		  insertWGS84Point(aux, geometry);  	  
          }
        } else {
          LOG.log(Level.INFO, "writeRdfModel: Not processing feature attribute in position {0}", position);
        }
        
        if (position%1000 ==0)
        	 System.out.print(UtilsLib.getGMTime() + " Processed " +  position + " records..." + "\r");
        ++position;
      }
    }
    finally {
      iterator.close();
    }
    
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Parsing completed for " + position + " records in " + dt + " ms.");
    System.out.println(UtilsLib.getGMTime() + " Starting to write triplets to file...");
    
    //Count the number of statements
    long numStmt = model.listStatements().toSet().size();
    
    //Export model to a suitable format
    FileOutputStream out = new FileOutputStream(configuration.outputFile);
    model.write(out, configuration.outFormat);
    
    dt = System.currentTimeMillis() - t_start;
    System.out.println(UtilsLib.getGMTime() + " Process concluded in " + dt + " ms. " + numStmt + " triples successfully exported to " + configuration.outFormat + " file: " + configuration.outputFile + ".");
 }

 
  //
  /**
   * Handle Polyline geometry according to GeoSPARQL standard
   * 
   */
  private void insertLineString(String resource, Geometry geo) {
	          
	insertResourceTriplet(configuration.nsUri + resource, URLConstants.NS_GEO + "hasGeometry",
	           configuration.nsUri + UtilsConstants.FEAT + resource); 
	        
    insertResourceTypeResource(configuration.nsUri + UtilsConstants.FEAT + resource,
	           URLConstants.NS_SF + Constants.LINE_STRING);

    insertLiteralTriplet(
            configuration.nsUri + UtilsConstants.FEAT + resource,
            URLConstants.NS_GEO + Constants.WKT,
            geo.toText(), 
            URLConstants.NS_GEO + Constants.WKTLiteral
            );
  }


  /**
   * 
   * Handle Polygon geometry according to GeoSPARQL standard
   */
  private void insertPolygon(String resource, Geometry geo) throws UnsupportedEncodingException 
  {
		insertResourceTriplet(configuration.nsUri + resource, URLConstants.NS_GEO + "hasGeometry",
		           configuration.nsUri + UtilsConstants.FEAT + resource); 
		        
	    insertResourceTypeResource(configuration.nsUri + UtilsConstants.FEAT + resource,
		           URLConstants.NS_SF + Constants.POLYGON);
	    
	    insertLiteralTriplet(
    		configuration.nsUri + UtilsConstants.FEAT + resource,
            URLConstants.NS_GEO + Constants.WKT,
            geo.toText(), 
            URLConstants.NS_GEO +  Constants.WKTLiteral);
  }

  /**
   * 
   * Handle resource type
   */
  private void insertResourceTypeResource(String r1, String r2) 
  {
    Resource resource1 = model.createResource(r1);
    Resource resource2 = model.createResource(r2);
    model.add(resource1, RDF.type, resource2);
  }
  
  /**
   * 
   * Handle triples for string literals
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
 * Handle string literals for 'name' attribute
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
   * Handle label triples
   */
  private void insertLabelResource(String resource, String label, String lang) 
  {
    Resource resource1 = model.createResource(resource);
    model.add(resource1, RDFS.label, model.createLiteral(label, lang));
  }

  
  /**
   * 
   * Point geometry according to GeoSPARQL standard
   */
  private void insertPoint(String resource, Geometry geo) 
  {
    insertResourceTriplet(
        configuration.nsUri + resource, URLConstants.NS_GEO + "hasGeometry",
        configuration.nsUri + UtilsConstants.FEAT + resource);
    insertResourceTypeResource(
       configuration.nsUri + UtilsConstants.FEAT + resource,
       URLConstants.NS_SF + Constants.POINT); 
    insertLiteralTriplet(
        configuration.nsUri + UtilsConstants.FEAT + resource,
        URLConstants.NS_GEO + Constants.WKT,
        geo.toText(),
        URLConstants.NS_GEO + Constants.WKTLiteral
        );
  }


  /**
   * 
   * Point geometry according to Virtuoso RDF specifics
   */
  private void insertVirtuosoPoint(String resource, Geometry geo) 
  {
    insertLiteralTriplet(
        configuration.nsUri + resource,
        Constants.NSPOS + Constants.GEOMETRY,
        geo.toText(),
        Constants.NSVIRT +  Constants.GEOMETRY
        );
 
  }
  
  /**
   * 
   * Point geometry according to WGS84 Geoposition RDF vocabulary
   */
  private void insertWGS84Point(String resource, Geometry geo) 
  {
	Point p = (Point) geo;
    insertLiteralTriplet(
        configuration.nsUri + resource,
        Constants.NSPOS + Constants.LONGITUDE,
        String.valueOf(p.getX()),     //X-ordinate as a property
        Constants.NSXSD + "decimal"
        );
    
    insertLiteralTriplet(
            configuration.nsUri + resource,
            Constants.NSPOS + Constants.LATITUDE,
            String.valueOf(p.getY()),   //Y-ordinate as a property
            Constants.NSXSD + "decimal"
            );
 
  }
  
}
