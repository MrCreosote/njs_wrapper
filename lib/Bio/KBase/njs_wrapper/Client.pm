package Bio::KBase::njs_wrapper::Client;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::njs_wrapper::Client

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'https://kbase.us/services/njs_wrapper/';
    }

    my $self = {
	client => Bio::KBase::njs_wrapper::Client::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 run_app

  $return = $obj->run_app($app)

=over 4

=item Parameter and return types

=begin html

<pre>
$app is a NarrativeJobService.app
$return is a NarrativeJobService.app_state
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
job_id is a string
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int

</pre>

=end html

=begin text

$app is a NarrativeJobService.app
$return is a NarrativeJobService.app_state
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
boolean is an int
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
job_id is a string
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int


=end text

=item Description



=back

=cut

 sub run_app
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function run_app (received $n, expecting 1)");
    }
    {
	my($app) = @args;

	my @_bad_arguments;
        (ref($app) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"app\" (value was \"$app\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to run_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'run_app');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.run_app",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'run_app',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method run_app",
					    status_line => $self->{client}->status_line,
					    method_name => 'run_app',
				       );
    }
}
 


=head2 check_app_state

  $return = $obj->check_app_state($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$return is a NarrativeJobService.app_state
job_id is a string
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int
boolean is an int
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$return is a NarrativeJobService.app_state
job_id is a string
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int
boolean is an int
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean


=end text

=item Description



=back

=cut

 sub check_app_state
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function check_app_state (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to check_app_state:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'check_app_state');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.check_app_state",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'check_app_state',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method check_app_state",
					    status_line => $self->{client}->status_line,
					    method_name => 'check_app_state',
				       );
    }
}
 


=head2 suspend_app

  $status = $obj->suspend_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string


=end text

=item Description

status - 'success' or 'failure' of action

=back

=cut

 sub suspend_app
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function suspend_app (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to suspend_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'suspend_app');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.suspend_app",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'suspend_app',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method suspend_app",
					    status_line => $self->{client}->status_line,
					    method_name => 'suspend_app',
				       );
    }
}
 


=head2 resume_app

  $status = $obj->resume_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string


=end text

=item Description



=back

=cut

 sub resume_app
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function resume_app (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to resume_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'resume_app');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.resume_app",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'resume_app',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method resume_app",
					    status_line => $self->{client}->status_line,
					    method_name => 'resume_app',
				       );
    }
}
 


=head2 delete_app

  $status = $obj->delete_app($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$status is a string
job_id is a string


=end text

=item Description



=back

=cut

 sub delete_app
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_app (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_app:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_app');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.delete_app",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'delete_app',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_app",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_app',
				       );
    }
}
 


=head2 list_config

  $return = $obj->list_config()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$return is a reference to a hash where the key is a string and the value is a string


=end text

=item Description



=back

=cut

 sub list_config
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_config (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.list_config",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_config',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_config",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_config',
				       );
    }
}
 


=head2 ver

  $return = $obj->ver()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string

</pre>

=end html

=begin text

$return is a string


=end text

=item Description

Returns the current running version of the NarrativeJobService.

=back

=cut

 sub ver
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ver (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.ver",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ver',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ver",
					    status_line => $self->{client}->status_line,
					    method_name => 'ver',
				       );
    }
}
 


=head2 status

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a NarrativeJobService.Status
Status is a reference to a hash where the following keys are defined:
	reboot_mode has a value which is a NarrativeJobService.boolean
	stopping_mode has a value which is a NarrativeJobService.boolean
	running_tasks_total has a value which is an int
	running_tasks_per_user has a value which is a reference to a hash where the key is a string and the value is an int
	tasks_in_queue has a value which is an int
	config has a value which is a reference to a hash where the key is a string and the value is a string
	git_commit has a value which is a string
boolean is an int

</pre>

=end html

=begin text

$return is a NarrativeJobService.Status
Status is a reference to a hash where the following keys are defined:
	reboot_mode has a value which is a NarrativeJobService.boolean
	stopping_mode has a value which is a NarrativeJobService.boolean
	running_tasks_total has a value which is an int
	running_tasks_per_user has a value which is a reference to a hash where the key is a string and the value is an int
	tasks_in_queue has a value which is an int
	config has a value which is a reference to a hash where the key is a string and the value is a string
	git_commit has a value which is a string
boolean is an int


=end text

=item Description

Simply check the status of this service to see queue details

=back

=cut

 sub status
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function status (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.status",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'status',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
					    status_line => $self->{client}->status_line,
					    method_name => 'status',
				       );
    }
}
 


=head2 list_running_apps

  $return = $obj->list_running_apps()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a reference to a list where each element is a NarrativeJobService.app_state
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
job_id is a string
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int
boolean is an int
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean

</pre>

=end html

=begin text

$return is a reference to a list where each element is a NarrativeJobService.app_state
app_state is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	job_state has a value which is a string
	running_step_id has a value which is a string
	step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
	step_errors has a value which is a reference to a hash where the key is a string and the value is a string
	step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
	step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
	is_deleted has a value which is a NarrativeJobService.boolean
	original_app has a value which is a NarrativeJobService.app
	submit_time has a value which is a string
	start_time has a value which is a string
	complete_time has a value which is a string
	position has a value which is an int
job_id is a string
step_stats is a reference to a hash where the following keys are defined:
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
	pos_in_queue has a value which is an int
boolean is an int
app is a reference to a hash where the following keys are defined:
	name has a value which is a string
	steps has a value which is a reference to a list where each element is a NarrativeJobService.step
step is a reference to a hash where the following keys are defined:
	step_id has a value which is a string
	type has a value which is a string
	service has a value which is a NarrativeJobService.service_method
	script has a value which is a NarrativeJobService.script_method
	parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
	input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	is_long_running has a value which is a NarrativeJobService.boolean
	job_id_output_field has a value which is a string
	method_spec_id has a value which is a string
service_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	service_url has a value which is a string
	service_version has a value which is a string
script_method is a reference to a hash where the following keys are defined:
	service_name has a value which is a string
	method_name has a value which is a string
	has_files has a value which is a NarrativeJobService.boolean
step_parameter is a reference to a hash where the following keys are defined:
	label has a value which is a string
	value has a value which is a string
	step_source has a value which is a string
	is_workspace_id has a value which is a NarrativeJobService.boolean
	ws_object has a value which is a NarrativeJobService.workspace_object
workspace_object is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a string
	object_type has a value which is a string
	is_input has a value which is a NarrativeJobService.boolean


=end text

=item Description



=back

=cut

 sub list_running_apps
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_running_apps (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.list_running_apps",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_running_apps',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_running_apps",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_running_apps',
				       );
    }
}
 


=head2 run_job

  $job_id = $obj->run_job($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a NarrativeJobService.RunJobParams
$job_id is a NarrativeJobService.job_id
RunJobParams is a reference to a hash where the following keys are defined:
	method has a value which is a string
	params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	service_ver has a value which is a string
	rpc_context has a value which is a NarrativeJobService.RpcContext
	remote_url has a value which is a string
	source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref
RpcContext is a reference to a hash where the following keys are defined:
	call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
	run_id has a value which is a string
MethodCall is a reference to a hash where the following keys are defined:
	time has a value which is a NarrativeJobService.timestamp
	method has a value which is a string
	job_id has a value which is a NarrativeJobService.job_id
timestamp is a string
job_id is a string
wsref is a string

</pre>

=end html

=begin text

$params is a NarrativeJobService.RunJobParams
$job_id is a NarrativeJobService.job_id
RunJobParams is a reference to a hash where the following keys are defined:
	method has a value which is a string
	params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	service_ver has a value which is a string
	rpc_context has a value which is a NarrativeJobService.RpcContext
	remote_url has a value which is a string
	source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref
RpcContext is a reference to a hash where the following keys are defined:
	call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
	run_id has a value which is a string
MethodCall is a reference to a hash where the following keys are defined:
	time has a value which is a NarrativeJobService.timestamp
	method has a value which is a string
	job_id has a value which is a NarrativeJobService.job_id
timestamp is a string
job_id is a string
wsref is a string


=end text

=item Description

Start a new job (long running method of service registered in ServiceRegistery).
Such job runs Docker image for this service in script mode.

=back

=cut

 sub run_job
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function run_job (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to run_job:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'run_job');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.run_job",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'run_job',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method run_job",
					    status_line => $self->{client}->status_line,
					    method_name => 'run_job',
				       );
    }
}
 


