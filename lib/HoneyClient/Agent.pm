#######################################################################
# Created on:  May 11, 2006
# Package:     HoneyClient::Agent
# File:        Agent.pm
# Description: Central library used for agent-based operations.
#
# CVS: $Id: Agent.pm 1049 2006-06-28 16:37:41Z flindiakos $
#
# @author knwang, ttruong, kindlund
#
# Copyright (C) 2006 The MITRE Corporation.  All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, using version 2
# of the License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
#
#######################################################################

=pod

=head1 NAME

HoneyClient::Agent - Perl extension to instantiate a SOAP server
that provides a central interface for all agent-based HoneyClient
operations.

=head1 VERSION

$Rev: 1626 $

=head1 SYNOPSIS

=head2 CREATING THE SOAP SERVER

# XXX: Fill this in.

=head2 INTERACTING WITH THE SOAP SERVER

# XXX: Fill this in.

=head1 DESCRIPTION

This library creates a SOAP server within the HoneyClient VM, allowing
the HoneyClient::Manager to perform agent-based operations within the
VM.

=cut

package HoneyClient::Agent;

# XXX: Disabled version check, Honeywall does not have Perl v5.8 installed.
#use 5.008006;
use strict;
use warnings FATAL => 'all';
use Config;
use Carp ();
# TODO: This can go away.
use POSIX qw(SIGALRM);

#######################################################################
# Module Initialization                                               #
#######################################################################

BEGIN {
    # Defines which functions can be called externally.
    require Exporter;
    our (@ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS, $VERSION, @DRIVERS);

    # Set our package version.
    $VERSION = 0.9;

    @ISA = qw(Exporter);

    # Symbols to export on request
    @EXPORT = qw();

    # Items to export into callers namespace by default. Note: do not export
    # names by default without a very good reason. Use EXPORT_OK instead.
    # Do not simply export all your public functions/methods/constants.

    # This allows declaration use HoneyClient::Agent ':all';
    # If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
    # will save memory.

    %EXPORT_TAGS = (
        'all' => [ qw() ],
    );

    # Symbols to autoexport (:DEFAULT tag)
    @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

    # Check to make sure our OS is Windows-based.
    # XXX: Fix this!
    #if ($Config{osname} !~ /^MSWin32$/) {
    #    Carp::croak "Error: " . __PACKAGE__ . " will only run on Win32 platforms!\n";
    #}

    # Check to see if ithreads are compiled into this version of Perl.
    $Config{useithreads} or Carp::croak "Error: Recompile Perl with ithread support, in order to use this module.\n";

    # Registered driver list.
    # TODO: Eventually, make this more dynamic, based upon the presence of HoneyClient::Agent::Driver::* elements
    # within the global configuration file.  Or, feed the initialization logic through init() as part of the arguments.
    @DRIVERS = ( 'IE' );
    foreach (@DRIVERS) {
        eval "use HoneyClient::Agent::Driver::Browser::$_";
        if ($@) {
            Carp::croak "$@";
        }
    }

    $SIG{PIPE} = 'IGNORE'; # Do not exit on broken pipes.
}
our (@EXPORT_OK, $VERSION, @DRIVERS);

=pod

=begin testing

