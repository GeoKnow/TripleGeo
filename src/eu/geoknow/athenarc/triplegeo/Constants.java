/*
 * Constants.java	version 1.0   8/2/2013
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

/**
 * @author 2012 jonbaraq
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * Modified by: Kostas Patroumpas, 24/5/2013
 */

public class Constants {
  //Alias for most common namespaces
  public static final String NSGEO = "http://www.opengis.net/ont/geosparql#";
  public static final String NSSF =  "http://www.opengis.net/ont/sf#";
  public static final String NSGML = "http://loki.cae.drexel.edu/~wbs/ontology/2004/09/ogc-gml#";
  public static final String NSXSD = "http://www.w3.org/2001/XMLSchema#";
  public static final String NSPOS = "http://www.w3.org/2003/01/geo/wgs84_pos#";
  public static final String NSVIRT = "http://www.openlinksw.com/schemas/virtrdf#";

  //alias for most common tags
  public static final String GEOMETRY = "Geometry";
  public static final String FEATURE = "Feature";
  public static final String LINE_STRING = "LineString";
  public static final String MULTI_LINE_STRING = "MultiLineString";
  public static final String POLYGON = "Polygon";
  public static final String MULTI_POLYGON = "MultiPolygon";
  public static final String POINT = "Point";
  public static final String LATITUDE = "lat";
  public static final String LONGITUDE = "long";
  public static final String GML = "gml";
  public static final String WKT = "asWKT";
  public static final String WKTLiteral = "wktLiteral";
  public static final String NAME = "name";
  public static final String TYPE = "type";
}