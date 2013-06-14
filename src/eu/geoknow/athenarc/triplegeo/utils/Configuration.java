/*
 * @(#) Configuration.java 	 version 1.0   5/6/2013
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
package eu.geoknow.athenarc.triplegeo.utils;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Class to parse configuration files used in the library.
 *
 * @author jonathangsc
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * Modified by: Kostas Patroumpas, 5/6/2013
 */
public final class Configuration {

  public String path;
  public String inputFile;
  public String tmpDir;
  public String outputFile;
  public String outFormat;
  public String targetStore;
  public String resourceName;
  public String nsPrefix = "georesource";
  public String ontologyNSPrefix = "geontology";
  public String ontologyNS = "http://www.opengis.net/ont/geosparql#";
  public String nsUri = "http://geoknow.eu/resource/";
  public String pointType = "http://www.opengis.net/ont/sf#Point";
  public String lineStringType = "http://www.opengis.net/ont/sf#LineString";
  public String polygonType = "http://www.opengis.net/ont/sf#Polygon";
  public String defaultLang = "en";
  public String featureString;
  public String attribute;
  public String ignore;
  public String type;
  public String featname;
  public String featclass;
  public String sourceCRS;
  public String targetCRS;


  private static final Logger LOG = Logger.getLogger(Configuration.class.getName());

  public Configuration(String path) 
  {
    this.path = path;
    buildConfiguration();
    
  }

  /**
   * Loads the configuration
   */
  private void buildConfiguration() {
    Properties properties = new Properties();
    try {
      properties.load(new FileInputStream(path));
    } catch (IOException io) {
      LOG.log(Level.WARNING, "Problems loading configuration file: {0}", io);
    }
    initializeParameters(properties);
  }

  /**
   * Initializes all the parameters from the configuration.
   *
   * @param properties with the properties object.
   */
  private void initializeParameters(Properties properties) {
	  
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("inputFile"))) {
		 inputFile = properties.getProperty("inputFile");
	 }
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("tmpDir"))) {
		 tmpDir = properties.getProperty("tmpDir");
	 }
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("outputFile"))) {
		 outputFile = properties.getProperty("outputFile");
	 }
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("format"))) {
		 outFormat = properties.getProperty("format");
	 }
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("targetStore"))) {
		 targetStore = properties.getProperty("targetStore");
	 }
	 if (!UtilsLib.isNullOrEmpty(properties.getProperty("resourceName"))) {
		 resourceName = properties.getProperty("resourceName");
	 }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("nsPrefix"))) {
      nsPrefix = properties.getProperty("nsPrefix");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("nsURI"))) {
      nsUri = properties.getProperty("nsURI");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("ontologyNSPrefix"))) {
      ontologyNSPrefix = properties.getProperty("ontologyNSPrefix");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("ontologyNS"))) {
      ontologyNS = properties.getProperty("ontologyNS");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("pointType"))) {
      pointType = properties.getProperty("pointType");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("linestringType"))) {
      lineStringType = properties.getProperty("linestringType");
    }

    if (!UtilsLib.isNullOrEmpty(properties.getProperty("polygonType"))) {
      polygonType = properties.getProperty("polygonType");
    }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("defaultLang"))) {
      defaultLang = properties.getProperty("defaultLang");
    }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("featureString"))) {
    	featureString = properties.getProperty("featureString");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("attribute"))) {
    	attribute = properties.getProperty("attribute");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("class"))) {
    	featclass = properties.getProperty("class");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("name"))) {
    	featname = properties.getProperty("name");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("ignore"))) {
    	ignore = properties.getProperty("ignore");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("type"))) {
        type = properties.getProperty("type");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("sourceRS"))) {
    	sourceCRS = properties.getProperty("sourceRS");
      }
    if (!UtilsLib.isNullOrEmpty(properties.getProperty("targetRS"))) {
    	targetCRS = properties.getProperty("targetRS");
      }

  }

}
