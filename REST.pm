=head1 VERSION

This documentation describe Net::Redmine::API::REST version $Rev$

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

    my $ref_hash = $object->get-issue('1'); # Call of the method get_issue

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
    $object->get_issue('1');

Methods return 1 when they have a problem .

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

use Data::Dumper;

our $VERSION = '1.0';

has Url    => ( is => 'rw', isa => 'Str', required => 1 );
has Server => ( is => 'rw', isa => 'Str', required => 1 );
has Port   => ( is => 'rw', isa => 'Str', default  => '80' );
has UserName   => ( is => 'rw', isa => 'Str' );
has PassWord   => ( is => 'rw', isa => 'Str' );

=head1 METHODS

=cut

=head2 get_issue

=head3 Description : 

return a reference on a hash who contains the issue

=head3 Parametre :

$id   issue's ID

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_issue($id);

=cut

sub get_issue {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/issues/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        return 1;
    }
}

=head2 get_issues

=head3 Description : 

return a reference on a hash who contains issues

=head3 Parametre :

nothing

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_issues();

=cut


sub get_issues {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request = HTTP::Request->new( GET => $self->{Url} . '/issues.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        return 1;
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
        return 1;
    }
}

=head2 post_issue

=head3 Description : 

Send a POST request with the hash value
  required elements :
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

0         when the POST request it's done

1         if the function failed

=head3 Use Exemple :  

    my $hash={
        'issue' =>
            { 
                'done_ratio' => 90,
                'description' => 'Post',
                'category_id' => 1,
                'status_id' => 1,
                'author_id' => 1,
                'start_date' => '2011/04/12',
                'created_on' => '2011/04/12 11:20:21 +0200',
                'subject' => 'Test post',
                'assigned_to_id' => 1,
                'tracker_id' => 1,
                'project_id' => 1,
                'due_date' => '2011/04/12',
                'updated_on' => '2011/04/12 20:04:27 +0200',
                'estimated_hours' => 100.0,
                'priority_id' => 1,
            }
    };
    if ($object->post_issue($hash) == 0){
        say 'Great Job !';
    }

=cut

sub post_issue {
    my ( $self, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/issues.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        return 0;
    }
    else {
        return 1;
    }
}

=head2 put_issue

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

0               when the PUT request it's done

1               if the function failed

=head3 Use Exemple : 

    my $hash={
        'issue' =>
        { 
            'priority_id' => '5',
            'notes' => 'this is a note for redmine issue'
        }
    };
    if ($object->put_issue($id,$hash) == 0){
        say 'Great Job !';
    }
=cut

sub put_issue {
    my ( $self, $id, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/issues/' . $id . '.json' );
    my $json = encode_json $hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        return 0;
    }
    else {
        return 1;
    }
}


=head2 delete_issue

=head3 Description : 

Delete an issue by id.

=head3 Parametre :

$id             Issue's ID

=head3 Return :

0               return 0 when the delete request is done

1               if the function failed

=head3 Use Exemple :    

    if( $object->delete_issue($id) == 0 ){
        say 'you have deleted the issue '.$id;
    }

=cut

sub delete_issue {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( DELETE => $self->{Url} . '/issues/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        return 0;
    }
    else {
        return 1;
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
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/projects/' . $name . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash->{'project'}->{'id'};
    }
    else {
        return undef;
    }
}

=head2 user_name_to_id

=head3 Description : 

Return the id of the user's name.

=head3 Parametre :

$name           User's Name

=head3 Return :

$id             return the id when the user exist

undef           if the function failed

=head3 Use Exemple :    

    if( defined( $object->user_name_to_id($name) ) ){
        say 'your user ".$name." have the id '.$object->user_name_to_id($name);
    }

=cut

sub user_name_to_id{
    my ( $self, $name ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/users.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
	my $user;
	my $i=0;
	while ( defined( $user=$ref_hash->{'users'}[$i] ) ) {
	      if ($user->{'login'} eq $name){
		  return  $user->{'id'};
	      }
	      else{
	      $i++;
	      }
	}
        return undef;
    }
    else {
        return undef;
    }
}

=head2 get_user

=head3 Description : 

return a reference on a hash who contains the user

=head3 Parametre :

$id   user's ID

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_user($id);

=cut

sub get_user {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/users/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        return 1;
    }
}

=head2 get_users

=head3 Description : 

return a reference on a hash who contains users

=head3 Parametre :

nothing

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_users();

=cut


sub get_users {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request = HTTP::Request->new( GET => $self->{Url} . '/users.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        return 1;
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
    };

=head3 Return :

0         when the POST request it's done

1         if the function failed

=head3 Use Exemple :  

    my $hash={
        'user' =>
            {
                      'firstname' => "Toto",
                      'mail' => 'toto@tata.fr',
                      'lastname' => '0+0',
                      'login' => 'toto'
            }
    };
    if ($object->post_user($hash) == 0){
        say 'Great Job !';
    }

=cut

sub post_user {
    my ( $self, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/users.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        return 0;
    }
    else {
        return 1;
    }
}



=head2 put_user

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

0               when the PUT request it's done

1               if the function failed

=head3 Use Exemple : 

    my $hash={
        'user' =>
        { 
            'mail' => 'toto@fake.com'
        }
    };
    if ($object->put_issue($id,$hash) == 0){
        say 'Great Job !';
    }
=cut

sub put_user {
    my ( $self, $id, $hash ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/users/' . $id . '.json' );
    my $json = encode_json $hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        return 0;
    }
    else {
        return 1;
    }
}

1;