=head2 get_job_params

  $params, $config = $obj->get_job_params($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$params is a NarrativeJobService.RunJobParams
$config is a reference to a hash where the key is a string and the value is a string
job_id is a string
RunJobParams is a reference to a hash where the following keys are defined:
	method has a value which is a string
	params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	service_ver has a value which is a string
	rpc_context has a value which is a NarrativeJobService.RpcContext
	remote_url has a value which is a string
	source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref
RpcContext is a reference to a hash where the following keys are defined:
	call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
	run_id has a value which is a string
MethodCall is a reference to a hash where the following keys are defined:
	time has a value which is a NarrativeJobService.timestamp
	method has a value which is a string
	job_id has a value which is a NarrativeJobService.job_id
timestamp is a string
wsref is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$params is a NarrativeJobService.RunJobParams
$config is a reference to a hash where the key is a string and the value is a string
job_id is a string
RunJobParams is a reference to a hash where the following keys are defined:
	method has a value which is a string
	params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	service_ver has a value which is a string
	rpc_context has a value which is a NarrativeJobService.RpcContext
	remote_url has a value which is a string
	source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref
RpcContext is a reference to a hash where the following keys are defined:
	call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
	run_id has a value which is a string
MethodCall is a reference to a hash where the following keys are defined:
	time has a value which is a NarrativeJobService.timestamp
	method has a value which is a string
	job_id has a value which is a NarrativeJobService.job_id
timestamp is a string
wsref is a string


=end text

=item Description

Get job params necessary for job execution

=back

=cut

 sub get_job_params
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_job_params (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_job_params:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_job_params');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.get_job_params",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_job_params',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_job_params",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_job_params',
				       );
    }
}
 


=head2 add_job_logs

  $line_number = $obj->add_job_logs($job_id, $lines)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$lines is a reference to a list where each element is a NarrativeJobService.LogLine
$line_number is an int
job_id is a string
LogLine is a reference to a hash where the following keys are defined:
	line has a value which is a string
	is_error has a value which is a NarrativeJobService.boolean
boolean is an int

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$lines is a reference to a list where each element is a NarrativeJobService.LogLine
$line_number is an int
job_id is a string
LogLine is a reference to a hash where the following keys are defined:
	line has a value which is a string
	is_error has a value which is a NarrativeJobService.boolean
boolean is an int


=end text

=item Description



=back

=cut

 sub add_job_logs
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function add_job_logs (received $n, expecting 2)");
    }
    {
	my($job_id, $lines) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        (ref($lines) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"lines\" (value was \"$lines\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to add_job_logs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'add_job_logs');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.add_job_logs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'add_job_logs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method add_job_logs",
					    status_line => $self->{client}->status_line,
					    method_name => 'add_job_logs',
				       );
    }
}
 


