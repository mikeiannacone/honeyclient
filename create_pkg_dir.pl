#!/usr/bin/perl
use warnings;
use strict;

use File::Copy;
use File::Copy::Recursive qw(dircopy pathrm pathmk);
use File::Find;
use Test::Inline::Extract;

#--------------------------------------#
# Go through each module or the ones specified
if(!@ARGV){@ARGV = qw(HoneyClient::Util HoneyClient::Agent HoneyClient::Manager)}

#   The path where the packages are
my $src_path  = "lib";

#   Directories to include in the distribution 
my %inc_dirs = (etc => $src_path . '/etc',
                bin => $src_path . '/bin',
                inc => 'thirdparty/inc',);
#--------------------------------------#


# Clean up some stuff
$src_path =~ s/\/+$//;
my $pkg_name;
foreach(@ARGV){
    # The name of the package, most of the paths are derived from this
    $pkg_name = $_;
    $pkg_name =~ s/::/-/g;

    l("Packaging $_...");
    # Magic fun with arrays
    #   Get the last one, thats the module name, then join the rest back together
    my ($module,@path) = reverse(split(/-/,$pkg_name));
    my $path = join('/',reverse(@path));

    # Clean up the old stuff
    l("Cleaning house",1);
    if(-e $pkg_name){ my_pathrm($pkg_name,2) } 

    # Get the stuff for the stub folder from wherever we want
    if(-e 'stub'){ my_pathrm('stub',2) }

    # Copy included directories
    while(my($name,$path) = each %inc_dirs){
        my_dircopy($path,$pkg_name,$name,1);
        # Suppress errors generated by removing .svn directories.
        eval {
            no warnings;
            find({wanted => \&remove_svn, no_chdir => 0}, "$pkg_name/$name");
        };
    }

    # Create the target directory
    my_pathmk("$pkg_name/lib/$path/$module",1);

    # Copy pm files to the lib
    if(-f "$src_path/$path/$module.pm"){
        my($src,$dest) = ("$src_path/$path/$module.pm","$pkg_name/lib/$path");
        my_copy($src,$dest,2);
    }
    find({wanted => \&process, no_chdir => 1} ,"$src_path/$path/$module");

    l('');
}

sub remove_svn {
    if(/\.svn$/) {
        my_pathrm($_, 2);
    }
}

# Process the files after we find them
sub process { #{{{
    # Make sure we only get .pm files
    if(/\.pm$/){
        my $src = $File::Find::name;
        l("Found $src",3);
        # Because messing with arrays is more fun than strings
        my @dest = split(/\//,$src);
        shift(@dest); 
        my $name = pop(@dest);
        $name =~ s/\.pm$//;
        unshift(@dest,$pkg_name,'lib');
        my $dest = join('/',@dest);
        if(!-e $dest){ my_pathmk($dest,4) }
        my_copy($src,$dest,3);

#------------------------
# TODO: Get it to create tests, works intermitantly
#------------------------
#        # Get the inline test stuff from the file
#        my $inline = Test::Inline::Extract->new($src)->elements;
#        if( $inline ne "" ){
#            l("Making test file",2);
#            my_pathmk("$pkg_name/t",3);
#            open(TEST,">$pkg_name/t/$pkg_name-$name.t");
#            foreach(@{$inline}){ print TEST; }
#            close TEST;
#        }
    }
}#}}}

# All of the calls are the same, and I wanted to unclutter the above code
sub my_copy { #{{{
    my($src,$dest,$log) = @_;
    l("Copying $src to $dest",$log);
    copy($src,$dest) or die "Cannot copy $src to $dest: $!";
}#}}}
sub my_dircopy { #{{{
    my($src,$dest,$name,$log) = @_;
    l("Copying $src to $dest as $name",$log);
    dircopy($src,"$dest/$name") or die "Couldn't copy $src to $dest: $!";
}#}}}
sub my_pathrm { #{{{
    my($pkg_name,$log) = @_;
    l("Removing $pkg_name directory",$log);
    pathrm($pkg_name,1) or die "Can't rmdir $pkg_name: $!";
}#}}}
sub my_pathmk { #{{{
    my($path,$log) = @_;
    l("$path does not exist, creating...",$log);
    pathmk($path) or die "Cannot mkdir $path: $!";
}#}}}

# Log with pretty tabbing 
sub l { #{{{
    my $string = shift;
    my $level = shift || 0;
    while($level-- > 0){
        print "\t";
        if(!$level){ print "- " }
    }
    print "$string\n";
}#}}}
