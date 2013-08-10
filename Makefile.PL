use strict;
use ExtUtils::MakeMaker 6.31;

my $meta = {
  "abstract"           => "implementation of WebID (a.k.a. FOAF+SSL)",
  "author"             => ["Toby Inkster <tobyink\@cpan.org>"],
  "dynamic_config"     => 1,
  "generated_by"       => "Dist::Inkt::Profile::TOBYINK version 0.002, CPAN::Meta::Converter version 2.120921",
  "keywords"           => [],
  "license"            => ["perl_5"],
  "meta-spec"          => {
                            url => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
                            version => 2,
                          },
  "name"               => "Web-ID",
  "no_index"           => { directory => ["eg", "examples", "inc", "t", "xt"] },
  "prereqs"            => {
                            configure => {
                              requires => { "ExtUtils::MakeMaker" => 6.31, "File::ShareDir" => 0 },
                            },
                            runtime => {
                              requires => {
                                "Crypt::X509"        => 0,
                                "DateTime"           => 0,
                                "Digest::SHA"        => 0,
                                "Exporter::TypeTiny" => 0.004,
                                "File::ShareDir"     => 0,
                                "List::MoreUtils"    => 0,
                                "match::simple"      => 0.004,
                                "Moose"              => "2.0600",
                                "namespace::sweep"   => 0,
                                "Path::Tiny"         => 0,
                                "Plack"              => 0,
                                "RDF::Query"         => "2.900",
                                "RDF::Trine"         => "1.000",
                                "Types::Standard"    => 0.022,
                                "URI"                => 0,
                              },
                            },
                            test => { requires => { "Test::More" => 0.96 } },
                          },
  "provides"           => {
                            "Plack::Middleware::Auth::WebID"  => { file => "lib/Plack/Middleware/Auth/WebID.pm", version => "1.924_03" },
                            "Web::ID"                         => { file => "lib/Web/ID.pm", version => "1.924_03" },
                            "Web::ID::Certificate"            => { file => "lib/Web/ID/Certificate.pm", version => "1.924_03" },
                            "Web::ID::Certificate::Generator" => {
                                                                   file => "lib/Web/ID/Certificate/Generator.pm",
                                                                   version => "1.924_03",
                                                                 },
                            "Web::ID::RSAKey"                 => { file => "lib/Web/ID/RSAKey.pm", version => "1.924_03" },
                            "Web::ID::SAN"                    => { file => "lib/Web/ID/SAN.pm", version => "1.924_03" },
                            "Web::ID::SAN::Email"             => { file => "lib/Web/ID/SAN/Email.pm", version => "1.924_03" },
                            "Web::ID::SAN::URI"               => { file => "lib/Web/ID/SAN/URI.pm", version => "1.924_03" },
                            "Web::ID::Types"                  => { file => "lib/Web/ID/Types.pm", version => "1.924_03" },
                            "Web::ID::Util"                   => { file => "lib/Web/ID/Util.pm", version => "1.924_03" },
                            "Web::ID::Util::FindOpenSSL"      => { file => "lib/Web/ID/Util/FindOpenSSL.pm", version => "1.924_03" },
                          },
  "release_status"     => "testing",
  "resources"          => {
                            bugtracker => { web => "http://rt.cpan.org/Dist/Display.html?Queue=Web-ID" },
                            homepage   => "https://metacpan.org/release/Web-ID",
                            license    => ["http://dev.perl.org/licenses/"],
                            repository => { type => "git", web => "https://github.com/tobyink/p5-web-id" },
                          },
  "version"            => "1.924_03",
  "x_provides_scripts" => {},
};

my %dynamic_config;
do {
	# If we can't find openssl via normal techniques,
	# add a dependency on Alien::OpenSSL.
	#
	use lib "lib";
	require Web::ID::Util::FindOpenSSL;
	$meta->{prereqs}{runtime}{requires}{"Alien::OpenSSL"} = "0.03"
		unless -x Web::ID::Util::FindOpenSSL::find_openssl();

};

my %WriteMakefileArgs = (
	ABSTRACT           => $meta->{abstract},
	AUTHOR             => $meta->{author},
	DISTNAME           => $meta->{name},
	DISTVNAME          => sprintf('%s-%s', $meta->{name}, $meta->{version}),
	EXE_FILES          => [ map $_->{file}, values %{ $meta->{x_provides_scripts} || {} } ],
	LICENSE            => $meta->{license}[0],
	NAME               => do { my $n = $meta->{name}; $n =~ s/-/::/g; $n },
	VERSION            => $meta->{version},
	%dynamic_config,
);

sub deps
{
	my %r;
	for my $stage (@_)
	{
		for my $dep (keys %{$meta->{prereqs}{$stage}{requires}})
		{
			my $ver = $meta->{prereqs}{$stage}{requires}{$dep};
			$r{$dep} = $ver if !exists($r{$dep}) || $ver >= $r{$dep};
		}
	}
	\%r;
}

my ($build_requires, $configure_requires, $runtime_requires, $test_requires);
if ('ExtUtils::MakeMaker'->VERSION >= 6.6303)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure');
	$WriteMakefileArgs{TEST_REQUIRES}      ||= deps('test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');
}
elsif ('ExtUtils::MakeMaker'->VERSION >= 6.5503)
{
	$WriteMakefileArgs{BUILD_REQUIRES}     ||= deps('build');
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure', 'test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');	
}
elsif ('ExtUtils::MakeMaker'->VERSION >= 6.52)
{
	$WriteMakefileArgs{CONFIGURE_REQUIRES} ||= deps('configure', 'build', 'test');
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('runtime');	
}
else
{
	$WriteMakefileArgs{PREREQ_PM}          ||= deps('configure', 'build', 'test', 'runtime');	
}

{
	my $minperl = delete $WriteMakefileArgs{PREREQ_PM}{perl};
	exists($WriteMakefileArgs{$_}) && delete($WriteMakefileArgs{$_}{perl})
		for qw(BUILD_REQUIRES TEST_REQUIRES CONFIGURE_REQUIRES);
	if ($minperl and 'ExtUtils::MakeMaker'->VERSION >= 6.48)
	{
		$WriteMakefileArgs{MIN_PERL_VERSION} ||= $minperl;
	}
	elsif ($minperl)
	{
		die "Need Perl >= $minperl" unless $] >= $minperl;
	}
}

sub FixMakefile
{
	return unless -d 'inc';
	my $file = shift;
	
	local *MAKEFILE;
	open MAKEFILE, "< $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	my $makefile = do { local $/; <MAKEFILE> };
	close MAKEFILE or die $!;
	
	$makefile =~ s/\b(test_harness\(\$\(TEST_VERBOSE\), )/$1'inc', /;
	$makefile =~ s/( -I\$\(INST_ARCHLIB\))/ -Iinc$1/g;
	$makefile =~ s/( "-I\$\(INST_LIB\)")/ "-Iinc"$1/g;
	$makefile =~ s/^(FULLPERL = .*)/$1 "-Iinc"/m;
	$makefile =~ s/^(PERL = .*)/$1 "-Iinc"/m;
	
	open  MAKEFILE, "> $file" or die "FixMakefile: Couldn't open $file: $!; bailing out";
	print MAKEFILE $makefile or die $!;
	close MAKEFILE or die $!;
}

my $mm = WriteMakefile(%WriteMakefileArgs);
FixMakefile($mm->{FIRST_MAKEFILE} || 'Makefile');
exit(0);

