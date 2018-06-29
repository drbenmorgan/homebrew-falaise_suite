class FalaiseGeant4 < Formula
  desc "C++ toolkit for simulating the passage of particles through matter"
  homepage "http://geant4.cern.ch"

  stable do
    url "http://geant4.cern.ch/support/source/geant4.10.04.p02.tar.gz"
    version "10.4.2"
    sha256 "2cac09e799f2eb609a7f1e4082d3d9d3d4d9e1930a8c4f9ecdad72aad35cdf10"
  end

  needs :cxx14

  depends_on "cmake" => :build
  depends_on "expat" if OS.linux?

  depends_on "art-clhep"
  depends_on "xerces-c"

  option "with-notimeout", "Set notimeout in installing data"

  def install
    ENV.cxx11
    mkdir "geant4-build" do
      args = std_cmake_args
      args << "-DCMAKE_INSTALL_LIBDIR=lib"
      args << "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
      args << "-DGEANT4_BUILD_CXXSTD=c++14"
      args << "-DGEANT4_INSTALL_DATA=ON"
      args << "-DGEANT4_INSTALL_DATA_TIMEOUT=86400" if build.with? "notimeout"
      args << "-DGEANT4_USE_SYSTEM_CLHEP=ON"
      args << "-DGEANT4_USE_SYSTEM_EXPAT=ON"
      args << "-DGEANT4_USE_GDML=ON"

      system "cmake", "../", *args
      system "make", "install"
    end
  end

  test do
    system "false"
  end
end
