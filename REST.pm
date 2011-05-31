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
use CHI;
use Data::Dumper;

our $VERSION = '0.001';

has Url    => ( is => 'rw', isa => 'Str', required => 1 );
has Server => ( is => 'rw', isa => 'Str', required => 1 );
has Port   => ( is => 'rw', isa => 'Str', default  => '80' );
has UserName   => ( is => 'rw', isa => 'Str' );
has PassWord   => ( is => 'rw', isa => 'Str' );
has Cache      => ( is => 'rw', isa => 'Object' );
has LastError  => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ( $self, $args ) = @_;
    if ( defined $args->{Config_Cache} ) {
        $self->{'Cache'} = CHI->new( %{ $args->{Config_Cache} } );
        $self->load_statuses;
        $self->load_trackers;
        $self->load_priorities;
        $self->load_categories;
    }
    return;
}

sub get_last_error {
    my ($self) = @_;
    return ( $self->{'LastError'} );
}

sub load_statuses {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
        HTTP::Request->new( GET => $self->{Url} . '/issue_statuses.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->{'Cache'}
                ->set( 'Statuses', decode_json $response->content, '10 minutes' );
        }
        else {
            return ( decode_json $response->content );
        }
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
            . 'Check your config object please statuses load failed : '
            . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    return;
}

sub load_priorities {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/enumerations.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->{'Cache'}->set( 'Priorities', decode_json $response->content,
                '10 minutes' );
        }
        else {
            return ( decode_json $response->content );
        }
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config object please priorities load failed : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    return;
}

sub load_trackers {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request = HTTP::Request->new( GET => $self->{Url} . '/trackers.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->{'Cache'}
              ->set( 'Trackers', decode_json $response->content, '10 minutes' );
        }
        else {
            return ( decode_json $response->content );
        }
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config object please trackers load failed : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    return;
}

sub load_categories {
    my ($self) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( GET => $self->{Url} . '/issue_categories.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->{'Cache'}->set( 'Categories', decode_json $response->content,
                '10 minutes' );
        }
        else {
            return ( decode_json $response->content );
        }
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config object please categories load failed : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    return;
}

