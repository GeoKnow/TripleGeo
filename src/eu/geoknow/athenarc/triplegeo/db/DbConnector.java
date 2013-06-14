/*
 * @(#) Connector.java	version 1.0   8/2/2013
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

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Set;

/**
 * Interface that defines all methods to be implemented by a JDBC Database connector.
 *
 * @author jonbaraq
 * initially implemented for geometry2rdf utility (source: https://github.com/boricles/geometry2rdf/tree/master/Geometry2RDF)
 * @version 2nd Feb 2012.
 * Modified by: Kostas Patroumpas, 12/6/2013
 */
public interface DbConnector {

  /**
   * Returns the Database URL.
   *
   * @return databaseUrl with the URL of the database.
   */
  public String getDatabaseUrl();

  /**
   * Returns the user entities of the DatabaseMetadata.
   *
   * @return set of strings with the use entities.
   * @throws SQL Exception.
   */
  public Set<String> getUserEntities(DatabaseMetaData databaseMetadata)
         throws SQLException;

  /**
   * Returns the result of the query executed against the database.
   *
   * @param query - String with the query.
   * @return resultset with the result of the query.
   */
  public ResultSet executeQuery(String query);

  /**
   * Returns the table name given a string Item.
   *
   * @param fromItem
   * @return tableName
   */
  public String getTable(String fromItem);

  /**
   * Closes database connection.
   */
  public void dispose();

}
