/*
 * @(#) DbConstants.java	version 1.0   5/6/2013
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
package eu.geoknow.athenarc.triplegeo.db;

/**
 * Constants for database connections.
 *
 * @author boricles
 * @author jonbaraq
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * @version 2nd Feb 2012.
 * Modified by: Kostas Patroumpas, 5/6/2013
 */
public class DbConstants {

  // DB Types.
  public static final int MSACCESS = 0;
  public static final int MYSQL = 1;
  public static final int ORACLE = 2;
  public static final int POSTGRESQL = 3;
  public static final int DB2 = 4;

  // DB Drivers
  public static final String[] DRIVERS =
    {"sun.jdbc.odbc.JdbcOdbcDriver", "com.mysql.jdbc.Driver",
     "oracle.jdbc.driver.OracleDriver", "org.postgresql.Driver", "com.ibm.db2.jcc.DB2Driver"};

  public static final String[] DBMS = {"MSACCESS", "MYSQL", "ORACLE", "POSTGRESQL", "DB2"};
  public static final String[] BASE_URL = {"jdbc:odbc:", "jdbc:mysql:", "jdbc:oracle:thin:", "jdbc:postgresql:", "jdbc:db2:"};
  public static final String[] LEN_PRIMITIVE = {"len", "length", "len"};
  public static final String SEPARATOR = ".";

  public static final String[] TABLE_TYPES = {"TABLE"};

  public static final String TABLE_NAME = "TABLE_NAME";
}