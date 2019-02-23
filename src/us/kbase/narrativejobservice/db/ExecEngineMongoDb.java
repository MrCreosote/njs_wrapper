package us.kbase.narrativejobservice.db;

import java.io.IOException;
import java.net.UnknownHostException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import java.util.logging.Level;
import java.util.stream.Collectors;

import org.bson.BSONObject;
import org.bson.LazyBSONList;
import org.jongo.Jongo;
import org.jongo.MongoCollection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import us.kbase.common.mongo.GetMongoDB;
import us.kbase.common.mongo.exceptions.InvalidHostException;
import us.kbase.common.mongo.exceptions.MongoAuthException;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Lists;
import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.DuplicateKeyException;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientOptions;
import com.mongodb.MongoException;
import com.mongodb.ServerAddress;

public class ExecEngineMongoDb {
	private Jongo jongo;
	private DBCollection taskCol;
	private DBCollection logCol;
	private DBCollection propCol;
	private MongoCollection srvProps;

	private static final Map<String, MongoClient> HOSTS_TO_CLIENT = new HashMap<>();

	private static final String COL_EXEC_TASKS = "exec_tasks";
	private static final String PK_EXEC_TASKS = "ujs_job_id";
	private static final String COL_EXEC_LOGS = "exec_logs";
	private static final String PK_EXEC_LOGS = "ujs_job_id";
	private static final String COL_SRV_PROPS = "srv_props";
	private static final String PK_SRV_PROPS = "prop_id";
	private static final String SRV_PROPS_VALUE = "value";
	private static final String SRV_PROP_DB_VERSION = "db_version";

	private static final String DB_VERSION = "1.0";

	private static final ObjectMapper MAPPER = new ObjectMapper();
	
	// should really inject the DB, but worry about that later.
	public ExecEngineMongoDb(
			final String hosts,
			final String db,
			final String user,
			final String pwd)
			throws Exception {
		final DB mongo = getDB(hosts, db, user, pwd, 0, 10);
		taskCol = mongo.getCollection(COL_EXEC_TASKS);
		logCol = mongo.getCollection(COL_EXEC_LOGS);
		propCol = mongo.getCollection(COL_SRV_PROPS);
		jongo = new Jongo(mongo);
		srvProps = jongo.getCollection(COL_SRV_PROPS);
		// Indexing
		final BasicDBObject unique = new BasicDBObject("unique", true);
		taskCol.createIndex(new BasicDBObject(PK_EXEC_TASKS, 1), unique);
		logCol.createIndex(new BasicDBObject(PK_EXEC_LOGS, 1), unique);
		propCol.createIndex(new BasicDBObject(PK_SRV_PROPS, 1), unique);

		try {
			// at some point check that the db ver = sw ver
			propCol.insert(new BasicDBObject(PK_SRV_PROPS, SRV_PROP_DB_VERSION)
					.append(SRV_PROPS_VALUE, DB_VERSION));
		} catch (DuplicateKeyException e) {
			//version is already there so do nothing
		}
	}
	
	private Map<String, Object> toMap(final Object obj) {
		return MAPPER.convertValue(obj, new TypeReference<Map<String, Object>>() {});
	}
		
	private DBObject toDBObj(final Object obj) {
		return new BasicDBObject(toMap(obj));
	}
	
	private <T> T toObj(final DBObject dbo, final Class<T> clazz) {
		return dbo == null ? null : MAPPER.convertValue(toMapRec(dbo), clazz);
	}

	private Map<String, Object> toMapRec(final BSONObject dbo) {
		@SuppressWarnings("unchecked")
		final Map<String, Object> ret = (Map<String, Object>) cleanObject(dbo);
		return ret;
	}
	
	// this assumes there aren't BSONObjects embedded in standard object, which should
	// be the case for stuff returned from mongo
	
