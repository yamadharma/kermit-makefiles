# autolatex - Config.pm
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

=pod

=head1 NAME

Config.pm - Configuration Files

=head1 DESCRIPTION

Provides a set of utilities for manipulating cofiguration files.

To use this library, type C<use AutoLaTeX::Config;>.

=head1 FUNCTIONS

The provided functions are:

=over 4

=cut
package AutoLaTeX::Config;

$VERSION = '5.1';
@ISA = ('Exporter');
@EXPORT = qw( &getProjectConfigFilename &getUserConfigFilename &getSystemConfigFilename
              &getSystemISTFilename &readConfiguration &readConfigFile &getUserConfigDirectory
	      &cfgBoolean &doConfigurationFileFixing &cfgToBoolean &writeConfigFile
	      &readOnlySystemConfiguration &readOnlyUserConfiguration &readOnlyProjectConfiguration
	      &setInclusionFlags &reinitInclusionFlags &cfgIsBoolean ) ;
@EXPORT_OK = qw();

use strict;
use warnings;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

use File::Spec;
use Config::Simple;

use AutoLaTeX::OS;
use AutoLaTeX::Util;
use AutoLaTeX::Locale;

#no warnings 'redefine';
#sub Config::Simple::READ_DELIM() {
#	return '\s*'.getPathListSeparator().'\s*';
#}
#sub Config::Simple::READ_DELIM() {
#	return getPathListSeparator();
#}

=pod

=item B<getProjectConfigFilename(@)>

Replies the name of a project's configuration file
which is located inside the given directory.

I<Parameters:>

=over 8

=item * the components of the paths, each parameter is a directory in the path.

=back

I<Returns:> the configuration filename according to the current operating system rules.

=cut
sub getProjectConfigFilename(@) {
	my $operatingsystem = getOperatingSystem();
	if (("$operatingsystem" eq 'Unix')||(("$operatingsystem" eq 'Cygwin'))) {
		return File::Spec->rel2abs(File::Spec->catfile(@_,".autolatex_project.cfg"));
	}
	else {
		return File::Spec->rel2abs(File::Spec->catfile(@_,"autolatex_project.cfg"));
	}
}

=pod

=item B<getUserConfigFilename()>

Replies the name of a user's configuration file.

I<Returns:> the configuration filename according to the current operating system rules.

=cut
sub getUserConfigFilename() {
	my $confdir = getUserConfigDirectory();
	if (-d "$confdir") {
		return File::Spec->catfile("$confdir","autolatex.conf");
	}
	my $operatingsystem = getOperatingSystem();
	if (("$operatingsystem" eq 'Unix')||(("$operatingsystem" eq 'Cygwin'))) {
		return File::Spec->rel2abs(File::Spec->catfile($ENV{'HOME'},".autolatex"));
	}
	elsif ("$operatingsystem" eq 'Win32') {
		return File::Spec->rel2abs(File::Spec->catfile("C:","Documents and Settings",$ENV{'USER'},"Local Settings","Application Data","autolatex.conf"));
	}
	else {
		return File::Spec->rel2abs(File::Spec->catfile($ENV{'HOME'},"autolatex.conf"));
	}
}

=pod

=item B<getUserConfigDirectory()>

Replies the name of a user's configuration directory.

I<Returns:> the configuration directory according to the current operating system rules.

=cut
sub getUserConfigDirectory() {
	my $operatingsystem = getOperatingSystem();
	if (("$operatingsystem" eq 'Unix')||(("$operatingsystem" eq 'Cygwin'))) {
		return File::Spec->rel2abs(File::Spec->catfile($ENV{'HOME'},".autolatex"));
	}
	elsif ("$operatingsystem" eq 'Win32') {
		return File::Spec->rel2abs(File::Spec->catfile("C:","Documents and Settings",$ENV{'USER'},"Local Settings","Application Data","autolatex"));
	}
	else {
		return File::Spec->rel2abs(File::Spec->catfile($ENV{'HOME'},"autolatex"));
	}
}

=pod

=item B<getSystemConfigFilename()>

Replies the name of the configuration file for all users.

I<Returns:> the configuration filename according to the current operating system rules.

=cut
sub getSystemConfigFilename() {
	return File::Spec->catfile(getAutoLaTeXDir(),"default.cfg");
}

=pod

=item B<getSystemISTFilename()>

Replies the name of the MakeIndex style file for all users.

I<Returns:> the filename according to the current operating system rules.

=cut
sub getSystemISTFilename() {
	return File::Spec->catfile(getAutoLaTeXDir(),"default.ist");
}

=pod

=item B<cfgBoolean($;$)>

Replies the Perl boolean value that corresponds to the specified
string. If the first parameter is not a valid boolean string, the second
parameter will be replied if it is specified; if not undef will be replied;

The valid string are (case insensitive): S<true>, S<false>, S<yes>, S<no>.

I<Parameters:>

=over 8

=item * the value to test.

=item * the data structure to fill

=back

I<Returns:> nothing

=cut
sub cfgBoolean($;$) {
	if ($_[0]) {
		my $v = lc($_[0]);
		return 1 if (($v eq 'yes')||($v eq 'true'));
		return 0 if (($v eq 'no')||($v eq 'false'));
	}
	return $_[1];
}

=pod

=item B<cfgToBoolean($)>

Replies the configuration's file boolean value that corresponds to the specified
Perl boolean value.

I<Parameters:>

=over 8

=item * the value to test.

=back

I<Returns:> nothing

=cut
sub cfgToBoolean($) {
	return ($_[0]) ? 'true' : 'false';
}

=pod

=item B<cfgIsBoolean($)>

Replies if the specified string is a valid boolean string.

I<Parameters:>

=over 8

=item * the value to test.

=back

I<Returns:> nothing

=cut
sub cfgIsBoolean($) {
	if (defined($_[0])) {
		my $v = lc($_[0]);
		return 1
			if (($v eq 'yes')||($v eq 'no')||($v eq 'true')||($v eq 'false'));
	}
	return 0;
}

=pod

=item B<readConfiguration()>

Replies the current configuration. The configuration
is extracted from the system configuration file
(from AutoLaTeX distribution) and from the user
configuration file.

I<Returns:> a hashtable containing (attribute name, attribute value) pairs.
The attribute name could be S<section.attribute> to describe the attribute inside
a section.

=cut
sub readConfiguration() {
	my %configuration = ();
	my $systemFile = getSystemConfigFilename();
	my $userFile = getUserConfigFilename();
	readConfigFile("$systemFile",\%configuration);
	readConfigFile("$userFile",\%configuration);
	# Remove the main intput filename
	if (exists $configuration{'generation.main file'}) {
		delete $configuration{'generation.main file'};
	}
	return %configuration;
}

=pod

=item B<readOnlySystemConfiguration()>

Replies the current configuration. The configuration
is extracted from the system configuration file
(from AutoLaTeX distribution) only.

I<Returns:> a hashtable containing (attribute name, attribute value) pairs.
The attribute name could be S<section.attribute> to describe the attribute inside
a section.

=cut
sub readOnlySystemConfiguration(;$) {
	my %configuration = ();
	my $systemFile = getSystemConfigFilename();
	readConfigFile("$systemFile",\%configuration,$_[0]);
	# Remove the main intput filename
	if (exists $configuration{'generation.main file'}) {
		delete $configuration{'generation.main file'};
	}
	return %configuration;
}

=pod

=item B<readOnlyUserConfiguration(;$)>

Replies the current configuration. The configuration
is extracted from the user configuration file
($HOME/.autolatex or $HOME/.autolatex/autolatex.conf) only.

I<Returns:> a hashtable containing (attribute name, attribute value) pairs.
The attribute name could be S<section.attribute> to describe the attribute inside
a section.

=cut
sub readOnlyUserConfiguration(;$) {
	my %configuration = ();
	my $userFile = getUserConfigFilename();
	readConfigFile("$userFile",\%configuration,$_[0]);
	# Remove the main intput filename
	if (exists $configuration{'generation.main file'}) {
		delete $configuration{'generation.main file'};
	}
	return %configuration;
}

=pod

=item B<readOnlyProjectConfiguration(@)>

Replies the current configuration. The configuration
is extracted from the project configuration file
($PROJECT_PATH/.autolatex_project.cfg) only.

I<Returns:> a hashtable containing (attribute name, attribute value) pairs.
The attribute name could be S<section.attribute> to describe the attribute inside
a section.

