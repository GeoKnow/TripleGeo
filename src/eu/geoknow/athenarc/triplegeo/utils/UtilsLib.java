/*
 * @(#) UtilsLib.java 	 version 1.1   10/4/2014
 *
 * Copyright (C) 2013-2014 Institute for the Management of Information Systems, Athena RC, Greece.
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

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 * Utils Library for TripleGeo
 *
 * @author jonathangsc 
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * @version 2nd Feb 2012.
 * Modified by: Kostas Patroumpas, 7/4/2014
 */
public class UtilsLib {

  /**
   * Returns true if the parameter is null or empty. false otherwise.
   *
   * @param text
   * @return true if the parameter is null or empty.
   */
  public static boolean isNullOrEmpty(String text) {
    if (text == null || text.equals("")) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Returns a String with the content of the InputStream
   * @param is with the InputStream
   * @return string with the content of the InputStream
   * @throws IOException
   */
  public static String convertInputStreamToString(InputStream is)
          throws IOException {
    if (is != null) {
      StringBuilder sb = new StringBuilder();
      String line;
      try {
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(is, UtilsConstants.UTF_8));
        while ((line = reader.readLine()) != null) {
          sb.append(line).append(UtilsConstants.LINE_SEPARATOR);
        }
      } finally {
        is.close();
      }
      return sb.toString();
    } else {
      return "";
    }
  }

  /**
   * Returns am InputStream with the parameter.
   *
   * @param string
   * @return InputStream with the string value.
   */
  public static InputStream convertStringToInputStream(String string) {
    InputStream is = null;
    try {
      is = new ByteArrayInputStream(string.getBytes("UTF-8"));
    } catch (UnsupportedEncodingException e) {
      e.printStackTrace();
    }
    return is;
  }


  /**
   * Get the current GMT time for user notification.
   *
   * @return timestamp value as string.
   */
	public static String getGMTime()
	{
		SimpleDateFormat gmtDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		gmtDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));

		//Current Date Time in GMT
		return gmtDateFormat.format(new java.util.Date());
	}

/**
 * Removes all files from a given folder
 */
	public static void removeDirectory(String path) 
	{
		    File filePath = new File(path);
		    if (filePath.exists()) {
		      for (String fileInDirectory : filePath.list()) {
		        File tmpFile = new File(path + "/" + fileInDirectory);
		        tmpFile.delete();
		      }
		      filePath.delete();
		    }
	}
	
	/** 
     * Simple transformation method using Saxon XSLT 2.0 processor. 
     * @param sourcePath - Absolute path to source GML file. 
     * @param xsltPath - Absolute path to XSLT file. 
     * @param resultPath - Absolute path to the resulting RDF file. 
     */  
    public static void saxonTransform(String sourcePath, String xsltPath, String resultPath) {  
        TransformerFactory tFactory = TransformerFactory.newInstance();  
        try 
        {  
            Transformer transformer = tFactory.newTransformer(new StreamSource(new File(xsltPath)));  
            transformer.transform(new StreamSource(new File(sourcePath)), new StreamResult(new File(resultPath)));  
            System.out.println("XSLT transformation completed successfully.\nOutput writen into file: " + resultPath );
        } 
        catch (Exception e) {  e.printStackTrace();  }  
    } 
    
}