	// Unimplemented error for dbo.toMap()
	// dbo is read only
	// can't call convertValue() on dbo since it has a 'size' field outside of the internal map
	// and just weird shit happens when you do anyway
	private Object cleanObject(final Object dbo) {
		if (dbo instanceof LazyBSONList) {
			final List<Object> ret = new LinkedList<>();
			// don't stream, sometimes has issues with nulls
			for (final Object obj: (LazyBSONList) dbo) {
				ret.add(cleanObject(obj));
			}
			return ret;
		} else if (dbo instanceof BSONObject) {
			// can't stream because streams don't like null values at HashMap.merge()
			final BSONObject m = (BSONObject) dbo;
			final Map<String, Object> ret = new HashMap<>();
			for (final String k: m.keySet()) {
				if (!k.equals("_id")) {
					final Object v = m.get(k);
					ret.put(k, cleanObject(v));
				}
			}
			return ret;
		}
		return dbo;
	}

	public String[] getSubJobIds(String ujsJobId) throws Exception{
		// there should be a null/empty check for the ujs id here
		final DBCursor dbc = taskCol.find(
				new BasicDBObject("parent_job_id", ujsJobId),
				new BasicDBObject("ujs_job_id", 1));
		List<String> idList = new ArrayList<String>();
		for (final DBObject dbo: dbc) {
			idList.add((String) dbo.get("ujs_job_id"));
		}
		return idList.toArray(new String[idList.size()]);
	}

	public ExecLog getExecLog(String ujsJobId) throws Exception {
		// there should be a null/empty check for the ujs id here
		// should make these strings constants
		final DBObject log = logCol.findOne(
				new BasicDBObject(PK_EXEC_LOGS, ujsJobId),
				new BasicDBObject(PK_EXEC_LOGS, 1)
						.append("original_line_count", 1)
						.append("stored_line_count", 1));
		final ExecLog ret;
		if (log == null) {
			ret = null;
		} else {
			ret = new ExecLog();
			ret.setOriginalLineCount((Integer) log.get("original_line_count"));
			ret.setStoredLineCount((Integer) log.get("stored_line_count"));
			ret.setUjsJobId((String) log.get(PK_EXEC_LOGS));
		}
		return ret;
	}

	public void insertExecLog(ExecLog execLog) throws Exception {
		// should be a null check here
		insertExecLogs(Arrays.asList(execLog));
	}

	public void insertExecLogs(List<ExecLog> execLogList) throws Exception {
		// should be a null collection contents check here
		logCol.insert(execLogList.stream().map(l -> toDBObj(l)).collect(Collectors.toList()));
	}

	public void updateExecLogLines(String ujsJobId, int newLineCount,
								   List<ExecLogLine> newLines) throws Exception {
		// needs input checking
		logCol.update(new BasicDBObject(PK_EXEC_LOGS, ujsJobId),
				new BasicDBObject("$set",
						new BasicDBObject("original_line_count", newLineCount)
								.append("stored_line_count", newLineCount))
						.append("$push", new BasicDBObject("lines", new BasicDBObject("$each",
								newLines.stream().map(l -> toDBObj(l))
										.collect(Collectors.toList())))));
	}

	public void updateExecLogOriginalLineCount(String ujsJobId, int newLineCount)
			throws Exception {
		//input checking
		logCol.update(new BasicDBObject(PK_EXEC_LOGS, ujsJobId),
				new BasicDBObject("$set", new BasicDBObject("original_line_count", newLineCount)));
	}

	public List<ExecLogLine> getExecLogLines(String ujsJobId, int from, int count)
			throws Exception {
		//input checking
		@SuppressWarnings("unchecked")
		final List<DBObject> lines = (List<DBObject>) logCol.findOne(
				new BasicDBObject(PK_EXEC_LOGS, ujsJobId),
				new BasicDBObject("lines", new BasicDBObject("$slice",
						Arrays.asList(from, count)))).get("lines");
		return lines.stream().map(dbo -> {
			final ExecLogLine line = new ExecLogLine();
			line.setIsError((Boolean) dbo.get("is_error"));
			line.setLine((String) dbo.get("line"));
			line.setLinePos((Integer) dbo.get("line_pos"));
			return line;
		}).collect(Collectors.toList());
	}

	public void insertExecTask(ExecTask execTask) throws Exception {
		// needs input checking
		taskCol.insert(toDBObj(execTask));
	}

	// note that result must be sanitized before storing in mongo. See {@link SanitizeMongoObject}.
	// the sanitization should really happen here.
	public void addExecTaskResult(final String ujsJobId, final Map<String, Object> result) {
		// input checking
		taskCol.update(new BasicDBObject(PK_EXEC_TASKS, ujsJobId),
				new BasicDBObject("$set", new BasicDBObject("job_output", result)));
	}

	// note that job inputs and outputs must be un-sanitized before use.
	// See {@link SanitizeMongoObject}.
	// the un-santization should really happen here.
	public ExecTask getExecTask(String ujsJobId) throws Exception {
		// input checking
		return toObj(taskCol.findOne(new BasicDBObject(PK_EXEC_TASKS, ujsJobId)), ExecTask.class);
	}

	public void updateExecTaskTime(String ujsJobId, boolean finishTime, long time)
			throws Exception {
		//inputs
		taskCol.update(new BasicDBObject(PK_EXEC_TASKS, ujsJobId),
				new BasicDBObject("$set",
						new BasicDBObject(finishTime ? "finish_time" : "exec_start_time", time)));
	}

	public String getServiceProperty(String propId) throws Exception {
		@SuppressWarnings("rawtypes")
		List<Map> ret = Lists.newArrayList(srvProps.find(String.format("{%s:#}", PK_SRV_PROPS), propId)
				.projection(String.format("{%s:1}", SRV_PROPS_VALUE)).as(Map.class));
		if (ret.size() == 0)
			return null;
		return (String)ret.get(0).get(SRV_PROPS_VALUE);
	}

	public void setServiceProperty(String propId, String value) throws Exception {
		srvProps.update(String.format("{%s:#}", PK_SRV_PROPS), propId).upsert().with(
				String.format("{$set:{%s:#}}", SRV_PROPS_VALUE), value);
	}

	private synchronized static MongoClient getMongoClient(final String hosts)
			throws UnknownHostException, InvalidHostException {
		//Only make one instance of MongoClient per JVM per mongo docs
		final MongoClient client;
		if (!HOSTS_TO_CLIENT.containsKey(hosts)) {
			// Don't print to stderr
			java.util.logging.Logger.getLogger("com.mongodb")
					.setLevel(Level.OFF);
			@SuppressWarnings("deprecation")
			final MongoClientOptions opts = MongoClientOptions.builder()
					.autoConnectRetry(true).build();
			try {
				List<ServerAddress> addr = new ArrayList<ServerAddress>();
				for (String s: hosts.split(","))
					addr.add(new ServerAddress(s));
				client = new MongoClient(addr, opts);
			} catch (NumberFormatException nfe) {
				//throw a better exception if 10gen ever fixes this
				throw new InvalidHostException(hosts
						+ " is not a valid mongodb host");
			}
			HOSTS_TO_CLIENT.put(hosts, client);
		} else {
			client = HOSTS_TO_CLIENT.get(hosts);
		}
		return client;
	}

	@SuppressWarnings("deprecation")
	private static DB getDB(final String hosts, final String database,
							final String user, final String pwd,
							final int retryCount, final int logIntervalCount)
			throws UnknownHostException, InvalidHostException, IOException,
			MongoAuthException, InterruptedException {
		if (database == null || database.isEmpty()) {
			throw new IllegalArgumentException(
					"database may not be null or the empty string");
		}
		final DB db = getMongoClient(hosts).getDB(database);
		if (user != null && pwd != null) {
			int retries = 0;
			while (true) {
				try {
					db.authenticate(user, pwd.toCharArray());
					break;
				} catch (MongoException.Network men) {
					if (retries >= retryCount) {
						throw (IOException) men.getCause();
					}
					if (retries % logIntervalCount == 0) {
						getLogger().info(
								"Retrying MongoDB connection {}/{}, attempt {}/{}",
								hosts, database, retries, retryCount);
					}
					Thread.sleep(1000);
				}
				retries++;
			}
		}
		try {
			db.getCollectionNames();
		} catch (MongoException me) {
			throw new MongoAuthException("Not authorized for database "
					+ database, me);
		}
		return db;
	}

	private static Logger getLogger() {
		return LoggerFactory.getLogger(GetMongoDB.class);
	}
}