=cut
sub readOnlyProjectConfiguration(@) {
	my %configuration = ();
	my $userFile = getProjectConfigFilename(@_);
	if (-r "$userFile") {
		readConfigFile("$userFile",\%configuration);
		$configuration{'__private__'}{'input.project directory'} = File::Spec->catfile(@_);
		return \%configuration;
	}
	return undef;
}

=pod

=item B<readConfigFile($\%;$)>

Fill the configuration data structure from the specified file information.
The structure of the filled hashtable is a set of (attribute name, attribute value) pairs.
The attribute name could be S<section.attribute> to describe the attribute inside
a section.

I<Parameters:>

=over 8

=item * the name of the file to read

=item * the data structure to fill

=item * boolean value that indicates if a warning message should be ignored when an old fashion file was detected.

=back

I<Returns:> nothing

=cut
sub readConfigFile($\%;$) {
	my $filename = shift;
	die('second parameter of readConfigGile() is not a hash') unless(isHash($_[0]));
	locDbg("Opening configuration file {}",$filename);
	if (-r "$filename") {
		my $cfgReader = new Config::Simple("$filename");
		my %config = $cfgReader->vars();
		my $warningDisplayed = $_[1];
		while (my ($k,$v) = each (%config)) {
			$k = lc("$k");
			if ($k !~ /^__private__/) {
				$v = ensureAccendentCompatibility("$k",$v,"$filename",$warningDisplayed);
				$_[0]->{"$k"} = rebuiltConfigValue("$k",$v);
			}
		}
		locDbg("Succeed on reading");
	}
	else {
		locDbg("Failed to read {}: {}",$filename,$!);
	}
	1;
}

# Put formatted comments inside an array
sub pushComment(\@$;$) {
	my $limit = $_[2] || 60;
	$limit = 1 unless ($limit>=1);
	my @lines = split(/\n/, $_[1]);
	foreach my $line (@lines) {
		my @words = split(/\s+/, $line);
		my $wline = '';
		if ($line =~ /^(\s+)/) {
			$wline .= $1;
		}
		foreach my $w (@words) {
			if ((length($wline)+length($w)+1)>$limit) {
				push @{$_[0]}, "#$wline\n";
				if (length($w)>$limit) {
					while (length($w)>$limit) {
						push @{$_[0]}, "# ".substr($w,0,$limit)."\n";
						$w = substr($w,$limit);
					}
				}
				$wline = " $w";
			}
			else {
				$wline .= " $w";
			}
		}
		if ($wline) {
			push @{$_[0]}, "#$wline\n";
		}
	}
}

=pod

=item B<writeConfigFile($\%)>

Write the specified configuration into a file.

I<Parameters:>

=over 8

=item * the name of the file to write

=item * the configuration data structure to write

=back

I<Returns:> nothing

=cut
sub writeConfigFile($\%) {
	my $filename = shift;
	die('second parameter of writeConfigGile() is not a hash') unless(isHash($_[0]));

	# Write the values
	locDbg("Writing configuration file {}",$filename);
	printDbgIndent();
	my $cfgWriter = new Config::Simple(syntax=>'ini');
	while (my ($attr,$value) = each (%{$_[0]})) {
		if ($attr ne '__private__') {
			$cfgWriter->param("$attr",$value);
		}
	}
	$cfgWriter->write("$filename");

	# Updating for comments
	locDbg("Adding configuration comments");
	my %sectionComments = (
		'viewer' => "Configuration of the viewing functions",
		'generation' => "Configuration of the generation functions",
		'clean' => "Configuration of the several cleaning functions",
		'scm' => "Configuration of the SCM functions",
		'gtk' => "GTK interface configuration",
		'qt' => "Qt interface configuration",
		'windows' => "Windows interface configuration",
		'macos' => "MacOS interface configuration",
		'wxwidget' => "wxWidgets interface configuration",
	);
	my %attrComments = (
		'viewer.view' => "Indicates if a viewer should be launch after the compilation. Valid values are 'yes' and 'no'",
		'viewer.viewer' => "Specify, if not commented,the command line of the viewer",
		'generation.main file' => "Main filename (this option is only available in project's configuration files)",
		'generation.generate images' => "Does the figures must be automatically generated?",
		'generation.generation type' => "Type of generation.\n   pdf   : use pdflatex to create a PDF document\n   dvi   : use latex to create a DVI document\n   ps    : use latex and dvips to create a Postscript document\n   pspdf : use latex, dvips and ps2pdf to create a PDF document",
		'makeindex style' => "Specify the style that must be used by makeindex.\nValid values are:\n   <filename>      if a filename was specified, AutoLaTeX assumes that it is the .ist file;\n   \@system         AutoLaTeX uses the system default .ist file (in AutoLaTeX distribution);\n   \@detect         AutoLaTeX will tries to find a .ist file in the project's directory. If none was found, AutoLaTeX will not pass a style to makeindex;\n   \@none           AutoLaTeX assumes that no .ist file must be passed to makeindex;\n   <empty>         AutoLaTeX assumes that no .ist file must be passed to makeindex.",
		'clean.files to clean' => "List of additional files to remove when cleaning (shell wild cards are allowed). This list is used when the target 'clean' is invoked.",
		'clean.files to desintegrate' => "List of additional files to remove when all cleaning (shell wild cards are allowed). This list is used when the target 'cleanall' is invoked.",
		'scm.scm commit' => "Tool to launch when a SCM commit action is requested. Basically the SCM tools are CVs and SVN.",
		'scm.scm update' => "Tool to launch when a SCM update action is requested. Basically the SCM tools are CVs and SVN.",
		'translator include path' => "Defines the paths from which the translators could be loaded. This is a list of paths separated by the path separator character used by your operating system: ':' on Unix platforms or ';' on Windows platforms for example.",
	);

	local *CFGFILE;
	open (*CFGFILE, "< $filename") or printErr("$filename:","$!");
	my @lines = ();
	my $lastsection = undef;
	while (my $l = <CFGFILE>) {
		if ($l =~ /^\s*\[\s*(.+?)\s*\]\s*$/) {
			$lastsection = lc($1);
			if ($sectionComments{"$lastsection"}) {
				push @lines, "\n";
				pushComment @lines, $sectionComments{"$lastsection"};
			}
			else {
				push @lines, "\n";
				pushComment @lines, "Configuration of the translator '".$lastsection."'";
			}
		}
		elsif (($l =~ /^\s*(.*?)\s*=/)&&($lastsection)) {
			my $attr = lc($1);
			if ($attrComments{"$lastsection.$attr"}) {
				push @lines, "\n";
				pushComment @lines, $attrComments{"$lastsection.$attr"};
			}
		}
		push @lines, $l;
	}
	close(*CFGFILE);

	locDbg("Saving configuration comments");
	local *CFGFILE;
	open (*CFGFILE, "> $filename") or printErr("$filename:","$!");
	print CFGFILE (@lines);
	close(*CFGFILE);	

	printDbgUnindent();
	1;
}

=pod

=item B<doConfigurationFileFixing($)>

Fix the specified configuration file.

I<Parameters:>

=over 8

=item * the name of the file to fix

=back

I<Returns:> nothing

=cut
sub doConfigurationFileFixing($) {
	my $filename = shift;
	my %configuration = ();

	readConfigFile("$filename",%configuration,1);

	writeConfigFile("$filename",%configuration);

	1;
}

# Try to detect an old fashioned configuration file
# and fix the value
sub ensureAccendentCompatibility($$$$) {
	my $v = $_[1];
	$v = '' unless (defined($v));
	if (!isArray($v)) {
		my $changed = 0;

		# Remove comments on the same line as values
		if ($v =~ /^\s*(.*?)\s*\#.*$/) {
			$v = "$1" ;
			$changed = 1;
		}

		if ($v eq '@detect@system') {
			$v = ['detect','system'];
			$changed = 1;
		}

		if (($changed)&&(!$_[3])) {
			printWarn(locGet("AutoLaTeX has detecting an old fashion syntax for the configuration file {}\nPlease regenerate this file with the command line option --fixconfig.",$_[2]));
			$_[3] = 1;
		}
	}
	return $v;
}

# Reformat the value from a configuration file to apply several rules
# which could not be directly applied by the configuration readed.
# $_[0]: value name,
# $_[1]: value to validated.
sub rebuiltConfigValue($$) {
	my $v = $_[1];
	if (($_[0])&&($v)) {
		if ($_[0] eq 'generation.translator include path') {
			my $sep = getPathListSeparator();
			if (isHash($v)) {
				while (my ($key,$val) = each(%{$v})) {
					my @tab = split(/\s*$sep\s*/,"$val");
					if (@tab>1) {
						$v->{"$key"} = @tab;
					}
					else {
						$v->{"$key"} = pop @tab;
					}
				}
			}
			else {
				my @paths = ();
				if (isArray($v)) {
					foreach my $p (@{$v}) {
						push @paths, split(/\s*$sep\s*/,"$p");
					}
				}
				else {
					push @paths, split(/\s*$sep\s*/,"$v");
				}
				if (@paths>1) {
					$v = \@paths;
				}
				else {
					$v = pop @paths;
				}
			}
		}
	}
	return $v;
}

=pod

=item B<setInclusionFlags(\%\%;\%\%)>

Set the translator inclusion flags obtained from the configurations.

This function assumed that the translator list is an hashtable of
(translator_name => { 'included' => { level => boolean } }) pairs.

I<Parameters:>

=over 8

=item * the translator list.

=item * the system configuration.

=item * the user configuration.

=item * the project configuration.

=back

I<Returns:> nothing

=cut
sub setInclusionFlags(\%\%;\%\%) {
	die('first parameter of setInclusionFlags() is not a hash')
		unless (isHash($_[0]));
	die('second parameter of setInclusionFlags() is not a hash')
		unless (isHash($_[1]));
	foreach my $trans (keys %{$_[0]}) {
		if (!$_[0]->{"$trans"}{'included'}) {
			$_[0]->{"$trans"}{'included'} = {};
		}

		if ((exists $_[1]->{"$trans.include module"})&&(cfgIsBoolean($_[1]->{"$trans.include module"}))) {
			$_[0]->{"$trans"}{'included'}{'system'} = cfgBoolean($_[1]->{"$trans.include module"});
		}
		else {
			# On system level, a module which was not specified as not includable must
			# be included even if it will cause conflicts
			$_[0]->{"$trans"}{'included'}{'system'} = undef;
		}

		if (($_[2])&&
		    (exists $_[2]->{"$trans.include module"})&&
		    (cfgIsBoolean($_[2]->{"$trans.include module"}))) {
			$_[0]->{"$trans"}{'included'}{'user'} = cfgBoolean($_[2]->{"$trans.include module"});
		}
		else {
			$_[0]->{"$trans"}{'included'}{'user'} = undef;
		}

		if (($_[3])&&
		    (exists $_[3]->{"$trans.include module"})&&
		    (cfgIsBoolean($_[3]->{"$trans.include module"}))) {
			$_[0]->{"$trans"}{'included'}{'project'} = cfgBoolean($_[3]->{"$trans.include module"});
		}
		else {
			$_[0]->{"$trans"}{'included'}{'project'} = undef;
		}
	}
}

=pod

=item B<setInclusionFlags(\%\%;\%\%)>

Init the translator inclusion flags obtained from the configurations.

This function assumed that the translator list is an hashtable of
(translator_name => { 'included' => { level => undef } }) pairs.

I<Parameters:>

=over 8

=item * the translator list.

=item * the system configuration.

=item * the user configuration.

=item * the project configuration.

=back

I<Returns:> nothing

=cut
sub reinitInclusionFlags(\%\%;\%\%) {
	die('first parameter of setInclusionFlags() is not a hash')
		unless (isHash($_[0]));
	die('second parameter of setInclusionFlags() is not a hash')
		unless (isHash($_[1]));
	foreach my $trans (keys %{$_[0]}) {
		if (!$_[0]->{"$trans"}{'included'}) {
			$_[0]->{"$trans"}{'included'} = {};
		}

		$_[0]->{"$trans"}{'included'}{'system'} = undef;

		if ($_[2]) {
		    $_[0]->{"$trans"}{'included'}{'user'} = undef;
		}

		if ($_[3]) {
			$_[0]->{"$trans"}{'included'}{'project'} = undef;
		}
	}
}

1;
__END__
=back

=head1 BUG REPORT AND FEEDBACK

To report bugs, provide feedback, suggest new features, etc. visit the AutoLaTeX Project management page at <http://www.arakhne.org/autolatex/> or send email to the author at L<galland@arakhne.org>.

=head1 LICENSE

S<GNU Public License (GPL)>

=head1 COPYRIGHT

S<Copyright (c) 1998-07 Stéphane Galland E<lt>galland@arakhne.orgE<gt>>

=head1 SEE ALSO

L<autolatex-dev>
