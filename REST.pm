=head1 VERSION

This documentation describe Net::Redmine::API::REST version 0.001

=head1 NAME

Net::Redmine::API::REST - REST API for Redmine's GET,POST,PUT,DELETE manipulation

=head1 SYNOPSIS

    use Net::Redmine::API::REST;

    my $object = Net::Redmine::API::REST->new (
        Url => 'http://redmine.test.com',
        Server => 'redmine.test.com',
        Port => '80',
        UserName => 'user',
        PassWord => 'pass'
    );  # object for methods using 

    my $ref_hash = $object->get_issue_by_id('1'); # Call of the method get_issue_by_id

=head1 DESCRIPTION

This is a module for Redmine's GET,POST,PUT,DELETE manipulation in order :
  -create an object Net::Redmine::API::REST with this params :
   Url [required]   # probably http://Redmine.[yourCompany].com
   Server [required] # probably Redmine.[yourCompany].com
   Port  [default=80] # 443 for https use
   UserName
   PassWord

   exemple :
    my $object = Net::Redmine::API::REST->new ( 
        Url => 'http://redmine.test.com',
        Server => 'redmine.test.com',
        Port => '80',
        UserName => 'user',
        PassWord => 'pass'
    );

  -use GET,POST,PUT,DELETE object's methods
   exemple : 
    $object->get_issue_by_id('1');

=head1 AUTHOR

Schoorens Stephane
 e-mail : sschoorens@lncsa.com

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011 LNCSA (contact@lncsa.com)

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself

=head1 MODIFICATIONS

Last modification : nothing.

=head1 SEE ALSO

HTTP::Request, LWP::UserAgent, JSON, Moose,

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

package Net::Redmine::API::REST;

use vars qw($VERSION @EXPORT_OK @ISA);

use strict;
use warnings;
use 5.010;

use HTTP::Request;
use LWP::UserAgent;
use JSON;
use Moose;
use Switch;
use Carp;

our $VERSION = '0.001';

has Url    => ( is => 'rw', isa => 'Str', required => 1 );
has Server => ( is => 'rw', isa => 'Str', required => 1 );
has Port   => ( is => 'rw', isa => 'Str', default  => '80' );
has UserName   => ( is => 'rw', isa => 'Str' );
has PassWord   => ( is => 'rw', isa => 'Str' );
has Projects => ( is => 'rw', isa => 'HashRef' );
has Issues => ( is => 'rw', isa => 'HashRef' );
has Users => ( is => 'rw', isa => 'HashRef' );
has Statuses => ( is => 'rw', isa => 'HashRef' );
has Priorities => ( is => 'rw', isa => 'HashRef' );
has Trackers => ( is => 'rw', isa => 'HashRef' );
has Categories => ( is => 'rw', isa => 'HashRef' );

sub BUILD {
  my $self = shift ;
  $self->load_elements;
}

=head1 METHODS

=cut

=head2 load_elements

=head3 Description : 

Set a reference on a hash into the object's statuses.

=head3 Parametre :

Nothing

=head3 Return :

Nothing

=head3 Use Exemple :    

    $object->load_elements;

=cut

sub load_elements{
      my ( $self ) = @_;
      my $ua = LWP::UserAgent->new;
      $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
      my $request = HTTP::Request->new( GET => $self->{Url} . '/issue_statuses.json' );
      my $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Statuses'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please statuses load failed' ."\n" ;
      }
      $request = HTTP::Request->new( GET => $self->{Url} . '/enumerations.json' );
      $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Priorities'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please priorities load failed' ."\n" ;
      }
      $request = HTTP::Request->new( GET => $self->{Url} . '/trackers.json' );
      $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Trackers'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please trackers load failed' ."\n" ;
      }
      $request = HTTP::Request->new( GET => $self->{Url} . '/issue_categories.json' );
      $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Categories'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please categories load failed' ."\n" ;
      }
}

=head2 load_projects

=head3 Description : 

Set a reference on a hash into the attribute Projects.

=head3 Parametre :

Nothing

=head3 Return :

Nothing

=head3 Use Exemple :    

    $object->load_projects;

=cut

