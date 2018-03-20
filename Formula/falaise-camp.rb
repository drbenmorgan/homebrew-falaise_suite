class FalaiseCamp < Formula
  desc "Tegesoft C++ reflection library"
  homepage "https://github.com/tegesoft/camp"
  url "https://github.com/drbenmorgan/camp.git", :revision => "7564e57f7b406d1021290cf2260334d57d8df255"
  version "0.8.0"

  needs :cxx14

  depends_on "cmake" => :build
  depends_on "art-boost"

  def install
    args = std_cmake_args
    args << "-DCMAKE_CXX_STANDARD=14"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system "false"
  end
end