=head2 get_job_logs

  $return = $obj->get_job_logs($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a NarrativeJobService.GetJobLogsParams
$return is a NarrativeJobService.GetJobLogsResults
GetJobLogsParams is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	skip_lines has a value which is an int
job_id is a string
GetJobLogsResults is a reference to a hash where the following keys are defined:
	lines has a value which is a reference to a list where each element is a NarrativeJobService.LogLine
	last_line_number has a value which is an int
LogLine is a reference to a hash where the following keys are defined:
	line has a value which is a string
	is_error has a value which is a NarrativeJobService.boolean
boolean is an int

</pre>

=end html

=begin text

$params is a NarrativeJobService.GetJobLogsParams
$return is a NarrativeJobService.GetJobLogsResults
GetJobLogsParams is a reference to a hash where the following keys are defined:
	job_id has a value which is a NarrativeJobService.job_id
	skip_lines has a value which is an int
job_id is a string
GetJobLogsResults is a reference to a hash where the following keys are defined:
	lines has a value which is a reference to a list where each element is a NarrativeJobService.LogLine
	last_line_number has a value which is an int
LogLine is a reference to a hash where the following keys are defined:
	line has a value which is a string
	is_error has a value which is a NarrativeJobService.boolean
boolean is an int


=end text

=item Description



=back

=cut

 sub get_job_logs
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_job_logs (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_job_logs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_job_logs');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.get_job_logs",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_job_logs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_job_logs",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_job_logs',
				       );
    }
}
 


=head2 finish_job

  $obj->finish_job($job_id, $params)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$params is a NarrativeJobService.FinishJobParams
job_id is a string
FinishJobParams is a reference to a hash where the following keys are defined:
	result has a value which is an UnspecifiedObject, which can hold any non-null object
	error has a value which is a NarrativeJobService.JsonRpcError
JsonRpcError is a reference to a hash where the following keys are defined:
	name has a value which is a string
	code has a value which is an int
	message has a value which is a string
	error has a value which is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$params is a NarrativeJobService.FinishJobParams
job_id is a string
FinishJobParams is a reference to a hash where the following keys are defined:
	result has a value which is an UnspecifiedObject, which can hold any non-null object
	error has a value which is a NarrativeJobService.JsonRpcError
JsonRpcError is a reference to a hash where the following keys are defined:
	name has a value which is a string
	code has a value which is an int
	message has a value which is a string
	error has a value which is a string


=end text

=item Description

Register results of already started job

=back

=cut

 sub finish_job
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function finish_job (received $n, expecting 2)");
    }
    {
	my($job_id, $params) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 2 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to finish_job:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'finish_job');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.finish_job",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'finish_job',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method finish_job",
					    status_line => $self->{client}->status_line,
					    method_name => 'finish_job',
				       );
    }
}
 


=head2 check_job

  $job_state = $obj->check_job($job_id)

=over 4

=item Parameter and return types

=begin html

<pre>
$job_id is a NarrativeJobService.job_id
$job_state is a NarrativeJobService.JobState
job_id is a string
JobState is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	finished has a value which is a NarrativeJobService.boolean
	ujs_url has a value which is a string
	status has a value which is an UnspecifiedObject, which can hold any non-null object
	result has a value which is an UnspecifiedObject, which can hold any non-null object
	error has a value which is a NarrativeJobService.JsonRpcError
	job_state has a value which is a string
	position has a value which is an int
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
boolean is an int
JsonRpcError is a reference to a hash where the following keys are defined:
	name has a value which is a string
	code has a value which is an int
	message has a value which is a string
	error has a value which is a string

</pre>

=end html

=begin text

$job_id is a NarrativeJobService.job_id
$job_state is a NarrativeJobService.JobState
job_id is a string
JobState is a reference to a hash where the following keys are defined:
	job_id has a value which is a string
	finished has a value which is a NarrativeJobService.boolean
	ujs_url has a value which is a string
	status has a value which is an UnspecifiedObject, which can hold any non-null object
	result has a value which is an UnspecifiedObject, which can hold any non-null object
	error has a value which is a NarrativeJobService.JsonRpcError
	job_state has a value which is a string
	position has a value which is an int
	creation_time has a value which is an int
	exec_start_time has a value which is an int
	finish_time has a value which is an int
boolean is an int
JsonRpcError is a reference to a hash where the following keys are defined:
	name has a value which is a string
	code has a value which is an int
	message has a value which is a string
	error has a value which is a string


=end text

=item Description

Check if a job is finished and get results/error

=back

