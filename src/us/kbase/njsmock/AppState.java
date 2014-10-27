
package us.kbase.njsmock;

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
 * <p>Original spec-file type: app_state</p>
 * <pre>
 * step_job_ids - mapping from step_id to job_id.
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "app_job_id",
    "running_step_id",
    "step_job_ids",
    "step_outputs"
})
public class AppState {

    @JsonProperty("app_job_id")
    private java.lang.String appJobId;
    @JsonProperty("running_step_id")
    private java.lang.String runningStepId;
    @JsonProperty("step_job_ids")
    private Map<String, String> stepJobIds;
    @JsonProperty("step_outputs")
    private Map<String, UObject> stepOutputs;
    private Map<java.lang.String, Object> additionalProperties = new HashMap<java.lang.String, Object>();

    @JsonProperty("app_job_id")
    public java.lang.String getAppJobId() {
        return appJobId;
    }

    @JsonProperty("app_job_id")
    public void setAppJobId(java.lang.String appJobId) {
        this.appJobId = appJobId;
    }

    public AppState withAppJobId(java.lang.String appJobId) {
        this.appJobId = appJobId;
        return this;
    }

    @JsonProperty("running_step_id")
    public java.lang.String getRunningStepId() {
        return runningStepId;
    }

    @JsonProperty("running_step_id")
    public void setRunningStepId(java.lang.String runningStepId) {
        this.runningStepId = runningStepId;
    }

    public AppState withRunningStepId(java.lang.String runningStepId) {
        this.runningStepId = runningStepId;
        return this;
    }

    @JsonProperty("step_job_ids")
    public Map<String, String> getStepJobIds() {
        return stepJobIds;
    }

    @JsonProperty("step_job_ids")
    public void setStepJobIds(Map<String, String> stepJobIds) {
        this.stepJobIds = stepJobIds;
    }

    public AppState withStepJobIds(Map<String, String> stepJobIds) {
        this.stepJobIds = stepJobIds;
        return this;
    }

    @JsonProperty("step_outputs")
    public Map<String, UObject> getStepOutputs() {
        return stepOutputs;
    }

    @JsonProperty("step_outputs")
    public void setStepOutputs(Map<String, UObject> stepOutputs) {
        this.stepOutputs = stepOutputs;
    }

    public AppState withStepOutputs(Map<String, UObject> stepOutputs) {
        this.stepOutputs = stepOutputs;
        return this;
    }

    @JsonAnyGetter
    public Map<java.lang.String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(java.lang.String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public java.lang.String toString() {
        return ((((((((((("AppState"+" [appJobId=")+ appJobId)+", runningStepId=")+ runningStepId)+", stepJobIds=")+ stepJobIds)+", stepOutputs=")+ stepOutputs)+", additionalProperties=")+ additionalProperties)+"]");
    }

}