# Make sure the module loads properly, with the exportable
# functions shared.
BEGIN { use_ok('HoneyClient::Agent') or diag("Can't load HoneyClient::Agent package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('HoneyClient::Agent');
can_ok('HoneyClient::Agent', 'init');
can_ok('HoneyClient::Agent', 'destroy');
use HoneyClient::Agent;

# Make sure HoneyClient::Util::SOAP loads.
BEGIN { use_ok('HoneyClient::Util::SOAP', qw(getServerHandle getClientHandle)) or diag("Can't load HoneyClient::Util::SOAP package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('HoneyClient::Util::SOAP');
can_ok('HoneyClient::Util::SOAP', 'getServerHandle');
can_ok('HoneyClient::Util::SOAP', 'getClientHandle');
use HoneyClient::Util::SOAP qw(getServerHandle getClientHandle);

# Make sure HoneyClient::Util::Config loads.
BEGIN { use_ok('HoneyClient::Util::Config', qw(getVar)) or diag("Can't load HoneyClient::Util::Config package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('HoneyClient::Util::Config');
can_ok('HoneyClient::Util::Config', 'getVar');
use HoneyClient::Util::Config qw(getVar);

# TODO: Change Driver::IE to Driver::Browser::IE
# Make sure HoneyClient::Agent::Driver::IE loads.
BEGIN { use_ok('HoneyClient::Agent::Driver::IE') or diag("Can't load HoneyClient::Agent::Driver::IE package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('HoneyClient::Agent::Driver::IE');
can_ok('HoneyClient::Agent::Driver::IE', 'new');
can_ok('HoneyClient::Agent::Driver::IE', 'drive');
can_ok('HoneyClient::Agent::Driver::IE', 'getNextLink');
can_ok('HoneyClient::Agent::Driver::IE', 'next');
can_ok('HoneyClient::Agent::Driver::IE', 'isFinished');
can_ok('HoneyClient::Agent::Driver::IE', 'status');
use HoneyClient::Agent::Driver::IE;

# Make sure Storable loads.
BEGIN { use_ok('Storable', qw(nfreeze thaw)) or diag("Can't load Storable package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('Storable');
can_ok('Storable', 'nfreeze');
can_ok('Storable', 'thaw');
use Storable qw(nfreeze thaw);

# Make sure MIME::Base64 loads.
BEGIN { use_ok('MIME::Base64', qw(encode_base64 decode_base64)) or diag("Can't load MIME::Base64 package.  Check to make sure the package library is correctly listed within the path."); }
require_ok('MIME::Base64');
can_ok('MIME::Base64', 'encode_base64');
can_ok('MIME::Base64', 'decode_base64');
use MIME::Base64 qw(encode_base64 decode_base64);

#XXX: Check to see if the port number should be externalized.
# Global test variables.
our $PORT = getVar(name      => "port",
                   namespace => "HoneyClient::Agent");
our ($stub, $som);

=end testing

=cut

#######################################################################

# Include the SOAP Utility Library
use HoneyClient::Util::SOAP qw(getClientHandle getServerHandle);

# Include Integrity Library
# TODO: Include corresponding unit tests.
use HoneyClient::Agent::Integrity;

# Include Thread Libraries
use threads;
use threads::shared;
use Thread::Semaphore;
use Thread::Queue;

# Include utility access to global configuration.
use HoneyClient::Util::Config qw(getVar);

# XXX: Remove this, eventually.
use Data::Dumper;

# Include Hash Serialization Utility Libraries
# TODO: Update unit tests to include 'dclone'
use Storable qw(nfreeze thaw dclone);

# Include Base64 Libraries
use MIME::Base64 qw(encode_base64 decode_base64);

# Include Data Differential Analysis Libraries
# TODO: Include corresponding unit tests.
# XXX: Do we need this?
use Data::Diff;
# TODO: Include corresponding unit tests.
# XXX: Do we need this?
use Data::Structure::Util qw(unbless);
# TODO: Include corresponding unit tests.
# XXX: Do we need this?
use Data::Compare;

# Complete URL of SOAP server, when initialized.
our $URL_BASE       : shared = undef;
our $URL            : shared = undef;

# The process ID of the SOAP server daemon, once created.
our $DAEMON_PID     : shared = undef;

# Global static value, to indicate if the Agent should perform
# any integrity checks.
our $PERFORM_INTEGRITY_CHECKS : shared =
    getVar(name => "perform_integrity_checks");

# A globally shared, serialized hashtable, containing data per
# registered driver.  Specifically, for each @DRIVER <entry>,
# the following data is created:
#   '<entry_name>' => {
#       'state'     => undef; # Driver-specific state information.
#       'thread_id' => undef; # The thread registered to handle
#                             # the driver.
#       'status'    => undef; # Driver-specific status information.
#       'next'      => undef; # Driver-specific connection information.
#   }
our $driverData     : shared = undef;

# A global shared semaphore, designed to limit read/write
# access to $driverData, by only allowing one thread
# at a time to freeze/thaw the data.  While $driverData is
# a scalar, the freeze/thaw operation is not atomic; thus,
# this semaphore ensures all operations remain atomic.
our $driverDataSemaphore     = Thread::Semaphore->new(1);

# A globally shared hashtable, containing one "update queue"
# per driver.  This allows different "driver threads" to
# receive asynchronous updates to their state information
# in a thread-safe manor.
our %driverUpdateQueues : shared = ( );

#######################################################################
# Daemon Initialization / Destruction                                 #
#######################################################################

=pod

=head1 LOCAL FUNCTIONS

The following init() and destroy() functions are the only direct
calls required to startup and shutdown the SOAP server.

All other interactions with this daemon should be performed as
C<SOAP::Lite> function calls, in order to ensure consistency across
client sessions.  See the L<"EXTERNAL SOAP FUNCTIONS"> section, for
more details.

=head2 HoneyClient::Agent->init(address => $localAddr, port => $localPort, ...)

=over 4

Starts a new SOAP server, within a child process.

I<Inputs>:
 B<$localAddr> is an optional argument, specifying the IP address for the SOAP server to listen on.
 B<$localPort> is an optional argument, specifying the TCP port for the SOAP server to listen on.

Additionally optional, driver-specific arguments can be specified 
as sub-hashtables, where the top-level key corresponds to the name of 
the implemented driver and the value contains all the expected hash data
that can be fed to HoneyClient::Agent::Driver->new() instances.

 Here is an example set of arguments:

   HoneyClient::Agent->init(
       address => '127.0.0.1',
       port    => 9000,
       IE      => {
           timeout => 30,
           links_to_visit => {
               'http://www.mitre.org/' => 1,
           },
       },
   );

 
I<Output>: The full URL of the web service provided by the SOAP server.

=back

=begin testing

# XXX: Test init() method.
our $URL = HoneyClient::Agent->init();
our $PORT = getVar(name      => "port", 
                   namespace => "HoneyClient::Agent");
our $HOST = getVar(name      => "address",
                   namespace => "HoneyClient::Agent");
is($URL, "http://$HOST:$PORT/HoneyClient/Agent", "init()") or diag("Failed to start up the VM SOAP server.  Check to see if any other daemon is listening on TCP port $PORT.");

=end testing

=cut

# TODO: Update documentation to reflect hash-based args.
sub init {
    # Extract arguments.
    # Hash-based arguments are used, since HoneyClient::Util::SOAP is unable to handle
    # hash references directly.  Thus, flat hashtables are used throughout the code
    # for consistency.
    my ($class, %args) = @_;

    # Sanity check.  Make sure the daemon isn't already running.
    if (defined($DAEMON_PID)) {
        Carp::croak "Error: " . __PACKAGE__ . " daemon is already running (PID = $DAEMON_PID)!\n";
    }

    # Acquire data lock.
    _lock();

    # Initialize the $driverData shared hashtable.
    my $data = { };
    for my $driverName (@DRIVERS) {

        # TODO: Figure out which drivers' data to initialize, based upon
        # which driver argument hashtables were provided.  Then keep
        # that list in a globally, defined array.
        
        $data->{$driverName} = { 
            'state'     => undef,
            'thread_id' => undef,
            'status'    => undef,
            'next'      => undef,
        };

        # Initialize the corresponding %driverUpdateQueues
        $driverUpdateQueues{$driverName} = new Thread::Queue;
    }

    # Release data lock.
    _unlock($data);

    my $argsExist = scalar(%args);

    if (!($argsExist && 
          exists($args{'address'}) &&
          defined($args{'address'}))) {
        $args{'address'} = getVar(name => "address");
    }

    if (!($argsExist && 
          exists($args{'port'}) &&
          defined($args{'port'}))) {
        $args{'port'} = getVar(name => "port");
    }

    $URL_BASE = "http://" . $args{'address'} . ":" . $args{'port'};
    $URL = $URL_BASE . "/" . join('/', split(/::/, __PACKAGE__));

    my $pid = undef;
    if ($pid = fork) {
        # We use a local variable to get the pid, and then we set the global
        # DAEMON_PID variable after the fork().  This is intentional, because
        # it seems the Win32 version of fork() doesn't seem to be an atomic
        # operation.
        $DAEMON_PID = $pid;
        return $URL;
   
    } else {
        # Make sure the fork was successful.
        if (!defined($pid)) {
            Carp::croak "Error: Unable to fork child process.\n$!";
        }

        # Do not attempt to rejoin parent process tree,
        # if any type of termination signal is received.
        local $SIG{HUP} = sub { exit; };
        local $SIG{INT} = sub { exit; };
        local $SIG{QUIT} = sub { exit; };
        local $SIG{ABRT} = sub { exit; };
        local $SIG{PIPE} = sub { exit; };
        local $SIG{TERM} = sub { exit; };

        my $daemon = getServerHandle(address => $args{'address'},
                                     port    => $args{'port'});

        # Populate our driver's object state with the remaining
        # arguments.
        delete($args{'address'});
        delete($args{'port'});

        # If this call fails, an exception is thrown or the process
        # remains locked.  If the process locks, then external
        # detection is used to catch for these types of failures.
        updateState($class, encode_base64(nfreeze(\%args)));
    
        for (;;) {
            $daemon->handle;
        }
    }
}

=pod

=head2 HoneyClient::Agent->destroy()

=over 4

Terminates the SOAP server within the child process.

I<Output>: True if successful, false otherwise.

=back

=begin testing

# XXX: Test destroy() method.
is(HoneyClient::Agent->destroy(), 1, "destroy()") or diag("Unable to terminate Agent SOAP server.  Be sure to check for any stale or lingering processes.");

# TODO: delete this.
#exit;

=end testing

=cut

sub destroy {
    my $ret = undef;
    # Make sure the PID is defined and not
    # the parent process...
    if (defined($DAEMON_PID) && ($DAEMON_PID != 0)) {
        # The Win32 version of kill() seems to only respond to SIGKILL(9).
        $ret = kill(9, $DAEMON_PID);
    }
    if ($ret) {
        # Acquire data lock.
        _lock();

        # Destroy all globally shared state data.
        $URL                  = undef;
        $URL_BASE             = undef;
        $DAEMON_PID           = undef;
        $driverData           = undef;
        $driverDataSemaphore  = Thread::Semaphore->new(1);
        %driverUpdateQueues   = ( );

        # Release data lock.
        _unlock();
    }
    return $ret;
}

#######################################################################
# Private Methods Implemented                                         #
#######################################################################

# Helper function designed to acquire exclusive access to the
# shared $driverData, for use within any thread.
#
# In perl, it is difficult to share hashtables between threads.
# However, it is easy to share scalars between threads.
# As such, we share a hashtable between threads by *serializing*
# the data using nfreeze().  The result can be stored in a scalar.
# 
# When we are in a thread where we subsequently want to read/use
# this hashtable, we thaw() the serialized data (it performs the
# deserialization process) and use the hashtable accordingly.
#
# This function guarantees that no other thread will access
# $driverData and returns the thaw()'d contents of $driverData.
#
# Input: None
# Output: driverData (deserialized)
sub _lock {
    # Acquire lock on stored driver state.
    $driverDataSemaphore->down();
        
    # Thaw the data.
    return thaw($driverData);
}

# Helper function designed to release exclusive access to the
# shared $driverData, for use within any thread.
#
# By calling this function, we assume that the thread has already
# called _lock() and would like to (optionally) update $driverData
# with a new, modified hashtable, prior to releasing the lock
# on $driverData.
#
# This function can optionally take in a normal hashtable reference,
# overwriting the $driverData with the contents of the supplied
# hashtable.  Once the $driverData's updated contents has been
# set and serialized, this function releases the corresponding
# lock.
#
# Input: driverData (deserialized, optional)
# Output: None
sub _unlock {
    my $data = shift;

    if (defined($data)) {
        # Refreze changed data.
        $driverData = nfreeze($data);
    }
    
    # Release lock on stored driver state.
    $driverDataSemaphore->up();
}

# Helper function designed to retrieve queued, external
# updates to driver state information from %driverUpdateQueues.
# 
# When called from run(), this function takes in the corresponding
# Driver object; checks to see if there's a new entry within the
# driver's corresponding update queue; and dequeues the *first*
# entry in the queue, overwriting the Driver's state data
# accordingly.
#
# The external updateState() call adds new driver state into the queue,
# one entry per call.  The internal _update() function merges this
# driver state with the currently running driver, one merge
# operation per call.  In order words, a single call to _update()
# may *NOT* empty the corresponding Driver update queue completely
# -- only one entry within the queue will be dequeued per _update()
# call made.
#
# Input: driver
# Output: driver (updated)
sub _update {
    # Extract arguments.
    my $driver = shift;

    # Figure out the corresponding driver name.
    my @package = split(/::/, ref($driver));
    my $driverName = pop(@package);

    # Extract the corresponding queue.
    my $queue = $driverUpdateQueues{$driverName};

    # If we have data in our driver specific queue...
    if ($queue->pending) {

        # Update our driver state with the first entry
        # found...
        my $queuedData = thaw($queue->dequeue_nb);

        # Sanity check: Only copy defined data.
        if (defined($queuedData)) {

            # Copy (and overwrite) overloaded object data 
            # into shared memory.  This looks creepy, I know, but
            # it actually works.  We're essentially identifying
            # driver-specific parameters that the user supplied
            # via $queuedData and overwriting our current driver state
            # with any matching, user supplied values.
            @{$driver}{keys %{$queuedData}} = values %{$queuedData};
        }
    }

    # Return the modified driver state.
    return $driver;
}

#######################################################################
# Public Methods Implemented                                          #
#######################################################################

=pod

=head1 EXPORTS

=head2 run()

=over 4

# XXX: Fill this in.

I<Inputs>: 
 B<$arg> is an optional argument.
SOAP server to listen on.
 
I<Output>: XXX: Fill this in.

=back

=begin testing

# XXX: Fill this in.
1;

=end testing

=cut

sub run {
    # Extract arguments.

    # Temporary variable, used to hold thawed driver data.
    my $data = undef;

    # Temporary variable, used to hold thread IDs.
    my $tid = undef;

    # Temporary variable, used to hold thread objects.
    my $thread = undef;

    # TODO: Eventually, use the globally defined array
    # of actual drivers used (set by init()).
    for my $driverName (@DRIVERS) {

        # Acquire data lock.
        $data = _lock();

        # Read the TID.
        $tid = $data->{$driverName}->{'thread_id'};
        
        # Sanity check: Return false, if we already have a
        # driver thread running.
        if (defined($tid) &&
            defined($thread = threads->object($tid)) &&
            $thread->is_running()) {

            # Release data lock.
            _unlock();

            return 0;
        }

        # Quickly define a temporary thread ID.
        # This value is simply a placeholder that will
        # get redefined later on in this function to
        # the thread's valid ID, once the thread has been
        # initialized.
        #
        # By defining a placeholder valid here, we avoid
        # a potential race condition, where multiple calls
        # to run() are made consecutively.
        #
        # Temporarily set the driver thread to be the
        # main thread.
        $data->{$driverName}->{'thread_id'} = 0;
        
        # Release data lock.
        _unlock($data);

        # TODO: Clean up this comment block.
        # This function should do the following:
        # - Initialize all drivers with starting state.
        # - "Drive" each driver, one-by-one.
        # - Collect any integrity violations found, with offending
        #   state information.
        #
        # Notes:
        # This function will eventually sit in a sub-thread, allowing the parent
        # thread to return without any delay.  It is expected that the Manager
        # would then subsequently call a getStatus() operation, in order to
        # then poll for any new violations found.
        #
        # TODO: We need to create a fault reporting mechanism, in order
        # to properly deal with exceptions/faults that occur within this
        # thread.
        $thread = async {
            threads->yield();
    
            # Trap all faults that may occur from these asynchronous operations.
            eval {

                my $integrity = undef;
                if ($PERFORM_INTEGRITY_CHECKS) {
                    print "Initializing Filesystem Integrity Check...\n";
                    # TODO: Initialize Integrity Checks
                    $integrity = HoneyClient::Agent::Integrity->new();
                    $integrity->initAll();
                }
 
                ###################################
                ### Driver Initialization Phase ###
                ###################################
                
                # Initially set all driver objects to undef. 
                my $driver = undef;
    
                # Acquire lock on stored driver state.
                $data = _lock();

                # Now, initialize each driver object. 
                # Figure out which $driver object to use...
                my $driverClass = 'HoneyClient::Agent::Driver::Browser::' . $driverName;
                
                if (!defined($data->{$driverName}->{'state'})) {
    
                    # If the driver state is undefined, then
                    # create a new state object.
                    $driver = $driverClass->new();

                } else {
                    # Then the driver state object is already defined,
                    # so go ahead and reuse it.
                    $driver = $driverClass->new(
                        %{$data->{$driverName}->{'state'}}, 
                    );
                }

                # Next, we make sure we have no updates, before we update
                # the corresponding shared memory version.
                $driver = _update($driver);

                # Once we've initialized the object, be sure to update
                # the corresponding shared memory version.  We do this
                # one time before the loop starts, in case we end up
                # finishing before we drove anywhere.
                
                # Copy object data to shared memory.
                $data->{$driverName}->{'next'} = $driver->next();
                $data->{$driverName}->{'status'} = $driver->status();
                $data->{$driverName}->{'status'}->{'is_compromised'} = 0;
                $data->{$driverName}->{'state'} = $driver;

                if ($driver->isFinished()) {
                    # Thread is about to finish, set the ID back to undef.
                    # This looks ugly, but setting it this early avoids the
                    # potential race condition of when the run() thread is finished
                    # and when updateState() checks for $driverData->{$driverName}->{'thread_id'}
                    # to be set to undef.
                    $data->{$driverName}->{'thread_id'} = undef;
                }

                # Release lock on stored driver state.
                _unlock($data);
                
                ###################################
                ### Driver Running Phase        ###
                ###################################

                # Boolean to indicate that the driver is about to transition
                # to a new set of targets upon the next drive() operation.
                my $driverTargetsChanged = 0;

                while (!$driver->isFinished() && !$driverTargetsChanged) {
                    # XXX: Debug.  Remove this.
                    # We assume $driver->next() returns defined data.
                    foreach my $resource (keys %{$driver->next()->{resources}}) {
                        print "Using Resource: " . $resource . "\n";
                    }

                    # Drive the driver for one step.
                    # If the operation fails, then an exception will be generated.
                    $driver->drive();
   
                    # Acquire lock on stored driver state.
                    $data = _lock();
                    
                    # Check for any additional external driver updates.
                    $driver = _update($driver);

                    # Check to see if our driver's targets have changed.
                    $driverTargetsChanged = not(Compare($data->{$driverName}->{'next'}->{'targets'}, $driver->next()->{'targets'}));

                    # Copy object data to shared memory.
                    $data->{$driverName}->{'next'} = $driver->next();
                    $data->{$driverName}->{'status'} = $driver->status();
                    $data->{$driverName}->{'status'}->{'is_compromised'} = 0;
                    $data->{$driverName}->{'state'} = $driver;

                    if ($driver->isFinished() or $driverTargetsChanged) {
                        # Thread is about to finish, set the ID back to undef.
                        # This looks ugly, but setting it this early avoids the
                        # potential race condition of when the run() thread is finished
                        # and when updateState() checks for $driverData->{$driverName}->{'thread_id'}
                        # to be set to undef.
                        $data->{$driverName}->{'thread_id'} = undef;
                    }

                    # Release lock on stored driver state.
                    _unlock($data);
                }
                
                # Acquire lock on stored driver state.
                $data = _lock();
                
                # TODO: Perform Integrity Check
                if (defined($integrity)) {
                    # For now, we update a scalar called 'is_compromised' within
                    # the $data->{$driverName}->{'status'} sub-hashtable.
                    print "Performing Filesystem Integrity Check...\n";
                    if ($integrity->checkAll()) {
                        print "Integrity Check: FAILED\n";
                        $data->{$driverName}->{'status'}->{'is_compromised'} = 1;
                    } else {
                        print "Integrity Check: PASSED\n";
                    }
                }

                # Release lock on stored driver state.
                _unlock($data);

                # XXX: Debugging, remove eventually. 
                print "Exiting run() thread.\n";
                #print Dumper($driver);
                # Verbose debugging:
                #print Dumper($driver->status());
                # Short-hand debugging:
                #my $status = $driver->status();
                #print "R(" . $status->{relative_links_remaining} . ") | [ " .
                #      "V(" . $status->{links_remaining} . ") + ".
                #      "P(" . $status->{links_processed} . ") = " .
                #      "T(" . $status->{links_total} . ") ] " .
                #      "| (" . $status->{percent_complete} . ")\n";
            };
    
            ###################################
            ### Driver Cleanup Phase        ###
            ###################################
           
            # Check to see if any errors occurred within the thread.
            # Queue any faults found, to transmit back to the next SOAP
            # caller. 
            if ($@) {
                # Release any pending locks, to avoid deadlocks.
                _unlock();

                # Acquire lock on stored driver state.
                $data = _lock();
                 
                # Make sure we update our state to reflect ourself dying.
                $data->{$driverName}->{'thread_id'} = undef;

                # Release lock on stored driver state.
                _unlock($data);
    
                # TODO: Do proper fault queuing.
                print "FAULT: " . $@ . "\n";
            }

            threads->detach(); # XXX: Test this.
            return;
        };
            
        # Acquire data lock.
        $data = _lock();
            
        # Set the valid thread ID.
        if ($thread->is_running()) {
            $data->{$driverName}->{'thread_id'} = $thread->tid();
        } else {
            $data->{$driverName}->{'thread_id'} = undef;
        }

        # Release data lock.
        _unlock($data);
    }

    # At this point, the driver thread is initialized and running,
    # return true.
    return 1;
}

# XXX: Document this.
# Should be something like:
#  updateState(
#    IE => {
#       links  => [ url1, url2, ... , ],
#       params => {
#           timeout => 5,
#           blah    => "testing",
#       },
#    },
#  )
# TODO: When updateState() hashtable data is sent across SOAP,
# we get the warning message:
# 
# Cannot encode 'links_to_visit' element as 'hash'.
# Will be encoded as 'map' instead.
#
# Check to make sure this issue is not critical.
#
# We must base64 encode the data, since SOAP doesn't like URLs
# that contain amperstands.
sub updateState {

    # Extract arguments.
    my ($class, $arg) = @_;
    my %args = ();

    # Decode serialized hash.
    if (defined($arg)) {
        %args = %{thaw(decode_base64($arg))};
    }

    my $argsExist = scalar(%args);

    # Temporary variable, used to hold thawed driver data.
    my $data = undef;

    # Temporary variable, used to hold thread IDs.
    my $tid = undef;

    # Temporary variable, used to hold retrieved driver state.
    my $driver = undef;

    # Temporary variable, used to hold thread objects.
    my $thread = undef;

    # Figure out which driver to use.
    for my $driverName (@DRIVERS) {
  
        # If the corresponding key within the argument
        # hash does not exist or is not defined, then
        # go ahead and skip to the next  
        if (!($argsExist && 
              exists($args{$driverName}) &&
              defined($args{$driverName}))) {
            next;
        }

        # Enqueue the updated state information.
        # If this call fails, an exception is thrown or the process
        # remains locked.  If the process locks, then external
        # detection is used to catch for these types of failures.
        $driverUpdateQueues{$driverName}->enqueue(nfreeze($args{$driverName}));

        # Acquire data lock.
        $data = _lock();

        # Sanity check: See if the run() thread is already running.
        $tid = $data->{$driverName}->{'thread_id'};
        if (defined($tid) &&
            defined($thread = threads->object($tid)) &&
            $thread->is_running()) {

            # The run() thread is active, so we assume that the run() thread will actually
            # merge these updates into the shared driver state.

            # Release data lock.
            _unlock();

        } else {
            
            # If we've gotten this far, then the run() thread is no longer active,
            # which means that we have to manually update the driver state
            # information.

            # Initialize the driver object. 
            # Figure out which $driver object to use...
            my $driverClass = 'HoneyClient::Agent::Driver::Browser::' . $driverName;
                
            if (!defined($data->{$driverName}->{'state'})) {
    
                # If the existing driver state is undefined, then
                # create a new state object.
                $driver = $driverClass->new();

            } else {
                # Else the driver state object is already defined,
                # so go ahead and reuse it.
                $driver = $driverClass->new(
                    %{$data->{$driverName}->{'state'}}, 
                );
            }

            # Once we have the correct driver state (either newly initialized or
            # preinitialized from a prior run() thread), we need to update this 
            # state with our new information.
            $driver = _update($driver);

            # Copy object data to shared memory.
            $data->{$driverName}->{'next'} = $driver->next();
            $data->{$driverName}->{'status'} = $driver->status();
            # XXX: This may not be ideal, as a previous compromised status indicator
            # would get overwritten, during the next updateState() call.
            $data->{$driverName}->{'status'}->{'is_compromised'} = 0;
            $data->{$driverName}->{'state'} = $driver;

            # Release data lock.
            _unlock($data);
        }
    }
}

# XXX: Document this.
sub getState {
    my $ret  = undef;
    _lock();

    # Sanity check.
    if (defined($driverData)) {

        # We're only interested in driver state information
        # (and no other status information).  Thus, we prune the
        # hashtable, before transmitting.
        my $data = thaw($driverData);
        my $driverName = undef;
        my @driverNames = keys %{$data};

        foreach $driverName (@driverNames) {
            $data->{$driverName} = $data->{$driverName}->{'state'};
        }
        $ret = encode_base64(nfreeze($data));
    }
    _unlock();
    return $ret;
}

# XXX: Document this.
sub getStatus {
    my $ret = undef;
    _lock();
    if (defined($driverData)) {
        $ret = encode_base64($driverData);
    }
    _unlock();
    return $ret;
}

# XXX: Document this.
# XXX: Do we really need this?
sub shutdown {

    print "Shutting down...\n";

    # Shutdown in 5 seconds after returning.
    my $thread = async {
        threads->yield();
        sleep(5);
        exit;
    };

    # Return true.
    return 1;
}

# XXX: Document this.
# TODO: Make this more robust.
sub killProcess {

    # Extract arguments.
    my ($class, $processName) = @_;

    # Sanity check.
    unless (defined($processName)) {
        return 0;
    }

    # TODO: Need unit tests.
    require Win32::Process;
    require Win32::Process::Info;

    # Create a new process inspector.
    my $inspector = Win32::Process::Info->new();
    my @procs = $inspector->GetProcInfo();

    foreach my $proc (@procs) {
        if ($proc->{Name} eq $processName) {
            # TODO: Should this statement be in here?
            Carp::carp "Killing Process ID: " . $proc->{ProcessId} . "\n";
            Win32::Process::KillProcess($proc->{ProcessId}, 0);
        }
    }

    return 1;
}

#######################################################################

1;

#######################################################################
# Additional Module Documentation                                     #
#######################################################################

__END__

=head1 BUGS & ASSUMPTIONS

# XXX: Fill this in.

=head1 SEE ALSO

XXX: Fill this in.

XXX: If you have a mailing list, mention it here.

XXX: If you have a web site set up for your module, mention it here.

=head1 REPORTING BUGS

XXX: Mention website/mailing list to use, when reporting bugs.

=head1 ACKNOWLEDGEMENTS

Paul Kulchenko for developing the SOAP::Lite module.

=head1 AUTHORS

Kathy Wang, E<lt>knwang@mitre.orgE<gt>

Thanh Truong, E<lt>ttruong@mitre.orgE<gt>

Darien Kindlund, E<lt>kindlund@mitre.orgE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2006 The MITRE Corporation.  All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, using version 2
of the License.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.


=cut