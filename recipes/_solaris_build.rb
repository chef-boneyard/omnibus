
# Set up the compiler - we don't trust the one that solaris brings to the table.
# it's a little out of date.

solaris_toolchain_env =
  { 'GREP' => 'ggrep',
    'CC' => '/usr/sfw/bin/gcc -m64',
    'CXX' => '/usr/sfw/bin/g++ -m64',
    'LD' => 'ld -64',
    'LD_LIBRARY_PATH' => '/usr/sfw/lib/amd64:/usr/sfw/lib:/usr/local/lib',
  }
# omnibus_env['GREP'] = 'ggrep'
# omnibus_env['CC'] = 'gcc -m64'
# omnibus_env['CXX'] = 'g++ -m64'
# omnibus_env['LD'] = 'ld -64'
# omnibus_env['MAKE'] = 'gmake'

# set up make, since everything expects we have gnu make
link '/usr/sfw/bin/make' do
  to '/usr/sfw/bin/gmake'
end

# same with tar
link '/usr/sfw/bin/tar' do
  to '/usr/sfw/bin/gtar'
end

# same with grep *sigh*
link '/usr/sfw/bin/grep' do
  to '/usr/sfw/bin/ggrep'
end

# In order to install the gnu toolchain, we need gnu m4
remote_install 'gnu-m4' do
  source 'http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz'
  checksum '3ce725133ee552b8b4baca7837fb772940b25e81b2a9dc92537aeaf733538c9e'
  version '1.4.17'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/m4')
  end
end

remote_install 'gnu-autoconf' do
  source 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz'
  checksum '954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969'
  version '2.69'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/autoconf')
  end
end

remote_install 'gnu-texinfo' do
  source 'http://ftp.gnu.org/gnu/texinfo/texinfo-5.2.tar.gz'
  checksum '6b8ca30e9b6f093b54fe04439e5545e564c63698a806a48065c0bba16994cf74'
  version '5.2'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/makeinfo')
  end
end

remote_install 'gnu-gmp' do
  source 'http://mirrors.kernel.org/gnu/gmp/gmp-5.1.3.tar.gz'
  checksum '71f37fe18b7eaffd0700c0d3c5062268c3933c7100c29f944b81d2b6e9f78527'
  version '5.1.3'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/lib/libgmp.so')
  end
end

remote_install 'mpfr' do
  source 'http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.gz'
  checksum '176043ec07f55cd02e91ee3219db141d87807b322179388413a9523292d2ee85'
  version '3.1.2'
  build_command './configure  --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/lib/libmpfr.so')
  end
end

remote_install 'gnu-mpc' do
  source 'ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.2.tar.gz'
  checksum 'b561f54d8a479cee3bc891ee52735f18ff86712ba30f036f8b8537bae380c488'
  version '1.0.2'
  build_command './configure  --with-gmp-include=/usr/local/include --with-gmp-lib=/usr/local/lib --with-mpfr-include=/usr/local/include --with-mpfr-lib=/usr/local/lib'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/lib/libmpc.so')
  end
end

remote_install 'gnu-binutils' do
  source 'http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz'
  checksum '4930b2886309112c00a279483eaef2f0f8e1b1b62010e0239c16b22af7c346d4'
  version '2.24'
  build_command './configure --with-gmp=/usr/local --with-mpc=/usr/local --with-mpfr=/usr/local --disable-werror'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/ld')
  end
end

# Build gcc per the instructions that gnu provides for building on solaris 10.
remote_install 'gnu-gcc' do
  source 'http://ftp.gnu.org/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.gz'
  checksum '51c3be8eb5f029929f05117c15c77be2d2f4290eb3c3edbdb54a59a5cd58bf0f'
  version '4.9.1'
  build_command './configure --with-gmp=/usr/local --with-mpc=/usr/local --with-mpfr=/usr/local --enable-languages=c,c++ --with-gnu-as --with-as=/usr/sfw/bin/gas --without-gnu-ld --with-ld=/usr/ccs/bin/ld'
  compile_command 'make'
  install_command 'make install'
  environment solaris_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/gcc')
  end
end

# we need to add /usr/local/lib to the library path (permanently) so later builds have the needed libraries
bash 'update_crle_local_lib' do
  code <<-EOH
  crle -64 -u -l /usr/local/lib/amd64
  EOH
  not_if 'crle -64 | grep /usr/local/lib/amd64'
end
# also /usr/sfw/lib
bash 'update_crle_sfw' do
  code <<-EOH
  crle -64 -u -l /usr/sfw/lib/amd64
  EOH
  not_if 'crle -64 | grep /usr/sfw/lib/amd64'
end

ruby_block 'set_environment' do
  block do
    ENV['GREP'] = 'ggrep'
    ENV['CC'] = '/usr/local/bin/gcc -m64'
    ENV['CXX'] = '/usr/local/bin/g++ -m64'
    ENV['LD'] = 'ld -64'
  end
end

new_toolchain_env =
{ 'GREP' => 'ggrep',
  'CC' => '/usr/local/bin/gcc -m64',
  'CXX' => '/usr/local/bin/g++ -m64',
  'LD' => '/usr/local/bin/ld -64',
  'LD_LIBRARY_PATH' => '/usr/local/lib/amd64:/usr/local/lib:/usr/sfw/lib/amd64:/usr/sfw/lib',
}

# openssl is pretty damn old... we need to update it.
remote_install 'openssl' do
  source 'https://www.openssl.org/source/openssl-0.9.8zc.tar.gz'
  checksum '461cc694f29e72f59c22e7ea61bf44671a5fc2f8b3fc2eeac89714b7be915881'
  version '0.9.8zc'
  build_command './Configure --prefix=/usr/local solaris64-x86_64-gcc shared'
  compile_command 'make'
  install_command 'make install'
  environment new_toolchain_env
  not_if do
    File.exist?('/usr/local/bin/openssl')
  end
end

remote_file '/usr/local/ssl/cert.pem' do
  source 'http://curl.haxx.se/ca/cacert.pem'
end
