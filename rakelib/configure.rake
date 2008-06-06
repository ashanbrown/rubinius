#
# configure.rake - handles all configuration and generate needed build files
#

file 'lib/rbconfig.rb' => :config_env do
  write_rbconfig
end

%w[shotgun/config.mk shotgun/config.h].each do |f|
  file f => :config_env do
    write_config
  end
end

task :configure => %w[shotgun/config.mk lib/rbconfig.rb shotgun/config.h]

task :config_env => %W[rakelib/configure.rake] do
  libtool = system("which glibtool > /dev/null") ? "glibtool" : "libtool"

  DTRACE              = ENV['DTRACE']
  ENGINE              = "rbx"
  PREFIX              = ENV['PREFIX'] || "/usr/local"
  RBX_RUBY_VERSION    = "1.8.6"
  RBX_RUBY_PATCHLEVEL = "111"
  LIBVER              = "0.8"
  RBX_VERSION         = "#{LIBVER}.0"
  HOST                = `./shotgun/config.guess`.chomp
  BUILDREV            = `git rev-list --all | head -n1`.chomp
  CC                  = ENV['CC'] || 'gcc'
  BINPATH             = "#{PREFIX}/bin"
  LIBPATH             = "#{PREFIX}/lib"
  CODEPATH            = "#{PREFIX}/lib/rubinius/#{LIBVER}"
  RBAPATH             = "#{PREFIX}/lib/rubinius/#{LIBVER}/runtime"
  EXTPATH             = "#{PREFIX}/lib/rubinius/#{LIBVER}/#{HOST}"

  case HOST
  when /darwin9/ then
    DARWIN         = 1
    DISABLE_KQUEUE = 1
  when /darwin/ then
    DARWIN         = 1
    DISABLE_KQUEUE = 1
  else
    DARWIN         = 0
    DISABLE_KQUEUE = (HOST =~ /freebsd/ ? 1 : 0)
  end
end

def write_config
  Dir.chdir(File.join(RUBINIUS_BASE, 'shotgun')) do
    File.open("config.mk", "w") do |f|
      f.puts "BUILDREV        = #{BUILDREV}"
      f.puts "ENGINE          = #{ENGINE}"
      f.puts "PREFIX          = #{PREFIX}"
      f.puts "RUBY_VERSION    = #{RBX_RUBY_VERSION}"
      f.puts "RUBY_PATCHLEVEL = #{RBX_RUBY_PATCHLEVEL}"
      f.puts "LIBVER          = #{LIBVER}"
      f.puts "VERSION         = #{RBX_VERSION}"
      f.puts "HOST            = #{HOST}"
      f.puts "DARWIN          = #{DARWIN}"
      f.puts "DISABLE_KQUEUE  = #{DISABLE_KQUEUE}"
      f.puts "BINPATH         = #{BINPATH}"
      f.puts "LIBPATH         = #{LIBPATH}"
      f.puts "CODEPATH        = #{CODEPATH}"
      f.puts "RBAPATH         = #{RBAPATH}"
      f.puts "EXTPATH         = #{EXTPATH}"
      f.puts "BUILDREV        = #{BUILDREV}"
      f.puts "DTRACE          = #{DTRACE}"

      case HOST
      when /darwin9/ then
        f.puts "MACOSX_DEPLOYMENT_TARGET=10.5"
      when /darwin/ then
        f.puts "MACOSX_DEPLOYMENT_TARGET=10.4"
      end
    end

    unix_date = Time.now.strftime("%m/%d/%Y")

    File.open("config.h", "w") do |f|
      f.puts "#define CONFIG_DARWIN           #{DARWIN.to_s.inspect}"
      f.puts "#define CONFIG_DISABLE_KQUEUE   #{DISABLE_KQUEUE}"
      f.puts "#define CONFIG_HOST             #{HOST.inspect}"
      f.puts "#define CONFIG_PREFIX           #{PREFIX.inspect}"
      f.puts "#define CONFIG_VERSION          #{RBX_VERSION.inspect}"
      f.puts "#define CONFIG_RUBY_VERSION     #{RBX_RUBY_VERSION.inspect}"
      f.puts "#define CONFIG_RELDATE          #{unix_date.inspect}"
      f.puts "#define CONFIG_RUBY_PATCHLEVEL  #{RBX_RUBY_PATCHLEVEL.inspect}"
      f.puts "#define CONFIG_CODEPATH         #{CODEPATH.inspect}"
      f.puts "#define CONFIG_RBAPATH          #{RBAPATH.inspect}"
      f.puts "#define CONFIG_EXTPATH          #{EXTPATH.inspect}"
      f.puts "#define CONFIG_BUILDREV         #{BUILDREV.inspect}"
      f.puts "#define CONFIG_ENGINE           #{ENGINE.inspect}"
      f.puts "#define CONFIG_CC               #{CC.inspect}"

      if DTRACE then
        f.puts "#define CONFIG_ENABLE_DTRACE 1"
      end

      if system "config/run is64bit > /dev/null" then
        f.puts "#define CONFIG_WORDSIZE 64"
        f.puts "#define CONFIG_ENABLE_DT 0"
      else
        f.puts "#define CONFIG_WORDSIZE 32"
        f.puts "#define CONFIG_ENABLE_DT 1"
      end

      if system "config/run isbigendian > /dev/null" then
        f.puts "#define CONFIG_BIG_ENDIAN 1"
      else
        f.puts "#define CONFIG_BIG_ENDIAN 0"
      end
    end
  end
