Name:           perl-Catmandu
Version:        1.0201
Release:        1%{?dist}
Summary:        Data toolkit
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Catmandu/
Source0:        http://www.cpan.org/authors/id/N/NI/NICS/Catmandu-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(Math::BigRat)
BuildRequires:  perl >= 1:v5.10.1
BuildRequires:  perl(Any::URI::Escape)
BuildRequires:  perl(App::Cmd) >= 0.33
BuildRequires:  perl(asa)
BuildRequires:  perl(CGI::Expand) >= 2.02
BuildRequires:  perl(Clone) >= 0.31
BuildRequires:  perl(Code::TidyAll)
BuildRequires:  perl(Config::Onion) >= 1.004
BuildRequires:  perl(Cpanel::JSON::XS) >= 3.0213
BuildRequires:  perl(Data::Compare) >= 1.22
BuildRequires:  perl(Data::UUID) >= 1.217
BuildRequires:  perl(File::Find::Rule) >= 0.33
BuildRequires:  perl(File::Slurp::Tiny) >= 0.003
BuildRequires:  perl(Hash::Merge::Simple)
BuildRequires:  perl(IO::Handle::Util) >= 0.01
BuildRequires:  perl(List::MoreUtils) >= 0.33
BuildRequires:  perl(Log::Any::Adapter)
BuildRequires:  perl(Log::Any::Adapter::Log4perl) >= 0.06
BuildRequires:  perl(Log::Any::Test) >= 1.03
BuildRequires:  perl(Log::Log4perl) >= 1.44
BuildRequires:  perl(LWP::UserAgent)
BuildRequires:  perl(LWP::UserAgent::Determined)
BuildRequires:  perl(Marpa::R2) >= 3.000000
BuildRequires:  perl(Module::Build)
BuildRequires:  perl(Module::Info)
BuildRequires:  perl(Moo) >= 1.004006
BuildRequires:  perl(MooX::Aliases) >= 0.001006
BuildRequires:  perl(MooX::Role::Logger) >= 0.005
BuildRequires:  perl(namespace::clean) >= 0.24
BuildRequires:  perl(Perl::Tidy)
BuildRequires:  perl(Ref::Util) >= 0.020
BuildRequires:  perl(Sub::Exporter) >= 0.982
BuildRequires:  perl(Sub::Quote)
BuildRequires:  perl(Test::Code::TidyAll) >= 0.20
BuildRequires:  perl(Test::Deep) >= 0.112
BuildRequires:  perl(Test::Exception) >= 0.43
BuildRequires:  perl(Test::LWP::UserAgent)
BuildRequires:  perl(Test::More) >= 0.99
BuildRequires:  perl(Test::Pod)
BuildRequires:  perl(Text::CSV) >= 1.21
BuildRequires:  perl(Text::Diff)
BuildRequires:  perl(Text::Hogan::Compiler) >= 1.02
BuildRequires:  perl(Throwable) >= 0.200004
BuildRequires:  perl(Time::HiRes)
BuildRequires:  perl(Time::Piece)
BuildRequires:  perl(Try::Tiny::ByClass) >= 0.01
BuildRequires:  perl(Unicode::Normalize)
BuildRequires:  perl(URI)
BuildRequires:  perl(URI::Template) >= 0.22
BuildRequires:  perl(YAML::XS) >= 0.41
BuildRequires:  perl(Devel::Peek)
Requires:       perl(Any::URI::Escape)
Requires:       perl(App::Cmd) >= 0.33
Requires:       perl(asa)
Requires:       perl(CGI::Expand) >= 2.02
Requires:       perl(Clone) >= 0.31
Requires:       perl(Config::Onion) >= 1.004
Requires:       perl(Cpanel::JSON::XS) >= 3.0213
Requires:       perl(Data::Compare) >= 1.22
Requires:       perl(Data::UUID) >= 1.217
Requires:       perl(File::Find::Rule) >= 0.33
Requires:       perl(File::Slurp::Tiny) >= 0.003
Requires:       perl(Hash::Merge::Simple)
Requires:       perl(IO::Handle::Util) >= 0.01
Requires:       perl(List::MoreUtils) >= 0.33
Requires:       perl(Log::Any::Adapter)
Requires:       perl(Log::Any::Adapter::Log4perl) >= 0.06
Requires:       perl(Log::Log4perl) >= 1.44
Requires:       perl(LWP::UserAgent)
Requires:       perl(LWP::UserAgent::Determined)
Requires:       perl(Marpa::R2) >= 3.000000
Requires:       perl(Module::Info)
Requires:       perl(Moo) >= 1.004006
Requires:       perl(MooX::Aliases) >= 0.001006
Requires:       perl(MooX::Role::Logger) >= 0.005
Requires:       perl(namespace::clean) >= 0.24
Requires:       perl(Ref::Util) >= 0.020
Requires:       perl(Sub::Exporter) >= 0.982
Requires:       perl(Sub::Quote)
Requires:       perl(Text::CSV) >= 1.21
Requires:       perl(Text::Hogan::Compiler) >= 1.02
Requires:       perl(Throwable) >= 0.200004
Requires:       perl(Time::HiRes)
Requires:       perl(Time::Piece)
Requires:       perl(Try::Tiny::ByClass) >= 0.01
Requires:       perl(Unicode::Normalize)
Requires:       perl(URI)
Requires:       perl(URI::Template) >= 0.22
Requires:       perl(YAML::XS) >= 0.41
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Catmandu provides a command line client and a Perl API to ease the export
(E) transformation (T) and loading (L) of data into databases or data file,
ETL in short.

%prep
%setup -q -n Catmandu-%{version}

%build
%{__perl} Build.PL installdirs=vendor
./Build

%install
rm -rf $RPM_BUILD_ROOT

./Build install destdir=$RPM_BUILD_ROOT create_packlist=0
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
./Build test

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc benchmark Changes cpanfile dist.ini README.md
%{perl_vendorlib}/*
%{_bindir}/catmandu
%{_mandir}/man3/*
%{_mandir}/man1/*


%changelog
* Thu Jun 02 2016 Nicholas van Oudtshoorn <vanoudt@gmail.com> 1.0201-1
- Specfile autogenerated by cpanspec 1.78.