sub load_projects {
    my ( $self, $limit, $offset ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    if ( ( defined $limit ) and ( defined $offset ) ) {
        my $request =
          HTTP::Request->new( GET => $self->{Url}
              . '/projects.json?limit='
              . $limit
              . '&offset='
              . $offset );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set(
                    'Projects',
                    decode_json $response->content,
                    '10 minutes'
                );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    else {
        my $request =
          HTTP::Request->new( GET => $self->{Url} . '/projects.json' );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set(
                    'Projects',
                    decode_json $response->content,
                    '10 minutes'
                );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    return;
}

sub load_users {
    my ( $self, $limit, $offset ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    if ( ( defined $limit ) and ( defined $offset ) ) {
        my $request =
          HTTP::Request->new( GET => $self->{Url}
              . '/users.json?limit='
              . $limit
              . '&offset='
              . $offset );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set( 'Users', decode_json $response->content,
                    '10 minutes' );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    else {
        my $request = HTTP::Request->new( GET => $self->{Url} . '/users.json' );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set( 'Users', decode_json $response->content,
                    '10 minutes' );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    return;
}

sub load_issues {
    my ( $self, $limit, $offset ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    if ( ( defined $limit ) and ( defined $offset ) ) {
        my $request =
          HTTP::Request->new( GET => $self->{Url}
              . '/issues.json?limit='
              . $limit
              . '&offset='
              . $offset );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set( 'Issues', decode_json $response->content,
                    '10 minutes' );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    else {
        my $request =
          HTTP::Request->new( GET => $self->{Url} . '/issues.json' );
        my $response = $ua->request($request);
        if ( $response->is_success ) {
            if ( defined $self->{'Cache'} ) {
                $self->{'Cache'}->set( 'Issues', decode_json $response->content,
                    '10 minutes' );
            }
            else {
                return ( decode_json $response->content );
            }
        }
        else {
            $self->{'LastError'} =
                $response->status_line . "\n"
              . 'Check your config object please : '
              . $response->content . "\n";
            croak 'Error : ' . $self->get_last_error;
        }
    }
    return;
}

sub get_issue_by_id {
    my ( $self, $id ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    my $issues;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Issues') ) {
            $issues = $self->{'Cache'}->get('Issues');
        }
        else {
            $issues = $self->load_issues;
        }
        my $issue;
        my $i = 0;
        while ( defined( $issue = $issues->{'issues'}[$i] ) ) {
            if ( $issue->{'id'} eq $id ) {
                return $issue;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The issue wasn't found reload issues with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
    else {
        $issues = $self->load_issues;
        my $issue;
        my $i = 0;
        while ( defined( $issue = $issues->{'issues'}[$i] ) ) {
            if ( $issue->{'id'} eq $id ) {
                return $issue;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The issue wasn't found reload issues with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_issue_by_subject {
    my ( $self, $subject ) = @_;
    if ( defined $self->issue_subject_to_id($subject)  ) {
        return (
            $self->get_issue_by_id( $self->issue_subject_to_id($subject) ) );
    }
    else {
        $self->{'LastError'} =
          q{The issue wasn't found reload issues with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_issues {
    my ($self) = @_;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Issues') ) {
            return $self->{'Cache'}->get('Issues');
        }
        else {
            return $self->load_issues;
        }
    }
    else {
        return $self->load_issues;
    }
}

sub get_project_issues {
    my ( $self, $name ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new(
        GET => $self->{Url} . '/projects/' . $name . '/issues.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        my $ref_hash = decode_json $response->content;
        return $ref_hash;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub post_issue {
    my ( $self, $hash_post_issue ) = @_;
    my $ref_hash = $self->hash_verification_issue( $hash_post_issue, 'post' );
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/issues.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        my $issue = decode_json $response->decoded_content;
        my $id    = $issue->{'issue'}->{'id'};
        if ( defined $self->{'Cache'}  ) {
            $self->load_issues;
        }
        return $id;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub put_issue_by_id {
    my ( $self, $id, $hash_put_issue ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification_issue( $hash_put_issue, 'put' );
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/issues/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->load_issues;
        }
        return 1;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub delete_issue_by_id {
    my ( $self, $id ) = @_;
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( DELETE => $self->{Url} . '/issues/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'}  ) {
            $self->load_issues;
        }
        return 1;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub issue_subject_to_id {
    my ( $self, $subject ) = @_;
    my $issues;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Issues') ) {
            $issues = $self->{'Cache'}->get('Issues');
        }
        else {
            $issues = $self->load_issues;
        }
        my $issue;
        my $i = 0;
        while ( defined( $issue = $issues->{'issues'}[$i] ) ) {
            if ( $issue->{'subject'} eq $subject ) {
                return $issue->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
    else {
        $issues = $self->load_issues;
        my $issue;
        my $i = 0;
        while ( defined( $issue = $issues->{'issues'}[$i] ) ) {
            if ( $issue->{'subject'} eq $subject ) {
                return $issue->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
}

sub project_name_to_id {
    my ( $self, $name ) = @_;
    my $projects;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Projects') ) {
            $projects = $self->{'Cache'}->get('Projects');
        }
        else {
            $projects = $self->load_projects;
        }
        my $project;
        my $i = 0;
        while ( defined( $project = $projects->{'projects'}[$i] ) ) {
            if ( $project->{'name'} eq $name ) {
                return $project->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
    else {
        $projects = $self->load_projects;
        my $project;
        my $i = 0;
        while ( defined( $project = $projects->{'projects'}[$i] ) ) {
            if ( $project->{'name'} eq $name ) {
                return $project->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
}

sub user_login_to_id {
    my ( $self, $login ) = @_;
    my $users;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Users') ) {
            $users = $self->{'Cache'}->get('Users');
        }
        else {
            $users = $self->load_users;
        }
        my $user;
        my $i = 0;
        while ( defined( $user = $users->{'users'}[$i] ) ) {
            if ( $user->{'login'} eq $login ) {
                return $user->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
    else {
        $users = $self->load_users;
        my $user;
        my $i = 0;
        while ( defined( $user = $users->{'users'}[$i] ) ) {
            if ( $user->{'login'} eq $login ) {
                return $user->{'id'};
            }
            else {
                $i++;
            }
        }
        return;
    }
}

sub status_name_to_id {
    my ( $self, $name ) = @_;
    my $statuses;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Statuses') ) {
            $statuses = $self->{'Cache'}->get('Statuses');
        }
        else {
            $statuses = $self->load_statuses;
        }
        my $status;
        my $i = 0;
        while ( defined( $status = $statuses->{'issue_statuses'}[$i] ) ) {
            if ( $status->{'name'} eq $name ) {
                return $status->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    else {
        $statuses = $self->load_statuses;
        my $status;
        my $i = 0;
        while ( defined( $status = $statuses->{'issue_statuses'}[$i] ) ) {
            if ( $status->{'name'} eq $name ) {
                return $status->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    return;
}

sub tracker_name_to_id {
    my ( $self, $name ) = @_;
    my $trackers;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Trackers') ) {
            $trackers = $self->{'Cache'}->get('Trackers');
        }
        else {
            $trackers = $self->load_trackers;
        }
        my $tracker;
        my $i = 0;
        while ( defined( $tracker = $trackers->{'trackers'}[$i] ) ) {
            if ( $tracker->{'name'} eq $name ) {
                return $tracker->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    else {
        $trackers = $self->load_trackers;
        my $tracker;
        my $i = 0;
        while ( defined( $tracker = $trackers->{'trackers'}[$i] ) ) {
            if ( $tracker->{'name'} eq $name ) {
                return $tracker->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    return;
}

sub priority_name_to_id {
    my ( $self, $name ) = @_;
    my $priorities;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Priorities') ) {
            $priorities = $self->{'Cache'}->get('Priorities');
        }
        else {
            $priorities = $self->load_priorities;
        }
        my $priority;
        my $i = 0;
        while ( defined( $priority = $priorities->{'enumerations'}[$i] ) ) {
            if ( $priority->{'type'} eq q{IssuePriority} ) {
                if ( $priority->{'name'} eq $name ) {
                    return $priority->{'id'};
                }
                else {
                    $i++;
                }
            }
            else {
                $i++;
            }
        }
    }
    else {
        $priorities = $self->load_priorities;
        my $priority;
        my $i = 0;
        while ( defined( $priority = $priorities->{'enumerations'}[$i] ) ) {
            if ( $priority->{'type'} eq q{IssuePriority} ) {
                if ( $priority->{'name'} eq $name ) {
                    return $priority->{'id'};
                }
                else {
                    $i++;
                }
            }
            else {
                $i++;
            }
        }
    }
    return;
}

sub category_name_to_id {
    my ( $self, $name ) = @_;
    my $categories;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Categories') ) {
            $categories = $self->{'Cache'}->get('Categories');
        }
        else {
            $categories = $self->load_categories;
        }

        my $category;
        my $i = 0;
        while ( defined( $category = $categories->{'issue_categories'}[$i] ) ) {
            if ( $category->{'name'} eq $name ) {
                return $category->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    else {
        $categories = $self->load_categories;
        my $category;
        my $i = 0;
        while ( defined( $category = $categories->{'issue_categories'}[$i] ) ) {
            if ( $category->{'name'} eq $name ) {
                return $category->{'id'};
            }
            else {
                $i++;
            }
        }
    }
    return;
}

sub hash_verification_issue {
    my ( $self, $hash, $action ) = @_;
    my $issue = $hash->{'issue'};
    if ( $action eq 'post' ) {
        if (
            (
                    ( defined $issue->{'status'} )
                and ( defined $issue->{'tracker'} )
                and ( defined $issue->{'priority'} )
                and ( defined $issue->{'subject'} )
            )
            or (    ( defined $issue->{'status_id'} )
                and ( defined $issue->{'tracker_id'} )
                and ( defined $issue->{'priority_id'} )
                and ( defined $issue->{'subject_id'} ) )
          )
        {
            my $result->{'issue'} = $self->reformating_hash($issue);
            return $result;
        }
        else {
            $self->{'LastError'} =
q{the elements : status , tracker , priority and subject was required};
            croak
'Error : the elements : status , tracker , priority and subject was required';
        }
    }
    else {
        my $result->{'issue'} = $self->reformating_hash($issue);
        return $result;
    }
}

sub hash_verification_user {
    my ( $self, $hash, $action ) = @_;
    if ( $action eq 'post' ) {
        if (defined $hash->{'user'}{'login'}
            and defined $hash->{'user'}{'mail'} )
        {
            return $hash;
        }
        else {
            $self->{'LastError'} =
              q{the elements : login and mail was required};
            croak 'Error : the elements : login and mail was required';
        }
    }
    else {
        return $hash;
    }
}

sub hash_verification_project {
    my ( $self, $hash, $action ) = @_;
    if ( $action eq 'post' ) {
        if (    defined $hash->{'project'}{'name'}
            and defined $hash->{'project'}{'identifier'} )
        {
            return $hash;
        }
        else {
            $self->{'LastError'} =
              q{the elements : name and identifier was required};
            croak 'Error : the elements : name and identifier was required';
        }
    }
    else {
        return $hash;
    }
}

sub reformating_hash {
    my ( $self, $issue ) = @_;
    my $res = {};
    while ( my ( $c, $v ) = each %{$issue} ) {
        switch ($c) {
            case 'status' {
                if ( defined $self->status_name_to_id($v) ) {
                    $res->{'status_id'} = $self->status_name_to_id($v);
                }
                else {
                    $self->{'LastError'} = q{ Status } . $v . q{ wasn't found};
                    croak 'Error: ' . q{ Status } . $v . q{ wasn't found};
                }
            }
            case 'tracker' {
                if ( defined $self->tracker_name_to_id($v) ) {
                    $res->{'tracker_id'} = $self->tracker_name_to_id($v);
                }
                else {
                    $self->{'LastError'} = q{ Tracker } . $v . q{ wasn't found};
                    croak 'Error :' . q{ Tracker } . $v . q{ wasn't found};
                }
            }
            case 'priority' {
                if ( defined $self->priority_name_to_id($v) ) {
                    $res->{'priority_id'} = $self->priority_name_to_id($v);
                }
                else {
                    $self->{'LastError'} =
                      q{ Priority } . $v . q{ wasn't found};
                    croak 'Error :' . q{ Priority } . $v . q{ wasn't found};
                }
            }
            case 'category' {
                if ( defined $self->category_name_to_id($v) ) {
                    $res->{'category_id'} = $self->category_name_to_id($v);
                }
                else {
                    $self->{'LastError'} =
                      q{ Category } . $v . q{ wasn't found};
                    croak 'Error :' . q{ Category } . $v . q{ wasn't found};
                }
            }
            case 'author' {
                if ( defined $self->user_login_to_id($v) ) {
                    $res->{'author_id'} = $self->user_login_to_id($v);
                }
                else {
                    $self->{'LastError'} = q{ User } . $v . q{ wasn't found};
                    croak 'Error :' . q{ User } . $v . q{ wasn't found};
                }
            }
            case 'assigned_to' {
                if ( defined $self->user_login_to_id($v) ) {
                    $res->{'assigned_to_id'} = $self->user_login_to_id($v);
                }
                else {
                    $self->{'LastError'} = q{ User } . $v . q{ wasn't found};
                    croak 'Error :' . q{ User } . $v . q{ wasn't found};
                }
            }
            case 'project' {
                if ( defined $self->project_name_to_id($v) ) {
                    $res->{'project_id'} = $self->project_name_to_id($v);
                }
                else {
                    $self->{'LastError'} = q{ Project } . $v . q{wasn't found};
                    croak 'Error :' . q{ Project } . $v . q{ wasn't found};
                }
            }
            else {
                $res->{$c} = $v;
            }
        }
    }
    return $res;
}

sub get_user_by_id {
    my ( $self, $id ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    my $users;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Users') ) {
            $users = $self->{'Cache'}->get('Users');
        }
        else {
            $users = $self->load_users;
        }
        my $user;
        my $i = 0;
        while ( defined( $user = $users->{'users'}[$i] ) ) {
            if ( $user->{'id'} eq $id ) {
                return $user;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The user wasn't found reload users with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
    else {
        $users = $self->load_users;
        my $user;
        my $i = 0;
        while ( defined ( $user = $users->{'users'}[$i] ) ) {
            if ( $user->{'id'} eq $id ) {
                return $user;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The user wasn't found reload users with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_user_by_login {
    my ( $self, $login ) = @_;
    if ( defined $self->user_login_to_id($login) ) {
        return ( $self->get_user_by_id( $self->user_login_to_id($login) ) );
    }
    else {
        $self->{'LastError'} =
          q{The user wasn't found reload users with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_users {
    my ($self) = @_;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Users') ) {
            return $self->{'Cache'}->get('Users');
        }
        else {
            return $self->load_users;
        }
    }
    else {
        return $self->load_users;
    }
}

sub post_user {
    my ( $self, $hash_post_user ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification_user( $hash_post_user, 'post' );
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/users.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        my $user = decode_json $response->decoded_content;
        my $id   = $user->{'user'}->{'id'};
        if ( defined $self->{'Cache'} ) {
            $self->load_users;
        }
        return $id;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : Use print(get_last_error);';
    }
}

sub put_user_by_id {
    my ( $self, $id, $hash_put_user ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification_user( $hash_put_user, 'put' );
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/users/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->load_users;
        }
        return 1;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub put_user_by_login {
    my ( $self, $login, $hash_put_user2 ) = @_;
    if ( defined $self->user_login_to_id($login) ) {
        return (
            $self->put_user_by_id(
                $self->user_login_to_id($login),
                $hash_put_user2
            )
        );
    }
    else {
        $self->{'LastError'} =
          q{The user wasn't found reload users with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_project_by_id {
    my ( $self, $id ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
    my $projects;
    if ( defined $self->{'Cache'} ) {
        if ( defined $self->{'Cache'}->get('Projects') ) {
            $projects = $self->{'Cache'}->get('Projects');
        }
        else {
            $projects = $self->load_projects;
        }
        my $project;
        my $i = 0;
        while ( defined( $project = $projects->{'projects'}[$i] ) ) {
            if ( $project->{'id'} eq $id ) {
                return $project;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The project wasn't found reload Projects with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
    else {
        $projects = $self->load_projects;
        my $project;
        my $i = 0;
        while ( defined( $project = $projects->{'projects'}[$i] ) ) {
            if ( $project->{'id'} eq $id ) {
                return $project;
            }
            else {
                $i++;
            }
        }
        $self->{'LastError'} =
          q{The project wasn't found reload Projects with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub get_project_by_name {
    my ( $self, $name ) = @_;
    if ( defined $self->project_name_to_id($name) ) {
        return ( $self->get_project_by_id( $self->project_name_to_id($name) ) );
    }
    else {
        $self->{'LastError'} =
          q{The project wasn't found reload Projects with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub post_project {
    my ( $self, $hash_post_project ) = @_;
    my $ua = LWP::UserAgent->new;
    my $ref_hash =
      $self->hash_verification_project( $hash_post_project, 'post' );
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $json = encode_json $ref_hash ;
    my $request = HTTP::Request->new( POST => $self->{Url} . '/projects.json' );
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        my $project = decode_json $response->decoded_content;
        my $id      = $project->{'project'}->{'id'};
        if ( defined $self->{'Cache'} ) {
            $self->load_projects;
        }
        return $id;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub put_project_by_id {
    my ( $self, $id, $hash_put_project ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : Use print(get_last_error);';
    }
    my $ua = LWP::UserAgent->new;
    my $ref_hash = $self->hash_verification_project( $hash_put_project, 'put' );
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new( PUT => $self->{Url} . '/projects/' . $id . '.json' );
    my $json = encode_json $ref_hash ;
    $request->header( 'Content-Type' => 'application/json' );
    $request->content($json);
    my $response = $ua->request($request);

    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->load_projects;
        }
        return 1;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub put_project_by_name {
    my ( $self, $name, $hash_put_project2 ) = @_;
    if ( defined $self->project_name_to_id($name) ) {
        return (
            $self->put_project_by_id(
                $self->project_name_to_id($name),
                $hash_put_project2
            )
        );
    }
    else {
        $self->{'LastError'} =
          q{The project wasn't found reload Projects with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

sub delete_project_by_id {
    my ( $self, $id ) = @_;
    if ( !( ($id) =~ /^\d+$/sxm ) ) {
        $self->{'LastError'} =
          'the id : "' . $id . '" is not an integer ' . "\n";
        croak 'Error : Use print(get_last_error);';
    }
    my $ua = LWP::UserAgent->new;
    $ua->credentials( $self->{Server} . q{:} . $self->{Port},
        'Redmine API', $self->{UserName} => $self->{PassWord} );
    my $request =
      HTTP::Request->new(
        DELETE => $self->{Url} . '/projects/' . $id . '.json' );
    my $response = $ua->request($request);
    if ( $response->is_success ) {
        if ( defined $self->{'Cache'} ) {
            $self->load_projects;
        }
        return 1;
    }
    else {
        $self->{'LastError'} =
            $response->status_line . "\n"
          . 'Check your config please : '
          . $response->content . "\n";
        croak 'Error : ' . $self->get_last_error;
    }
}

sub delete_project_by_name {
    my ( $self, $name ) = @_;
    if ( defined $self->project_name_to_id($name) ) {
        return (
            $self->delete_project_by_id( $self->project_name_to_id($name) ) );
    }
    else {
        $self->{'LastError'} =
          q{The project wasn't found reload Projects with the max limit ? };
        croak 'Error : ' . $self->get_last_error;
    }
}

1;
__END__

=head1 VERSION

This documentation describe Net::Redmine::API::REST Rev : $Revision$,Url : $HeadURL$,Date : $Date$,Source :  $Source$

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
        Server => 'Redmine API',
        Port => '80',
        UserName => 'user',
        PassWord => 'pass'
    );

  -use GET,POST,PUT,DELETE object's methods
   exemple : 
    $object->get_issue_by_id('1');

=head1 Notefication

To modify or posting with custom values use this syntax :
    $hashref = {
                    issues => {
                                    key => value,
                                    custom_field_values => {
                                                                id => value,
                                    },
                    },
    };

To use test.t with your redmine set $Redmine_Url,_Server,_Port,_UserName,_PassWord environement variable

=head1 AUTHOR

Schoorens Stephane
 e-mail : sschoorens@lncsa.com

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 LNCSA (contact@lncsa.com)

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself

=head1 MODIFICATIONS

Last modification : nothing.

=head1 DEPENDENCIES

HTTP::Request, LWP::UserAgent, JSON, Moose, Switch, Carp

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

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=cut

=head1 SUBROUTINES/METHODS

=cut

=head2 get_last_error

=head3 Description : 

return the last error was occured.

=head3 Parametre :

Nothing

=head3 Return :

$error          a string who was the last error

=head3 Use Exemple :    

    print $object->get_last_error;

=cut

=head2 load_statuses

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Statuses" or return the ref if cache isn't used.

=head3 Parametre :

Nothing

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple :    

*Without cache

    $hash_ref = $object->load_statuses; (without cache)

*With cache

    $object->load_statuses;
    $object->{'Cache'}->get ('Statuses'};

=cut

=head2 load_trackers

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Trackers" or return the ref if cache isn't used.

=head3 Parametre :

Nothing

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple :    

*Without cache

   $hash_ref = $object->load_trackers;

*With cache

    $object->load_trackers;
    $object->{'Cache'}->get ('Trackers'};

=cut

=head2 load_categories

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Categories" or return the ref if cache isn't used.

=head3 Parametre :

Nothing

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple : 

*Without cache

    $hash_ref = $object->load_categories;

*With cache

    $object->load_categories;
    $object->{'Cache'}->get ('Categories'};

=cut

=head2 load_priorities

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Priorities" or return the ref if cache isn't used.

=head3 Parametre :

Nothing

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple : 

*Without cache

    $hash_ref = $object->load_priorities;

*With cache

    $object->load_priorities;
    $object->{'Cache'}->get ('Priorities'};

=cut

=head2 load_projects

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Projects" or return the ref if cache isn't used.

=head3 Parametre :

[$limit ans $offset]    by default limit = 25 and offset = 0

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple :

*Without cache

    $hash_ref = $object->load_projects;
OR
    $hash_ref = $object->load_projects(100,0); #the 100 last projects 

*With cache

    $object->load_projects;
    $object->{'Cache'}->get ('Projects');
OR
    $object->load_projects(100,0);
    $object->{'Cache'}->get ('Projects');

=cut

=head2 load_users

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Users" or return the ref if cache isn't used.

=head3 Parametre :

[$limit ans $offset]    by default limit = 25 and offset = 0

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple :    

*Without cache

    $hash_ref = $object->load_users;
OR
    $hash_ref = $object->load_users(100,0); #the 100 last users 

*With cache

    $object->load_users;
    $object->{'Cache'}->get ('Users');
OR
    $object->load_users(100,0);
    $object->{'Cache'}->get ('Users');


=cut

=head2 load_issues

=head3 Description : 

Set a reference on a hash into the object's Cache with the key "Issues" or return the ref if cache isn't used.

=head3 Parametre :

[$limit ans $offset]    by default limit = 25 and offset = 0

=head3 Return :

Return the hash_ref if cache isn't used.

=head3 Use Exemple :    

*Without cache

    $hash_ref = $object->load_issues;
OR
    $hash_ref = $object->load_issuess(100,0); #the 100 last issues 

*With cache

    $object->load_issues;
    $object->{'Cache'}->get ('Issues');
OR
    $object->load_issues(100,0);
#     $object->{'Cache'}->get ('Issues');

=cut

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

=head2 get_project_issues

=head3 Description : 

return a reference on a hash who contains project's issues

=head3 Parametre :

$name           The project's name

=head3 Return :

$ref_hash       return a reference on a hash

1               if the function failed

=head3 Use Exemple :    

    my $ref_hash=$object->get_project_issues('test');

=cut

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
                 custom_field_values => {
                                            '12' => 'put',
                 },
            }
    };
    if ($object->post_issue($hash) > 0 ){
        say 'Great Job !';
    }

=cut

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

=head2 hash_verification_issue

=head3 Description : 

Verify a hash and give a result conform with the protocol

=head3 Parametre :ost

$hash          hash reference will be used to post or put everything on redmine

$action        Post or Put protocol to verify the required elements in Post

=head3 Return :

$result             return a good hash reference

0                   if the function failed

=head3 Use Exemple :    

    if( ref( $object->hash_verification_issue($refhash,'post') ) eq 'HASH' ){
        say 'you can post the function return';
    }

=cut

=head2 hash_verification_user

=head3 Description : 

Verify a hash and give a result conform with the protocol

=head3 Parametre :ost

$hash          hash reference will be used to post or put everything on redmine

$action        Post or Put protocol to verify the required elements in Post

=head3 Return :

$result             return a good hash reference

0                   if the function failed

=head3 Use Exemple :    

    if( ref( $object->hash_verification_user($refhash,'post') ) eq 'HASH' ){
        say 'you can post the function return';
    }

=cut

=head2 hash_verification_project

=head3 Description : 

Verify a hash and give a result conform with the protocol

=head3 Parametre :ost

$hash          hash reference will be used to post or put everything on redmine

$action        Post or Put protocol to verify the required elements in Post

=head3 Return :

$result             return a good hash reference

0                   if the function failed

=head3 Use Exemple :    

    if( ref( $object->hash_verification_project($refhash,'post') ) eq 'HASH' ){
        say 'you can post the function return';
    }

=cut

=head2 reformating_hash

=head3 Description : 

reformate a hash with conform attribute

=head3 Parametre :ost

$issue         hash reference will be used to post or put issue on redmine

=head3 Return :

$res            return a good hash reference

=head3 Use Exemple :    

    if( ref( $object->reformating_hash($refhash,'post') ) eq 'HASH' ){
        say 'you can post the function return';
    }

=cut

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

=head2 put_user_by_login

=head3 Description : 

Send a PUT request with the hash value to the user. You can lock a user by passing { 'status' => '3' } unlock  { 'status' => '1' }

=head3 Parametre :

$login          User's login

$hash           A reference on a hash construct like this : 
    my $hash={
        'user' =>
        {
            'Redmine key' => 'Value',
        }
    };

=head3 Return :

1               when the PUT request it's done

=head3 Use Exemple : 

    my $hash={
        'user' =>
        { 
            'mail' => 'toto@fake.com'
        }
    };
    if ($object->put_user_by_login('toto',$hash) == 1){
        say 'Great Job !';
    }
=cut

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

=head2 put_project_by_name

=head3 Description : 

Send a PUT request with the hash value to the project.

=head3 Parametre :

$name           Project's Name

$hash           A reference on a hash construct like this : 
    my $hash={
        'project' =>
        {
            'Redmine key' => 'Value',
        }
    };

=head3 Return :

1               when the PUT request it's done

=head3 Use Exemple : 

    my $hash={
        'project' =>
        { 
            'name' => 'put_test'
        }
    };
    if ($object->put_project_by_name('test',$hash) == 1){
        say 'Great Job !';
    }
=cut

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

=head2 delete_project_by_name

=head3 Description : 

Delete an project by name.

=head3 Parametre :

$name             Project's Name

=head3 Return :

1               return 1 when the delete request is done

=head3 Use Exemple :    

    if( $object->delete_project_by_name('test') == 1 ){
        say 'you have deleted the project test';
    }

=cut