end

def write_rbconfig
  File.open 'lib/rbconfig.rb', 'w' do |f|
    f.puts '#--'
    f.puts '# This file was generated by the Rubinius rakelib/configure.rake.'
    f.puts '#++'
    f.puts
    f.puts 'module Config'
    f.puts '  unless defined? RUBY_ENGINE and RUBY_ENGINE == "rbx" then'
    f.puts '    raise "Looks like you loaded the Rubinius rbconfig, but this is not Rubinius."'
    f.puts '  end'
    f.puts
    f.puts '  prefix = File.dirname(File.dirname(__FILE__))'
    f.puts
    f.puts '  CONFIG = {}'
    f.puts
    f.puts '  CONFIG["prefix"]             = prefix'
    f.puts %Q!  CONFIG["install_prefix"]     = "#{PREFIX}"!
    f.puts '  CONFIG["DLEXT"]              = Rubinius::LIBSUFFIX.dup'
    f.puts '  CONFIG["EXEEXT"]             = ""'
    f.puts '  CONFIG["ruby_install_name"]  = RUBY_ENGINE.dup'
    f.puts '  CONFIG["RUBY_INSTALL_NAME"]  = RUBY_ENGINE.dup'

    f.puts '  CONFIG["exec_prefix"]        = "$(prefix)"'
    f.puts '  if File.exists?(File.join(prefix, "bin", "rbx"))'
    f.puts '    CONFIG["bindir"]             = "$(exec_prefix)/bin"'
    f.puts '  else'
    f.puts "    CONFIG[\"bindir\"]           = '#{BINPATH}'"
    f.puts '  end'
    f.puts '  CONFIG["sbindir"]            = "$(exec_prefix)/sbin"'
    f.puts '  CONFIG["libexecdir"]         = "$(exec_prefix)/libexec"'
    f.puts '  CONFIG["datarootdir"]        = "$(prefix)/share"'
    f.puts '  CONFIG["datadir"]            = "$(datarootdir)"'
    f.puts '  CONFIG["sysconfdir"]         = "$(prefix)/etc"'
    f.puts '  CONFIG["sharedstatedir"]     = "$(prefix)/com"'
    f.puts '  CONFIG["localstatedir"]      = "$(prefix)/var"'
    f.puts '  CONFIG["includedir"]         = "$(prefix)/include"'
    f.puts '  CONFIG["oldincludedir"]      = "/usr/include"'
    f.puts '  CONFIG["docdir"]             = "$(datarootdir)/doc/$(PACKAGE)"'
    f.puts '  CONFIG["infodir"]            = "$(datarootdir)/info"'
    f.puts '  CONFIG["htmldir"]            = "$(docdir)"'
    f.puts '  CONFIG["dvidir"]             = "$(docdir)"'
    f.puts '  CONFIG["pdfdir"]             = "$(docdir)"'
    f.puts '  CONFIG["psdir"]              = "$(docdir)"'
    f.puts '  CONFIG["libdir"]             = "$(exec_prefix)/lib"'
    f.puts '  CONFIG["localedir"]          = "$(datarootdir)/locale"'
    f.puts '  CONFIG["mandir"]             = "$(datarootdir)/man"'
    f.puts '  CONFIG["sitedir"]            = "$(libdir)/ruby/site_ruby"'

    f.puts '  major, minor, teeny = RUBY_VERSION.split(".")'
    f.puts '  CONFIG["MAJOR"]              = "#{major}"'
    f.puts '  CONFIG["MINOR"]              = "#{minor}"'
    f.puts '  CONFIG["TEENY"]              = "#{teeny}"'

    f.puts '  CONFIG["ruby_version"]       = "$(MAJOR).$(MINOR).$(TEENY)"'
    f.puts '  CONFIG["rubylibdir"]         = "$(libdir)/ruby/$(ruby_version)"'
    f.puts '  CONFIG["archdir"]            = "$(rubylibdir)/$(arch)"'
    f.puts '  CONFIG["sitelibdir"]         = "$(sitedir)/$(ruby_version)"'
    f.puts '  CONFIG["sitearchdir"]        = "$(sitelibdir)/$(sitearch)"'
    f.puts '  CONFIG["topdir"]             = File.dirname(__FILE__)'

    f.puts '  # some of these only relevant to cross-compiling'
    f.puts '  /([^-]+)-([^-]+)-(.*)/ =~ RUBY_PLATFORM'
    f.puts '  cpu, vendor, os = $1, $2, $3'
    f.puts '  CONFIG["build"]              = "#{cpu}-#{vendor}-#{os}"'
    f.puts '  CONFIG["build_cpu"]          = "#{cpu}"'
    f.puts '  CONFIG["build_vendor"]       = "#{vendor}"'
    f.puts '  CONFIG["build_os"]           = "#{os}"'
    f.puts '  CONFIG["host"]               = "#{cpu}-#{vendor}-#{os}"'
    f.puts '  CONFIG["host_cpu"]           = "#{cpu}"'
    f.puts '  CONFIG["host_vendor"]        = "#{vendor}"'
    f.puts '  CONFIG["host_os"]            = "#{os}"'
    f.puts '  CONFIG["target"]             = "#{cpu}-#{vendor}-#{os}"'
    f.puts '  CONFIG["target_cpu"]         = "#{cpu}"'
    f.puts '  CONFIG["target_vendor"]      = "#{vendor}"'
    f.puts '  CONFIG["target_os"]          = "#{os}"'
    f.puts '  CONFIG["arch"]               = "#{cpu}-#{os}"'
    f.puts '  CONFIG["sitearch"]           = "#{cpu}-#{os}"'
    f.puts '  CONFIG["build_alias"]        = ""'
    f.puts '  CONFIG["host_alias"]         = ""'
    f.puts '  CONFIG["target_alias"]       = ""'

    f.puts '  CONFIG["RUBY_SO_NAME"]       = "rubinius-#{Rubinius::RBX_VERSION}"'
    f.puts '  CONFIG["sitedir"]            = "$(install_prefix)/lib/rubinius"'
    f.puts '  if File.directory?(File.join(prefix, "shotgun"))'
    f.puts '    CONFIG["rubyhdrdir"]         = "$(prefix)/shotgun/lib/subtend"'
    f.puts '  else'
    f.puts '    CONFIG["rubyhdrdir"]         = "#{Rubinius::CODE_PATH}/$(host)"'
    f.puts '  end'
    f.puts '  CONFIG["wordsize"]           = Rubinius::WORDSIZE'

    # TODO: we should compose sitelibdir from existing CONFIG keys
    f.puts "  CONFIG[\"sitelibdir\"]         = \"$(sitedir)/#{LIBVER}\""

    # TODO: we need to be able to discover these, but for now, UNIXy defaults
    f.puts '  # command line utilities'
    f.puts '  CONFIG["SHELL"]              = "/bin/sh"'
    f.puts '  CONFIG["ECHO_C"]             = ""'
    f.puts '  CONFIG["ECHO_N"]             = "-n"'
    f.puts '  CONFIG["ECHO_T"]             = ""'
    f.puts '  CONFIG["GREP"]               = "/usr/bin/grep"'
    f.puts '  CONFIG["EGREP"]              = "/usr/bin/grep -E"'
    f.puts '  CONFIG["RM"]                 = "rm -f"'
    f.puts '  CONFIG["CP"]                 = "cp"'
    f.puts '  CONFIG["NROFF"]              = "/usr/bin/nroff"'
    f.puts '  CONFIG["MAKEDIRS"]           = "mkdir -p"'

    f.puts '  # compile tools'
    f.puts '  CONFIG["CC"]                 = "gcc"'
    f.puts '  CONFIG["CPP"]                = "gcc -E"'
    f.puts '  CONFIG["YACC"]               = "bison -y"'
    f.puts '  CONFIG["RANLIB"]             = "ranlib"'
    f.puts '  CONFIG["AR"]                 = "ar"'
    f.puts '  CONFIG["AS"]                 = "as"'
    f.puts '  CONFIG["WINDRES"]            = ""'
    f.puts '  CONFIG["DLLWRAP"]            = ""'
    f.puts '  CONFIG["OBJDUMP"]            = ""'
    f.puts '  CONFIG["LN_S"]               = "ln -s"'
    f.puts '  CONFIG["NM"]                 = ""'
    f.puts '  CONFIG["INSTALL_PROGRAM"]    = "$(INSTALL)"'
    f.puts '  CONFIG["INSTALL_SCRIPT"]     = "$(INSTALL)"'
    f.puts '  CONFIG["INSTALL_DATA"]       = "$(INSTALL) -m 644"'
    f.puts '  CONFIG["STRIP"]              = "strip -A -n"'
    f.puts '  CONFIG["MANTYPE"]            = "doc"'
    f.puts '  CONFIG["MAKEFILES"]          = "Makefile"'

    # TODO: fill in these values
    f.puts '  # compile tools flags'
    f.puts '  CONFIG["CFLAGS"]             = ""'
    f.puts '  CONFIG["LDFLAGS"]            = ""'
    f.puts '  CONFIG["CPPFLAGS"]           = ""'
    f.puts '  CONFIG["OBJEXT"]             = "o"'
    f.puts '  CONFIG["GNU_LD"]             = ""'
    f.puts '  CONFIG["CPPOUTFILE"]         = ""'
    f.puts '  CONFIG["OUTFLAG"]            = "-o "'
    f.puts '  CONFIG["YFLAGS"]             = ""'
    f.puts '  CONFIG["ASFLAGS"]            = ""'
    f.puts '  CONFIG["DLDFLAGS"]           = ""'
    f.puts '  CONFIG["ARCH_FLAG"]          = ""'
    f.puts '  CONFIG["STATIC"]             = ""'
    f.puts '  CONFIG["CCDLFLAGS"]          = ""'
    f.puts '  CONFIG["XCFLAGS"]            = ""'
    f.puts '  CONFIG["XLDFLAGS"]           = ""'
    f.puts '  CONFIG["LIBRUBY_DLDFLAGS"]   = ""'
    f.puts '  CONFIG["rubyw_install_name"] = ""'
    f.puts '  CONFIG["RUBYW_INSTALL_NAME"] = ""'
    f.puts '  CONFIG["SOLIBS"]             = ""'
    f.puts '  CONFIG["DLDLIBS"]            = ""'
    f.puts '  CONFIG["ENABLE_SHARED"]      = ""'
    f.puts '  CONFIG["MAINLIBS"]           = ""'
    f.puts '  CONFIG["COMMON_LIBS"]        = ""'
    f.puts '  CONFIG["COMMON_MACROS"]      = ""'
    f.puts '  CONFIG["COMMON_HEADERS"]     = ""'
    f.puts '  CONFIG["EXPORT_PREFIX"]      = ""'
    f.puts '  CONFIG["EXTOUT"]             = ".ext"'
    f.puts '  CONFIG["ARCHFILE"]           = ""'
    f.puts '  CONFIG["RDOCTARGET"]         = ""'
    f.puts '  CONFIG["LIBRUBY_A"]          = "lib$(RUBY_SO_NAME)-static.a"'
    f.puts '  CONFIG["LIBRUBY_SO"]         = "lib$(RUBY_SO_NAME).so"'
    f.puts '  CONFIG["LIBRUBY_ALIASES"]    = "lib$(RUBY_SO_NAME).so"'
    f.puts '  CONFIG["LIBRUBY"]            = "$(LIBRUBY_A)"'
    f.puts '  CONFIG["LIBRUBYARG"]         = "$(LIBRUBYARG_STATIC)"'
    f.puts '  CONFIG["LIBRUBYARG_STATIC"]  = "-l$(RUBY_SO_NAME)-static"'
    f.puts '  CONFIG["LIBRUBYARG_SHARED"]  = ""'
    f.puts '  CONFIG["configure_args"]     = ""'
    f.puts '  CONFIG["ALLOCA"]             = ""'
    f.puts '  CONFIG["DLEXT"]              = "bundle"'
    f.puts '  CONFIG["LIBEXT"]             = "a"'
    f.puts '  CONFIG["LINK_SO"]            = ""'
    f.puts '  CONFIG["LIBPATHFLAG"]        = " -L%s"'
    f.puts '  CONFIG["RPATHFLAG"]          = ""'
    f.puts '  CONFIG["LIBPATHENV"]         = "DYLD_LIBRARY_PATH"'
    f.puts '  CONFIG["TRY_LINK"]           = ""'
    f.puts '  CONFIG["EXTSTATIC"]          = ""'
    f.puts '  CONFIG["setup"]              = "Setup"'
    f.puts '  CONFIG["PATH_SEPARATOR"]     = ":"'
    f.puts '  CONFIG["PACKAGE_NAME"]       = ""'
    f.puts '  CONFIG["PACKAGE_TARNAME"]    = ""'
    f.puts '  CONFIG["PACKAGE_VERSION"]    = ""'
    f.puts '  CONFIG["PACKAGE_STRING"]     = ""'
    f.puts '  CONFIG["PACKAGE_BUGREPORT"]  = ""'

    # HACK: we need something equivalent, but I'm cheating for now - zenspider
    f.puts '  CONFIG["LDSHARED"]          = "cc -dynamic -bundle -undefined suppress -flat_namespace"'
    f.puts '  CONFIG["LIBRUBY_LDSHARED"]  = "cc -dynamic -bundle -undefined suppress -flat_namespace"'
    f.puts
    f.puts <<-EOC
  # Adapted from MRI's' rbconfig.rb
  MAKEFILE_CONFIG = {}
  CONFIG.each { |k,v| MAKEFILE_CONFIG[k] = v.kind_of?(String) ? v.dup : v }

  def Config.expand(val, config = CONFIG)
    return val unless val.kind_of? String

    val.gsub!(/\\$\\$|\\$\\(([^()]+)\\)|\\$\\{([^{}]+)\\}/) do |var|
      if !(v = $1 || $2)
        '$'
      elsif key = config[v = v[/\\A[^:]+(?=(?::(.*?)=(.*))?\\z)/]]
        pat, sub = $1, $2
        config[v] = false
        Config.expand(key, config)
        config[v] = key
        key = key.gsub(/\#{Regexp.quote(pat)}(?=\\s|\\z)/n) {sub} if pat
        key
      else
        var
      end
    end
    val
  end

  CONFIG.each_value do |val|
    Config.expand(val)
  end
EOC
    f.puts "end"
    f.puts
    f.puts "CROSS_COMPILING = nil unless defined? CROSS_COMPILING"
    f.puts "RbConfig = Config"
  end
end
