
package us.kbase.narrativejobservice;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import us.kbase.common.service.UObject;


/**
 * <p>Original spec-file type: JobState</p>
 * <pre>
 * job_id - id of job running method
 * finished - indicates whether job is done (including error cases) or not,
 *     if the value is true then either of 'returned_data' or 'detailed_error'
 *     should be defined;
 * ujs_url - url of UserAndJobState service used by job service
 * status - tuple returned by UserAndJobState.get_job_status method
 * result - keeps exact copy of what original server method puts
 *     in result block of JSON RPC response;
 * error - keeps exact copy of what original server method puts
 *     in error block of JSON RPC response;
 * job_state - 'queued', 'in-progress', 'completed', or 'suspend';
 * position - position of the job in execution waiting queue;
 * creation_time, exec_start_time and finish_time - time moments of submission, execution 
 *     start and finish events in milliseconds since Unix Epoch.
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "job_id",
    "finished",
    "ujs_url",
    "status",
    "result",
    "error",
    "job_state",
    "position",
    "creation_time",
    "exec_start_time",
    "finish_time"
})
public class JobState {

    @JsonProperty("job_id")
    private String jobId;
    @JsonProperty("finished")
    private Long finished;
    @JsonProperty("ujs_url")
    private String ujsUrl;
    @JsonProperty("status")
    private UObject status;
    @JsonProperty("result")
    private UObject result;
    /**
     * <p>Original spec-file type: JsonRpcError</p>
     * <pre>
     * Error block of JSON RPC response
     * </pre>
     * 
     */
    @JsonProperty("error")
    private JsonRpcError error;
    @JsonProperty("job_state")
    private String jobState;
    @JsonProperty("position")
    private Long position;
    @JsonProperty("creation_time")
    private Long creationTime;
    @JsonProperty("exec_start_time")
    private Long execStartTime;
    @JsonProperty("finish_time")
    private Long finishTime;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("job_id")
    public String getJobId() {
        return jobId;
    }

    @JsonProperty("job_id")
    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public JobState withJobId(String jobId) {
        this.jobId = jobId;
        return this;
    }

    @JsonProperty("finished")
    public Long getFinished() {
        return finished;
    }

    @JsonProperty("finished")
    public void setFinished(Long finished) {
        this.finished = finished;
    }

    public JobState withFinished(Long finished) {
        this.finished = finished;
        return this;
    }

    @JsonProperty("ujs_url")
    public String getUjsUrl() {
        return ujsUrl;
    }

    @JsonProperty("ujs_url")
    public void setUjsUrl(String ujsUrl) {
        this.ujsUrl = ujsUrl;
    }

    public JobState withUjsUrl(String ujsUrl) {
        this.ujsUrl = ujsUrl;
        return this;
    }

    @JsonProperty("status")
    public UObject getStatus() {
        return status;
    }

    @JsonProperty("status")
    public void setStatus(UObject status) {
        this.status = status;
    }

    public JobState withStatus(UObject status) {
        this.status = status;
        return this;
    }

    @JsonProperty("result")
    public UObject getResult() {
        return result;
    }

    @JsonProperty("result")
    public void setResult(UObject result) {
        this.result = result;
    }

    public JobState withResult(UObject result) {
        this.result = result;
        return this;
    }

    /**
     * <p>Original spec-file type: JsonRpcError</p>
     * <pre>
     * Error block of JSON RPC response
     * </pre>
     * 
     */
    @JsonProperty("error")
    public JsonRpcError getError() {
        return error;
    }

    /**
     * <p>Original spec-file type: JsonRpcError</p>
     * <pre>
     * Error block of JSON RPC response
     * </pre>
     * 
     */
    @JsonProperty("error")
    public void setError(JsonRpcError error) {
        this.error = error;
    }

    public JobState withError(JsonRpcError error) {
        this.error = error;
        return this;
    }

    @JsonProperty("job_state")
    public String getJobState() {
        return jobState;
    }

    @JsonProperty("job_state")
    public void setJobState(String jobState) {
        this.jobState = jobState;
    }

    public JobState withJobState(String jobState) {
        this.jobState = jobState;
        return this;
    }

    @JsonProperty("position")
    public Long getPosition() {
        return position;
    }

    @JsonProperty("position")
    public void setPosition(Long position) {
        this.position = position;
    }

    public JobState withPosition(Long position) {
        this.position = position;
        return this;
    }

    @JsonProperty("creation_time")
    public Long getCreationTime() {
        return creationTime;
    }

    @JsonProperty("creation_time")
    public void setCreationTime(Long creationTime) {
        this.creationTime = creationTime;
    }

    public JobState withCreationTime(Long creationTime) {
        this.creationTime = creationTime;
        return this;
    }

    @JsonProperty("exec_start_time")
    public Long getExecStartTime() {
        return execStartTime;
    }

    @JsonProperty("exec_start_time")
    public void setExecStartTime(Long execStartTime) {
        this.execStartTime = execStartTime;
    }

    public JobState withExecStartTime(Long execStartTime) {
        this.execStartTime = execStartTime;
        return this;
    }

    @JsonProperty("finish_time")
    public Long getFinishTime() {
        return finishTime;
    }

    @JsonProperty("finish_time")
    public void setFinishTime(Long finishTime) {
        this.finishTime = finishTime;
    }

    public JobState withFinishTime(Long finishTime) {
        this.finishTime = finishTime;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((((((((((((((((((("JobState"+" [jobId=")+ jobId)+", finished=")+ finished)+", ujsUrl=")+ ujsUrl)+", status=")+ status)+", result=")+ result)+", error=")+ error)+", jobState=")+ jobState)+", position=")+ position)+", creationTime=")+ creationTime)+", execStartTime=")+ execStartTime)+", finishTime=")+ finishTime)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
