/*
 * @(#) MetadataToRdf.java	version 1.1   10/4/2014
 *
 * Copyright (C) 2014 Institute for the Management of Information Systems, Athena RC, Greece.
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

import java.io.*;
import org.xml.sax.SAXException;

import eu.geoknow.athenarc.triplegeo.utils.UtilsLib;

/**
 * Entry point to convert geographic metadata compliant to ISO 19139 & INSPIRE  from XML files into RDF triples.
 * @author Kostas Patroumpas
 * Last modified by: Kostas Patroumpas, 10/4/2014
 */
public class MetadataToRdf 
{
	/**
     * Accept two arguments: the name of an XML file with geographic metadata, and the name of the resulting RDF file.
     * EXAMPLE: java -cp lib/*;TripleGeo.jar eu.geoknow.athenarc.triplegeo.MetadataToRdf ./data/samples.xml ./data/test1.rdf
     */
    public static void main(String[] args) throws IOException, SAXException 
    {
    	System.out.println("*********************************************************************\n*                      TripleGeo version 1.1                        *\n* Developed by the Institute for Management of Information Systems. *\n* Copyright (C) 2013-2014 Athena Research Center, Greece.           *\n* This program comes with ABSOLUTELY NO WARRANTY.                   *\n* This is FREE software, distributed under GPL license.             *\n* You are welcome to redistribute it under certain conditions       *\n* as mentioned in the accompanying LICENSE file.                    *\n*********************************************************************\n");
    	
        if (args.length != 2) {
            System.err.println("Usage:");
            System.err.println("  java " + MetadataToRdf.class.getName(  )
                    + " <metadataXML> <fileRDF>");
            System.exit(1);
        }

        String fileXML = args[0];    //input file
        String fileRDF = args[1];    //output file
        
        String fileXSLT = "./xslt/Metadata2RDF.xsl";   //Predefined XSLT stylesheet to be applied in transformation
        
        //Set saxon as transformer.  
        System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");  
  
        //simpleTransform("./data/samples.xml", "./xslt/Metadata2RDF.xsl", "./data/test1.rdf");  
        UtilsLib.saxonTransform(fileXML, fileXSLT, fileRDF);  
    }
        
}