sub load_projects{
      my ( $self ) = @_;
      my $ua = LWP::UserAgent->new;
      $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
      my $request = HTTP::Request->new( GET => $self->{Url} . '/projects.json' );
      my $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Projects'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please' ."\n" ;
      }
}

=head2 load_users

=head3 Description : 

Set a reference on a hash into the attribute Users.

=head3 Parametre :

Nothing

=head3 Return :

Nothing

=head3 Use Exemple :    

    $object->load_users;

=cut

sub load_users{
      my ( $self ) = @_;
      my $ua = LWP::UserAgent->new;
      $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
      my $request = HTTP::Request->new( GET => $self->{Url} . '/users.json' );
      my $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Users'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please (perhaps you need access right to load users) ' ."\n" ;
      }
}

=head2 load_issues

=head3 Description : 

Set a reference on a hash into the attribute Issues.

=head3 Parametre :

Nothing

=head3 Return :

Nothing

=head3 Use Exemple :    

    $object->load_issues;

=cut

sub load_issues{
      my ( $self ) = @_;
      my $ua = LWP::UserAgent->new;
      $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
      my $request = HTTP::Request->new( GET => $self->{Url} . '/issues.json' );
      my $response = $ua->request($request);
      if ( $response->is_success ) {
	$self->{'Issues'} = decode_json $response->content;
      }
      else {
        croak  $response->status_line . "\n" . 'Check your config object please' ."\n" ;
      }
}

=head2 get_issue_by_id

=head3 Description : 

return a reference on a hash who contains the issue

=head3 Parametre :

$id   issue's ID

=head3 Return :

$ref_hash       return a reference on a hash

undef           if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_issue_by_id($id);

=cut

sub get_issue_by_id {
    my ( $self, $id ) = @_;
    if ( !(($id) =~ /^\d+$/) ){
      croak 'the id : "'.$id.'" is not an integer '."\n";
    }
    if ( defined ( $self->{'Issues'} ) ) {
	my $issue;
	my $i=0;
	while ( defined($issue=$self->{'Issues'}->{'issues'}[$i] ) ) {
	      if ($issue->{'id'} eq $id){
		  return  $issue;
	      }
	      else{
	      $i++;
	      }
	}
        return undef;
    }
    else{
      $self->load_issues;
      my $issue;
      my $i=0;
      while ( defined( $issue=$self->{'Issues'}->{'issues'}[$i] ) ) {
	      if ($issue->{'id'} eq $id){
		  return  $issue;
	      }
	      else{
	      $i++;
	      }
	}
       return undef;
    }
    
}

=head2 get_issue_by_subject

=head3 Description : 

return a reference on a hash who contains the issue

=head3 Parametre :

$subject   issue's Subject

=head3 Return :

$issue       return a reference on a hash

undef        if not exists

=head3 Use Exemple :    

    my $ref_hash=$object->get_issue_by_subject('test');

=cut

sub get_issue_by_subject {
    my ( $self, $subject ) = @_;
    if ( defined ( $self->issue_subject_to_id($subject)  ) ){
      return ( $self->get_issue_by_id( $self->issue_subject_to_id($subject) ) );   
    }
    else{
       return undef; 
    }
}

=head2 get_issues

=head3 Description : 

return a reference on a hash who contains issues

=head3 Parametre :

nothing

=head3 Return :

$issue          return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_issues();

=cut


sub get_issues {
    my ($self) = @_;
    if ( defined($self->{'Issues'} ) ){
      return $self->{'Issues'};
    }else{
	$self->load_issues ;
      return $self->{'Issues'};
    }
}

=head2 get_issues

=head3 Description : 

return a reference on a hash who contains project's issues

=head3 Parametre :

$name           The project's name

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_issues('test');

=cut

sub get_project_issues {
    my ($self,$name) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request = HTTP::Request->new( GET => $self->{Url}.'/projects/'.$name. '/issues.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        croak print $response->status_line . "\n" . 'Check your config object please' ."\n" ;
    }
}

=head2 post_issue

=head3 Description : 

Send a POST request with the hash value
  required elements :
   'status' 
   'tracker' 
   'priority' 
   'subject'
  OR
   'status_id' 
   'tracker_id' 
   'priority_id' 
   'subject'

