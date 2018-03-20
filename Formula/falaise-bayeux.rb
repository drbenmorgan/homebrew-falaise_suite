class FalaiseBayeux < Formula
  desc "Core C++ Framework Library for SuperNEMO Experiment"
  homepage "https://github.com/supernemo-dbd/bayeux"
  url "https://github.com/SuperNEMO-DBD/Bayeux/archive/3.1.2.tar.gz"
  sha256 "2bf6b887e654fadbb7373fbea550ec14adc8836758fb029bf56c76bb5177827d"

  patch :DATA

  depends_on "cmake" => :build
  depends_on "readline"
  depends_on "gsl"
  depends_on "art-boost"
  depends_on "art-clhep"
  depends_on "art-root6"
  depends_on "falaise-camp"

  needs :cxx14

  def install
    mkdir "bayeux.build" do
      bx_cmake_args = std_cmake_args
      bx_cmake_args << "-DCMAKE_INSTALL_LIBDIR=lib"
      bx_cmake_args << "-DBAYEUX_CXX_STANDARD=14"
      bx_cmake_args << "-DBAYEUX_COMPILER_ERROR_ON_WARNING=OFF"
      bx_cmake_args << "-DBAYEUX_WITH_DOCS=OFF"
      bx_cmake_args << "-DBAYEUX_WITH_GEANT4_MODULE=OFF"
      bx_cmake_args << "-DBAYEUX_WITH_QT_GUI=OFF"
      bx_cmake_args << "-DBAYEUX_ENABLE_TESTING=ON" if build.devel?

      system "cmake", "..", *bx_cmake_args
      system "make", "install"
    end
  end

  test do
    false
  end
end

__END__
diff --git a/cmake/LPCCMakeSettings.cmake b/cmake/LPCCMakeSettings.cmake
index 6f88d916..bbbd40ce 100644
--- a/cmake/LPCCMakeSettings.cmake
+++ b/cmake/LPCCMakeSettings.cmake
@@ -422,6 +422,8 @@ if(${PROJECT_NAME_UC}_CXX_STANDARD EQUAL 14)
 
   list(APPEND ${PROJECT_NAME_UC}_CXX_COMPILE_FEATURES
     ${${PROJECT_NAME_UC}_CXX11_COMPILE_FEATURES}
-    ${${PROJECT_NAME_UC}_PROJECT_CXX14_COMPILE_FEATURES}
+    ${${PROJECT_NAME_UC}_CXX14_COMPILE_FEATURES}
     )
 endif()
+
+message(STATUS "${${PROJECT_NAME_UC}_CXX_COMPILE_FEATURES}")
diff --git a/source/CMakeLists.txt b/source/CMakeLists.txt
index a59e669d..85cc3914 100644
--- a/source/CMakeLists.txt
+++ b/source/CMakeLists.txt
@@ -46,6 +46,63 @@ find_package(Boost ${BAYEUX_BOOST_MIN_VERSION}
   REQUIRED
   ${BAYEUX_BOOST_COMPONENTS}
   )
+# Reconstitute imported targets
+if(Boost_FOUND AND (CMAKE_VERSION VERSION_LESS "3.11") AND (NOT _Boost_IMPORTED_TARGETS))
+  # Find boost will already have created Boost::boost for us.
+  foreach(COMPONENT ${BAYEUX_BOOST_COMPONENTS})
+    if(NOT TARGET Boost::${COMPONENT})
+      string(TOUPPER ${COMPONENT} UPPERCOMPONENT)
+      if(Boost_${UPPERCOMPONENT}_FOUND)
+        if(Boost_USE_STATIC_LIBS)
+          add_library(Boost::${COMPONENT} STATIC IMPORTED)
+        else()
+          # Even if Boost_USE_STATIC_LIBS is OFF, we might have static
+          # libraries as a result.
+          add_library(Boost::${COMPONENT} UNKNOWN IMPORTED)
+        endif()
+        if(Boost_INCLUDE_DIRS)
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
+        endif()
+        if(EXISTS "${Boost_${UPPERCOMPONENT}_LIBRARY}")
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
+            IMPORTED_LOCATION "${Boost_${UPPERCOMPONENT}_LIBRARY}")
+        endif()
+        if(EXISTS "${Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE}")
+          set_property(TARGET Boost::${COMPONENT} APPEND PROPERTY
+            IMPORTED_CONFIGURATIONS RELEASE)
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
+            IMPORTED_LOCATION_RELEASE "${Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE}")
+        endif()
+        if(EXISTS "${Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG}")
+          set_property(TARGET Boost::${COMPONENT} APPEND PROPERTY
+            IMPORTED_CONFIGURATIONS DEBUG)
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
+            IMPORTED_LOCATION_DEBUG "${Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG}")
+        endif()
+        if(_Boost_${UPPERCOMPONENT}_DEPENDENCIES)
+          unset(_Boost_${UPPERCOMPONENT}_TARGET_DEPENDENCIES)
+          foreach(dep ${_Boost_${UPPERCOMPONENT}_DEPENDENCIES})
+            list(APPEND _Boost_${UPPERCOMPONENT}_TARGET_DEPENDENCIES Boost::${dep})
+          endforeach()
+          if(COMPONENT STREQUAL "thread")
+            list(APPEND _Boost_${UPPERCOMPONENT}_TARGET_DEPENDENCIES Threads::Threads)
+          endif()
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            INTERFACE_LINK_LIBRARIES "${_Boost_${UPPERCOMPONENT}_TARGET_DEPENDENCIES}")
+        endif()
+        if(_Boost_${UPPERCOMPONENT}_COMPILER_FEATURES)
+          set_target_properties(Boost::${COMPONENT} PROPERTIES
+            INTERFACE_COMPILE_FEATURES "${_Boost_${UPPERCOMPONENT}_COMPILER_FEATURES}")
+        endif()
+      endif()
+    endif()
+  endforeach()
+endif()
+
 
 foreach(_boost_lib ${BAYEUX_BOOST_COMPONENTS})
   list(APPEND Bayeux_Boost_LIBRARIES Boost::${_boost_lib})