=cut

 sub check_job
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function check_job (received $n, expecting 1)");
    }
    {
	my($job_id) = @args;

	my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 1 \"job_id\" (value was \"$job_id\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to check_job:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'check_job');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "NarrativeJobService.check_job",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'check_job',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method check_job",
					    status_line => $self->{client}->status_line,
					    method_name => 'check_job',
				       );
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "NarrativeJobService.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'check_job',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method check_job",
            status_line => $self->{client}->status_line,
            method_name => 'check_job',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::njs_wrapper::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::njs_wrapper::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

@range [0,1]


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 timestamp

=over 4



=item Description

A time in the format YYYY-MM-DDThh:mm:ssZ, where Z is either the
character Z (representing the UTC timezone) or the difference
in time to UTC in the format +/-HHMM, eg:
    2012-12-17T23:24:06-0500 (EST time)
    2013-04-03T08:56:32+0000 (UTC time)
    2013-04-03T08:56:32Z (UTC time)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 job_id

=over 4



=item Description

A job id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 service_method

=over 4



=item Description

service_url could be empty in case of docker image of service loaded from registry,
service_version - optional parameter defining version of service docker image.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
service_url has a value which is a string
service_version has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
service_url has a value which is a string
service_version has a value which is a string


=end text

=back



=head2 script_method

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
has_files has a value which is a NarrativeJobService.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
service_name has a value which is a string
method_name has a value which is a string
has_files has a value which is a NarrativeJobService.boolean


=end text

=back



=head2 workspace_object

=over 4



=item Description

label - label of parameter, can be empty string for positional parameters
value - value of parameter
step_source - step_id that parameter derives from
is_workspace_id - parameter is a workspace id (value is object name)
# the below are only used if is_workspace_id is true
    is_input - parameter is an input (true) or output (false)
    workspace_name - name of workspace
    object_type - name of object type


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
object_type has a value which is a string
is_input has a value which is a NarrativeJobService.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a string
object_type has a value which is a string
is_input has a value which is a NarrativeJobService.boolean


=end text

=back



=head2 step_parameter

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
label has a value which is a string
value has a value which is a string
step_source has a value which is a string
is_workspace_id has a value which is a NarrativeJobService.boolean
ws_object has a value which is a NarrativeJobService.workspace_object

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
label has a value which is a string
value has a value which is a string
step_source has a value which is a string
is_workspace_id has a value which is a NarrativeJobService.boolean
ws_object has a value which is a NarrativeJobService.workspace_object


=end text

=back



=head2 step

=over 4



=item Description

type - 'service' or 'script'.
job_id_output_field - this field is used only in case this step is long running job and
    output of service method is structure with field having name coded in
    'job_id_output_field' rather than just output string with job id.
method_spec_id - high level id of UI method used for logging of execution time 
    statistics.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
step_id has a value which is a string
type has a value which is a string
service has a value which is a NarrativeJobService.service_method
script has a value which is a NarrativeJobService.script_method
parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
is_long_running has a value which is a NarrativeJobService.boolean
job_id_output_field has a value which is a string
method_spec_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
step_id has a value which is a string
type has a value which is a string
service has a value which is a NarrativeJobService.service_method
script has a value which is a NarrativeJobService.script_method
parameters has a value which is a reference to a list where each element is a NarrativeJobService.step_parameter
input_values has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
is_long_running has a value which is a NarrativeJobService.boolean
job_id_output_field has a value which is a string
method_spec_id has a value which is a string


=end text

=back



=head2 app

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
steps has a value which is a reference to a list where each element is a NarrativeJobService.step

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
steps has a value which is a reference to a list where each element is a NarrativeJobService.step


=end text

=back



=head2 step_stats

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
creation_time has a value which is an int
exec_start_time has a value which is an int
finish_time has a value which is an int
pos_in_queue has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
creation_time has a value which is an int
exec_start_time has a value which is an int
finish_time has a value which is an int
pos_in_queue has a value which is an int


=end text

=back



=head2 app_state

=over 4



=item Description

