/*
 * @(#) ShpToRdf.java	version 1.1   2/6/2014
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
package eu.geoknow.athenarc.triplegeo;

import eu.geoknow.athenarc.triplegeo.shape.ShpConnector;
import eu.geoknow.athenarc.triplegeo.utils.Configuration;

//import java.io.FileInputStream;
import java.io.IOException;

/**
 * Entry point to convert shapefiles into RDF triples.
 * @author Kostas Patroumpas
 * Last modified by: Kostas Patroumpas, 2/6/2014
 */
public class ShpToRdf {
  public static void main(String [] args) throws IOException 
  {
	System.out.println("*********************************************************************\n*                      TripleGeo version 1.1                        *\n* Developed by the Institute for Management of Information Systems. *\n* Copyright (C) 2013-2014 Athena Research Center, Greece.           *\n* This program comes with ABSOLUTELY NO WARRANTY.                   *\n* This is FREE software, distributed under GPL license.             *\n* You are welcome to redistribute it under certain conditions       *\n* as mentioned in the accompanying LICENSE file.                    *\n*********************************************************************\n");
	
	//Specify properties file for shapefile conversion
    Configuration config = new Configuration(args[0]);     //Argument like "./bin/shp_options.conf"
    System.out.println("Output format is: " + config.outFormat);
    ShpConnector shpConverter = new ShpConnector(config);
    
    //Distinguish the type of the exported geometries
    if (config.targetStore.equalsIgnoreCase("GeoSPARQL"))
    	shpConverter.writeRdfModel();      			//Exporting all types of GeoSPARQL geometries, along with identifiers
    else
    	shpConverter.writePointRdfModel(config.targetStore);  //Exporting point geometries, no descriptive attributes. Set argument "wgs84_pos" or "Virtuoso"
  }

}
