#!/usr/bin/perl -w

# autolatex - autolatex.pl
# Copyright (C) 1998-07  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

require 5.004;

use strict ;

use File::Basename ;
use File::Spec ;

#------------------------------------------------------
#
# Initialization code
#
#------------------------------------------------------
{
	my $PERLSCRIPTDIR ;
	my $PERLSCRIPTNAME ;
	my $LAUNCHINGNAME ;
	BEGIN{
	  # Where is this script?
	  $PERLSCRIPTDIR = "$0";
	  $LAUNCHINGNAME = basename("$0");
	  my $scriptdir = dirname( $PERLSCRIPTDIR );
	  while ( -e $PERLSCRIPTDIR && -l $PERLSCRIPTDIR ) {
	    $PERLSCRIPTDIR = readlink($PERLSCRIPTDIR);
	    if ( substr( $PERLSCRIPTDIR, 0, 1 ) eq '.' ) {
	      $PERLSCRIPTDIR = File::Spec->catfile( $scriptdir, "$PERLSCRIPTDIR" ) ;
	    }
	    $scriptdir = dirname( $PERLSCRIPTDIR );
	  }
	  $PERLSCRIPTNAME = basename( $PERLSCRIPTDIR ) ;
	  $PERLSCRIPTDIR = dirname( $PERLSCRIPTDIR ) ;
	  $PERLSCRIPTDIR = File::Spec->rel2abs( "$PERLSCRIPTDIR" );
	  # Push the path where the script is to retreive the arakhne.org packages
	  push(@INC,"$PERLSCRIPTDIR");
	  push(@INC,File::Spec->catfile("$PERLSCRIPTDIR","pm"));


	}
	use AutoLaTeX::Util;
	AutoLaTeX::Util::setAutoLaTeXInfo("$LAUNCHINGNAME","$PERLSCRIPTNAME","$PERLSCRIPTDIR");
}

use Locale::gettext;
use POSIX; # Needed for setlocale()

use AutoLaTeX::Main;
use AutoLaTeX::Config;
use AutoLaTeX::GUI::Gtk::Window;

# Set the default locale
setlocale(LC_MESSAGES, "");

#------------------------------------------------------
#
# MAIN PROGRAM: Treat main program actions
#
#------------------------------------------------------

my %currentConfiguration = mainProgram(0);

my %systemConfiguration = readOnlySystemConfiguration();
my %userConfiguration = readOnlyUserConfiguration();
my $projectConfiguration = undef;

if ($currentConfiguration{'__private__'}{'input.project directory'}) {
	my @path = File::Spec->splitdir($currentConfiguration{'__private__'}{'input.project directory'});
	$projectConfiguration = readOnlyProjectConfiguration(@path);
}

my $gui = AutoLaTeX::GUI::Gtk::Window->new (
			\%currentConfiguration,
			\%systemConfiguration,
			\%userConfiguration,
			$projectConfiguration);

$gui->setAdminUser($< == 0);
$gui->setCommandLine(getAutoLaTeXLaunchingName(),@ARGV);

$gui->showDialog();

exit(0);

__END__