job_id - id of job running app
job_state - 'queued', 'in-progress', 'completed', or 'suspend'
running_step_id - id of step currently running
step_outputs - mapping step_id to stdout text produced by step, only for completed or errored steps
step_outputs - mapping step_id to stderr text produced by step, only for completed or errored steps
step_job_ids - mapping from step_id to job_id
step_stats - mapping from step_id to execution time statistics
position - position of this job in execution waiting queue
submit_time, start_time and complete_time - time moments of submission, execution start and
    finish events formatted in ISO 8601 with UTC time-zone (like 2016-02-18T12:06:55Z).


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
job_id has a value which is a NarrativeJobService.job_id
job_state has a value which is a string
running_step_id has a value which is a string
step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
step_errors has a value which is a reference to a hash where the key is a string and the value is a string
step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
is_deleted has a value which is a NarrativeJobService.boolean
original_app has a value which is a NarrativeJobService.app
submit_time has a value which is a string
start_time has a value which is a string
complete_time has a value which is a string
position has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
job_id has a value which is a NarrativeJobService.job_id
job_state has a value which is a string
running_step_id has a value which is a string
step_outputs has a value which is a reference to a hash where the key is a string and the value is a string
step_errors has a value which is a reference to a hash where the key is a string and the value is a string
step_job_ids has a value which is a reference to a hash where the key is a string and the value is a string
step_stats has a value which is a reference to a hash where the key is a string and the value is a NarrativeJobService.step_stats
is_deleted has a value which is a NarrativeJobService.boolean
original_app has a value which is a NarrativeJobService.app
submit_time has a value which is a string
start_time has a value which is a string
complete_time has a value which is a string
position has a value which is an int


=end text

=back



=head2 Status

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reboot_mode has a value which is a NarrativeJobService.boolean
stopping_mode has a value which is a NarrativeJobService.boolean
running_tasks_total has a value which is an int
running_tasks_per_user has a value which is a reference to a hash where the key is a string and the value is an int
tasks_in_queue has a value which is an int
config has a value which is a reference to a hash where the key is a string and the value is a string
git_commit has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reboot_mode has a value which is a NarrativeJobService.boolean
stopping_mode has a value which is a NarrativeJobService.boolean
running_tasks_total has a value which is an int
running_tasks_per_user has a value which is a reference to a hash where the key is a string and the value is an int
tasks_in_queue has a value which is an int
config has a value which is a reference to a hash where the key is a string and the value is a string
git_commit has a value which is a string


=end text

=back



=head2 wsref

=over 4



=item Description

A workspace object reference of the form X/Y/Z, where
X is the workspace name or id,
Y is the object name or id,
Z is the version, which is optional.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 MethodCall

=over 4



=item Description

time - the time the call was started;
method - service defined in standard JSON RPC way, typically it's
    module name from spec-file followed by '.' and name of funcdef
    from spec-file corresponding to running method (e.g.
    'KBaseTrees.construct_species_tree' from trees service);
job_id - job id if method is asynchronous (optional field).


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
time has a value which is a NarrativeJobService.timestamp
method has a value which is a string
job_id has a value which is a NarrativeJobService.job_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
time has a value which is a NarrativeJobService.timestamp
method has a value which is a string
job_id has a value which is a NarrativeJobService.job_id


=end text

=back



=head2 RpcContext

=over 4



=item Description

call_stack - upstream calls details including nested service calls and 
    parent jobs where calls are listed in order from outer to inner.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
run_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
call_stack has a value which is a reference to a list where each element is a NarrativeJobService.MethodCall
run_id has a value which is a string


=end text

=back



=head2 RunJobParams

=over 4



=item Description

method - service defined in standard JSON RPC way, typically it's
    module name from spec-file followed by '.' and name of funcdef 
    from spec-file corresponding to running method (e.g.
    'KBaseTrees.construct_species_tree' from trees service);
params - the parameters of the method that performed this call;
service_ver - specific version of deployed service, last version is used 
    if this parameter is not defined (optional field);
rpc_context - context of current method call including nested call history
    (optional field, could be omitted in case there is no call history);
remote_url - optional field determining remote service call instead of
    local command line execution.
source_ws_objects - optional field denoting the workspace objects that
    will serve as a source of data when running the SDK method. These
    references will be added to the autogenerated provenance.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
method has a value which is a string
params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
service_ver has a value which is a string
rpc_context has a value which is a NarrativeJobService.RpcContext
remote_url has a value which is a string
source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
method has a value which is a string
params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
service_ver has a value which is a string
rpc_context has a value which is a NarrativeJobService.RpcContext
remote_url has a value which is a string
source_ws_objects has a value which is a reference to a list where each element is a NarrativeJobService.wsref


=end text

=back



=head2 LogLine

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
line has a value which is a string
is_error has a value which is a NarrativeJobService.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
line has a value which is a string
is_error has a value which is a NarrativeJobService.boolean


=end text

=back



=head2 GetJobLogsParams

=over 4



=item Description

skip_lines - optional parameter, number of lines to skip (in case they were 
    already loaded before).


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
job_id has a value which is a NarrativeJobService.job_id
skip_lines has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
job_id has a value which is a NarrativeJobService.job_id
skip_lines has a value which is an int


=end text

=back



=head2 GetJobLogsResults

=over 4



=item Description

last_line_number - common number of lines (including those in skip_lines 
    parameter), this number can be used as next skip_lines value to
    skip already loaded lines next time.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
lines has a value which is a reference to a list where each element is a NarrativeJobService.LogLine
last_line_number has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
lines has a value which is a reference to a list where each element is a NarrativeJobService.LogLine
last_line_number has a value which is an int


=end text

=back



=head2 JsonRpcError

=over 4



=item Description

Error block of JSON RPC response


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
name has a value which is a string
code has a value which is an int
message has a value which is a string
error has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
name has a value which is a string
code has a value which is an int
message has a value which is a string
error has a value which is a string


=end text

=back



=head2 FinishJobParams

=over 4



=item Description

Either 'result' or 'error' field should be defined;
result - keeps exact copy of what original server method puts
    in result block of JSON RPC response;
error - keeps exact copy of what original server method puts
    in error block of JSON RPC response.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
result has a value which is an UnspecifiedObject, which can hold any non-null object
error has a value which is a NarrativeJobService.JsonRpcError

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
result has a value which is an UnspecifiedObject, which can hold any non-null object
error has a value which is a NarrativeJobService.JsonRpcError


=end text

=back



=head2 JobState

=over 4



=item Description

job_id - id of job running method
finished - indicates whether job is done (including error cases) or not,
    if the value is true then either of 'returned_data' or 'detailed_error'
    should be defined;
ujs_url - url of UserAndJobState service used by job service
status - tuple returned by UserAndJobState.get_job_status method
result - keeps exact copy of what original server method puts
    in result block of JSON RPC response;
error - keeps exact copy of what original server method puts
    in error block of JSON RPC response;
job_state - 'queued', 'in-progress', 'completed', or 'suspend';
position - position of the job in execution waiting queue;
creation_time, exec_start_time and finish_time - time moments of submission, execution 
    start and finish events in milliseconds since Unix Epoch.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
job_id has a value which is a string
finished has a value which is a NarrativeJobService.boolean
ujs_url has a value which is a string
status has a value which is an UnspecifiedObject, which can hold any non-null object
result has a value which is an UnspecifiedObject, which can hold any non-null object
error has a value which is a NarrativeJobService.JsonRpcError
job_state has a value which is a string
position has a value which is an int
creation_time has a value which is an int
exec_start_time has a value which is an int
finish_time has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
job_id has a value which is a string
finished has a value which is a NarrativeJobService.boolean
ujs_url has a value which is a string
status has a value which is an UnspecifiedObject, which can hold any non-null object
result has a value which is an UnspecifiedObject, which can hold any non-null object
error has a value which is a NarrativeJobService.JsonRpcError
job_state has a value which is a string
position has a value which is an int
creation_time has a value which is an int
exec_start_time has a value which is an int
finish_time has a value which is an int


=end text

=back



=cut

package Bio::KBase::njs_wrapper::Client::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
