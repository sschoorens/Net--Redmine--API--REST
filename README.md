# VERSION #

This documentation describe Net::Redmine::API::REST version 1.0
_ _ _
# NAME #

**Net::Redmine::API::REST** - REST API for Redmine's GET,POST,PUT,DELETE manipulation
_ _ _
# SYNOPSIS # 
    `
    use Net::Redmine::API::REST;

    my $object = Net::Redmine::API::REST->new (
        Url => 'http://redmine.test.com',
        Server => 'redmine.test.com',
        Port => '80',
        UserName => 'user',
        PassWord => 'pass'
    );  # object for methods using 

    my $ref_hash = $object->get-issue_by_id('1'); # Call of the method get_issue_by_id
    `
_ _ _
# DESCRIPTION #

This is a module for Redmine's **GET,POST,PUT,DELETE** manipulation in order :

  -create **an object** Net::Redmine::API::REST with this params :

       >Url    [required]   # probably http://Redmine.[yourCompany].com

       >Server [required]   # probably Redmine.[yourCompany].com

       >Port   [default=80] # 443 for https use

       >UserName

       >PassWord
  
   exemple :

    `
    my $object = Net::Redmine::API::REST->new ( 
        Url => 'http://redmine.test.com',
        Server => 'redmine.test.com',
        Port => '80',
        UserName => 'user',
        PassWord => 'pass'
    );
    `
  -use **GET,POST,PUT,DELETE object's methods**

   exemple : 

    `$object->get_issue_by_id('1');`

Methods return generaly undef when they have a problem .
_ _ _
# AUTHOR #

Schoorens Stephane
 e-mail : sschoorens@lncsa.com
_ _ _
# LICENCE AND COPYRIGHT #

Copyright (c) 2011 LNCSA (contact@lncsa.com)

This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself