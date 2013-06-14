/*
 * @(#) ShpToRdf.java	version 1.0   8/2/2013
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
 * Last modified by: Kostas Patroumpas, 12/6/2013
 */
public class ShpToRdf {
  public static void main(String [] args) throws IOException 
  {
	System.out.println("TripleGeo v1.0 Copyright (C) 2013 Institute for the Management of Information Systems, Athena RC, Greece.\nThis program comes with ABSOLUTELY NO WARRANTY. This is free software, distributed under GPL license.\nYou are welcome to redistribute it under certain conditions as mentioned in the accompanying LICENSE file.");
	
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