=head3 Parametre :

$hash           A reference on a hash construct like this : 

    my $hash={
        'issue' =>
            { 
                'Redmine key' => 'Value',
            }
    };

=head3 Return :

$id        when the POST request it's done

0         if the function failed

=head3 Use Exemple :  

    my $hash={
        'issue' =>
            { 
                'done_ratio' => 90,
                'description' => 'Post',
                'category' => 'market',
                'status' => 'new' ,
                'author' =>  'develloper' ,
                'subject' => 'Test post',
                'assigned_to' => 'admin',
                'tracker' => 'bug' ,
                'project' => 'test',
		'start_date' => '2011/04/12',
                'due_date' => '2011/04/12',
                'estimated_hours' => 100.0,
                'priority' => 'hot',
            }
    };
    if ($object->post_issue($hash) > 0 ){
        say 'Great Job !';
    }

=cut

sub post_issue {
    my ( $self, $hash ) = @_;
    my $ref_hash = $self->hash_verification($hash,'post');
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/issues.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
	my $issue = decode_json $response->decoded_content ;
	my $id = $issue->{'issue'}->{'id'};
	$self->load_issues;
        return $id;
    }
    else {
        return 0;
    }
}

=head2 put_issue_by_id

=head3 Description : 

Send a PUT request with the hash value to the issue

=head3 Parametre :

$id             Issue's ID

$hash           A reference on a hash construct like this : 
    my $hash={
        'issue' =>
        {
            'Redmine key' => 'Value',
        }
    };

=head3 Return :

1               when the PUT request it's done

0               if the function failed

=head3 Use Exemple : 

    my $hash={
        'issue' =>
        { 
            'priority_id' => '5',
            'notes' => 'this is a note for redmine issue'
        }
    };
    if ($object->put_issue_by_id($id,$hash) == 1){
        say 'Great Job !';
    }
=cut

sub put_issue_by_id {
    my ( $self, $id, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification($hash,'put');
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/issues/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
	$self->load_issues;
        return 1;
    }
    else {
        return 0;
    }
}


=head2 delete_issue_by_id

=head3 Description : 

Delete an issue by id.

=head3 Parametre :

$id             Issue's ID

=head3 Return :

1               return 1 when the delete request is done

0               if the function failed

=head3 Use Exemple :    

    if( $object->delete_issue_by_id($id) == 1 ){
        say 'you have deleted the issue '.$id;
    }

=cut

sub delete_issue_by_id {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( DELETE => $self->{Url} . '/issues/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
	$self->load_issues;
        return 1;
    }
    else {
        return 0;
    }
}

=head2 issue_subject_to_id

=head3 Description : 

Return the id of the issue's subject.

=head3 Parametre :

$subject           Issue's Subject

=head3 Return :

$id             return the id when the project exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->issue_subject_to_id($subject) ) ){
        say 'your issue ".$subject." have the id '.$object->issue_subject_to_id($subject);
    }

=cut

sub issue_subject_to_id{
    my ( $self, $subject ) = @_;
    if ( defined ( $self->{'Issues'} ) ){
      my $issue;
      my $i=0;
      while ( defined( $issue=$self->{'Issues'}->{'issues'}[$i] ) ) {
              if ($issue->{'subject'} eq $subject){
                  return  $issue->{'id'};
              }
              else{
              $i++;
              }
        }
      return undef;
    }else{
      $self-> load_issues ;
      my $issue;
      my $i=0;
      while ( defined( $issue=$self->{'Issues'}->{'issues'}[$i] ) ) {
              if ($issue->{'subject'} eq $subject){
                  return  $issue->{'id'};
              }
              else{
              $i++;
              }
        }
      return undef;
    }
}

=head2 project_name_to_id

=head3 Description : 

Return the id of the project's name.

=head3 Parametre :

$name           Project's Name

=head3 Return :

$id             return the id when the project exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->project_name_to_id($name) ) ){
        say 'your project ".$name." have the id '.$object->project_name_to_id($name);
    }

=cut
sub project_name_to_id{
    my ( $self, $name ) = @_;
    if ( defined ( $self->{'Projects'} ) ){
      my $project;
      my $i=0;
      while ( defined( $project=$self->{'Projects'}->{'projects'}[$i] ) ) {
	      if ($project->{'name'} eq $name){
		  return  $project->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
      return undef;
    }else{
      $self-> load_projects ;
      my $project;
      my $i=0;
      while ( defined( $project=$self->{'Projects'}->{'projects'}[$i] ) ) {
	      if ($project->{'name'} eq $name){
		  return  $project->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
      return undef;
    }
}

=head2 user_login_to_id

=head3 Description : 

Return the id of the user's login.

=head3 Parametre :

$login           User's Login

=head3 Return :

$id             return the id when the user exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->user_login_to_id($login) ) ){
        say 'your user ".$login." have the id '.$object->user_login_to_id($login);
    }

=cut

sub user_login_to_id{
    my ( $self, $login ) = @_;
    if ( defined ( $self->{'Users'} ) ){
	my $user;
	my $i=0;
	while ( defined( $user = $self->{'Users'}->{'users'}[$i] ) ) {
	      if ($user->{'login'} eq $login){
		  return  $user->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
	return undef;
    }
    else {
	$self->load_users ;
	my $user;
	my $i=0;
	while ( defined( $user = $self->{'Users'}->{'users'}[$i] ) ) {
	      if ($user->{'login'} eq $login){
		  return  $user->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
	return undef;
    }
}

=head2 status_name_to_id

=head3 Description : 

Return the id of the status's name.

=head3 Parametre :

$name           Status's Name

=head3 Return :

$id             return the id when the status exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->status_name_to_id($name) ) ){
        say 'your status ".$name." have the id '.$object->status_name_to_id($name);
    }

=cut

sub status_name_to_id{
    my ( $self, $name ) = @_;
    my $status;
    my $i = 0 ;
    while ( defined( $status=$self->{'Statuses'}->{'issue_statuses'}[$i] ) ) {
	      if ($status->{'name'} eq $name){
		  return  $status->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
    return undef ;   
}

=head2 tracker_name_to_id

=head3 Description : 

Return the id of the tracker's name.

=head3 Parametre :

$name           Tracker's Name

=head3 Return :

$id             return the id when the tracker exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->tracker_name_to_id($name) ) ){
        say 'your tracker ".$name." have the id '.$object->tracker_name_to_id($name);
    }

=cut

sub tracker_name_to_id{
    my ( $self, $name ) = @_;
    my $tracker;
    my $i = 0 ;
    while ( defined( $tracker=$self->{'Trackers'}->{'trackers'}[$i] ) ) {
	      if ($tracker->{'name'} eq $name){
		  return  $tracker->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
    return undef ;   
}

=head2 priority_name_to_id

=head3 Description : 

Return the id of the priority's name.

=head3 Parametre :

$name           Priority's Name

=head3 Return :

$id             return the id when the priority exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->priority_name_to_id($name) ) ){
        say 'your priority ".$name." have the id '.$object->priority_name_to_id($name);
    }

=cut

sub priority_name_to_id{
    my ( $self, $name ) = @_;
    my $priority;
    my $i = 0 ;
    while ( defined( $priority=$self->{'Priorities'}->{'enumerations'}[$i] ) ) {
	      if ( $priority->{'type'} eq q{IssuePriority} ){
		  if ( $priority->{'name'} eq $name ){
		    return  $priority->{'id'};
		    }
		  else{
		    $i++;
		  }
	      }
	      else{
	      $i++;
	      }
	}
    return undef ; 
}

=head2 category_name_to_id

=head3 Description : 

Return the id of the category's name.

=head3 Parametre :

$name           Category's Name

=head3 Return :

$id             return the id when the category exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->category_name_to_id($name) ) ){
        say 'your category ".$name." have the id '.$object->category_name_to_id($name);
    }

=cut

sub category_name_to_id{
    my ( $self, $name ) = @_;
    my $category;
    my $i = 0 ;
    while ( defined( $category=$self->{'Categories'}->{'issue_categories'}[$i] ) ) {
	      if ($category->{'name'} eq $name){
		  return  $category->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
    return undef ; 
}

=head2 hash_verification

=head3 Description : 

Verify a hash and give a result conform with the protocol

=head3 Parametre :ost

$hash          hash reference will be used to post or put everything on redmine

$action        Post or Put protocol to verify the required elements in Post

=head3 Return :

$result             return a good hash reference

0                   if the function failed

=head3 Use Exemple :    

    if( ref( $object->hash_verification($refhash,'post') ) eq 'HASH' ){
        say 'you can post the function return';
    }

=cut

sub hash_verification{
  my ($self, $hash,$action) = @_;
   my @cles = keys(%{$hash});
   my $cle = $cles[0];
   my $res = {};
   switch ($cle){
      case 'issue'{
	  my $issue =  $hash->{$cle};
	if  ( $action eq 'post' ){
	  if ( ( defined( $issue->{'status'} ) and defined( $issue->{'tracker'} ) and defined( $issue->{'priority'} ) and defined( $issue->{'subject'} ) ) 
	      or ( defined( $issue->{'status_id'} ) and defined( $issue->{'tracker_id'} ) and defined( $issue->{'priority_id'} ) and defined( $issue->{'subject_id'} ) ) ) 
          {
	     while (my ($c,$v) = each %{$issue}){
		switch ($c){
		      case 'status' {
			  $res->{'status_id'} = $self->status_name_to_id($v);
		      }
		      case 'tracker' {
			  $res->{'tracker_id'} = $self->tracker_name_to_id($v);
		      }
		      case 'priority' {
			  $res->{'priority_id'} = $self->priority_name_to_id($v);
		      }
		      case 'category' {
			  $res->{'category_id'} = $self->category_name_to_id($v);
		      }
		      case 'author' {
			  $res->{'author_id'} = $self->user_login_to_id($v);
		      }
		      case 'assigned_to' {
			  $res->{'assigned_to_id'} = $self->user_login_to_id($v);
		      }
		      case 'project' {
			  $res->{'project_id'} = $self->project_name_to_id($v);
		      }
		      else{
                          $res->{$c} = $v;
                      }
		}
	     }
	     my $result->{'issue'} = $res;
	     return $result;
	  }
	  else
	  {
	    return 0 ;
	  }
        }
      else{
	while (my ($c,$v) = each %{$issue}){
		switch ($c){
		      case 'status' {
			  $res->{'status_id'} = $self->status_name_to_id($v);
		      }
		      case 'tracker' {
			  $res->{'tracker_id'} = $self->tracker_name_to_id($v);
		      }
		      case 'priority' {
			  $res->{'priority_id'} = $self->priority_name_to_id($v);
		      }
		      case 'category' {
			  $res->{'category_id'} = $self->category_name_to_id($v);
		      }
		      case 'author' {
			  $res->{'author_id'} = $self->user_login_to_id($v);
		      }
		      case 'assigned_to' {
			  $res->{'assigned_to_id'} = $self->user_login_to_id($v);
		      }
		      case 'project' {
			  $res->{'project_id'} = $self->project_name_to_id($v);
		      }
		      else{
                          $res->{$c} = $v;
                      }
		}
	     }
	 my $result->{'issue'} = $res;
	 return $result;
      }
     }
     case 'user' {
	if  ($action eq 'post'){ 
	  if ( defined($hash->{'user'}{'login'}) and defined($hash->{'user'}{'mail'}) ){
	      return $hash ;
	  }
	  else{
	      return 0 ;
	  }
      }
      else{
      return $hash ;
      }
     }
     case 'project' {
        if  ($action eq 'post'){
          if ( defined($hash->{'project'}{'name'}) and defined($hash->{'project'}{'identifier'}) ){
              return $hash ;
          }
          else{
              return 0 ;
          }
        }
        else{
          return $hash ;
        }
     }
     else {
	  return 0;
     }
  }
}
=head2 get_user_by_id

=head3 Description : 

return a reference on a hash who contains the user

=head3 Parametre :

$id   user's ID

=head3 Return :

$ref_hash       return a reference on a hash

undef           if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_user_by_id($id);

=cut

sub get_user_by_id {
    my ( $self, $id ) = @_;
    if ( !(($id) =~ /^\d+$/) ){
      croak 'the id : "'.$id.'" is not an integer '."\n";
    }
    if ( defined ( $self->{'Users'} ) ) {
	my $user;
	my $i=0;
	while ( defined($user=$self->{'Users'}->{'users'}[$i] ) ) {
	      if ($user->{'id'} eq $id){
		  return  $user;
	      }
	      else{
	      $i++;
	      }
	}
        return undef;
    }
    else{
      $self->load_users ;
      my $user;
      my $i=0;
      while ( defined( $user=$self->{'Users'}->{'users'}[$i] ) ) {
	      if ($user->{'id'} eq $id){
		  return  $user;
	      }
	      else{
	      $i++;
	      }
	}
       return undef;
    }
}

=head2 get_user_by_name

=head3 Description : 

return a reference on a hash who contains the user

=head3 Parametre :

$name           User's Name

=head3 Return :

$user           return a reference on a hash

undef           if not exists or locked

=head3 Use Exemple :    

    my $ref_hash=$object->get_user_by_name('toto');

=cut

sub get_user_by_name {
    my ( $self, $name ) = @_;
    if ( defined ( $self->user_login_to_id($name)  ) ){
      return ( $self->get_user_by_id( $self->user_login_to_id($name) ) );
    }
    else{
     return undef;
    }
}

=head2 get_users

=head3 Description : 

return a reference on a hash who contains users
1
=head3 Parametre :

nothing

=head3 Return :

$ref_hash       return a reference on a hash

=head3 Use Exemple :    

    my $ref_hash=$object->get_users();

=cut


sub get_users {
    my ($self) = @_;
    if ( defined($self->{'Users'} ) ){
      return $self->{'Users'};
    }else{
	$self->load_users ;
      return $self->{'Users'};
    }
}

=head2 post_user

=head3 Description : 

Send a POST request with the hash value
  elements :
   'firstname'
   'lastname'
   'mail'
   'login'

=head3 Parametre :

$hash           A reference on a hash construct like this : 

    my $hash={
        'user' =>
            { 
                'Redmine key' => 'Value',
            }
    };1

=head3 Return :

$id       when the POST request it's done

0         if the function failed

=head3 Use Exemple :  

    my $hash={
        'user' =>
            {
                      'firstname' => 'Toto',
                      'mail' => 'toto@tata.fr',
                      'lastname' => '0+0',
                      'login' => 'toto',
            }
    };
    if ($object->post_user($hash) > 0){
        say 'Great Job !';
    }

=cut

sub post_user {
    my ( $self, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification($hash,'post');
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/users.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
	say Dumper $response->decoded_content;
	my $user = decode_json $response->decoded_content ;
	my $id = $user->{'user'}->{'id'};
	$self->load_users;
        return $id;
    }
    else {
        return 0;
    }
}



=head2 put_user_by_id

=head3 Description : 

Send a PUT request with the hash value to the user. You can lock a user by passing { 'status' => '3' } unlock  { 'status' => '1' }

=head3 Parametre :

$id             User's ID

$hash           A reference on a hash construct like this : 
    my $hash={
        'user' =>
        {
            'Redmine key' => 'Value',
        }
    };

=head3 Return :

1               when the PUT request it's done

0               if the function failed

=head3 Use Exemple : 

    my $hash={
        'user' =>
        { 
            'mail' => 'toto@fake.com'
        }
    };
    if ($object->put_user_by_id($id,$hash) == 1){
        say 'Great Job !';
    }
=cut

sub put_user_by_id {
    my ( $self, $id, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification($hash,'put');
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/users/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
	$self->load_users;
        return 1;
    }
    else {
        return 0;
    }
}

sub put_user_by_login {
    my ( $self, $login, $hash ) = @_;
    if ( defined ( $self->user_login_to_id($login)  ) ){
      return ( $self->put_user_by_id( $self->user_login_to_id($login),$hash ) );
    }
    else{
     return undef;
    }
}

=head2 get_project_by_id

=head3 Description : 

return a reference on a hash who contains the project

=head3 Parametre :

$id   project's ID

=head3 Return :

$project        return a reference on a hash

undef           if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_project_by_id($id);

=cut

sub get_project_by_id {
    my ( $self, $id ) = @_;
    if ( !(($id) =~ /^\d+$/) ){
      croak 'the id : "'.$id.'" is not an integer '."\n";
    }
    if ( defined ( $self->{'Projects'} ) ) {
        my $project;
        my $i=0;
        while ( defined($project=$self->{'Projects'}->{'projects'}[$i] ) ) {
              if ($project->{'id'} eq $id){
                  return  $project;
              }
              else{
              $i++;
              }
        }
        return undef;
    }
    else{
      $self->load_projects;
      my $project;
      my $i=0;
      while ( defined( $project=$self->{'Projects'}->{'projects'}[$i] ) ) {
              if ($project->{'id'} eq $id){
                  return  $project;
              }
              else{
              $i++;
              }
        }
       return undef;
   }
}

=head2 get_project_by_name

=head3 Description : 

return a reference on a hash who contains the project

=head3 Parametre :

$name           Project's Name

=head3 Return :

$project           return a reference on a hash

undef           if not exists or locked

=head3 Use Exemple :    

    my $ref_hash=$object->get_project_by_name('test');

=cut

sub get_project_by_name {
    my ( $self, $name ) = @_;
    if ( defined ( $self->project_name_to_id($name)  ) ){
      return ( $self->get_project_by_id( $self->project_name_to_id($name) ) );
    }
    else{
     return undef;
    }
}

=head2 post_project

=head3 Description : 

Send a POST request with the hash value
  elements :
       name (required): the project name
       identifier (required): the project identifier
       description




=head3 Parametre :

$hash           A reference on a hash construct like this : 

    my $hash={
        'project' =>
            { 
                'Redmine key' => 'Value',
            }
    };1

=head3 Return :

$id       when the POST request it's done

0         if the function failed

=head3 Use Exemple :  

    my $hash={
        'project' =>
            {
                      'name' => 'Test2',
                      'identifier' => 'test',
                      'description' => 'test',
            }
    };
    if ($object->post_project($hash) > 0){
        say 'Great Job !';
    }

=cut

sub post_project {
    my ( $self, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification($hash,'post');
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/projects.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $project = decode_json $response->decoded_content ;
        my $id = $project->{'project'}->{'id'};
        $self->load_projects;
        return $id;
    }
    else {
        return 0;
    }
}

=head2 put_project_by_id

=head3 Description : 

Send a PUT request with the hash value to the project.

=head3 Parametre :

$id             Project's ID

$hash           A reference on a hash construct like this : 
    my $hash={
        'project' =>
        {
            'Redmine key' => 'Value',
        }
    };

=head3 Return :

1               when the PUT request it's done

0               if the function failed

=head3 Use Exemple : 

    my $hash={
        'project' =>
        { 
            'name' => 'put_test'
        }
    };
    if ($object->put_project_by_id($id,$hash) == 1){
        say 'Great Job !';
    }
=cut

sub put_project_by_id {
    my ( $self, $id, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification($hash,'put');
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/projects/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        $self->load_projects;
        return 1;
    }
    else {
        return 0;
    }
}

sub put_project_by_name {
    my ( $self, $name,$hash ) = @_;
    if ( defined ( $self->project_name_to_id($name)  ) ){
      return ( $self->put_project_by_id( $self->project_name_to_id($name),$hash ) );
    }
    else{
     return undef;
    }
}

=head2 delete_project_by_id

=head3 Description : 

Delete an project by id.

=head3 Parametre :

$id             Project's ID

=head3 Return :

1               return 1 when the delete request is done

0               if the function failed

=head3 Use Exemple :    

    if( $object->delete_project_by_id($id) == 1 ){
        say 'you have deleted the project '.$id;
    }

=cut


sub delete_project_by_id {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( DELETE => $self->{Url} . '/projects/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        $self->load_projects;
        return 1;
    }
    else {
        return 0;
    }
}

sub delete_project_by_name {
    my ( $self, $name ) = @_;
    if ( defined ( $self->project_name_to_id($name)  ) ){
      return ( $self->delete_project_by_id( $self->project_name_to_id($name) ) );
    }
    else{
     return undef;
    }
}

1;
