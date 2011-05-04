cmake_minimum_required(VERSION 2.8)
CMAKE_POLICY(VERSION 2.8)

project (DWIResamplingSlicer3Module)


IF(CMAKE_COMPILER_2005)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
ENDIF(CMAKE_COMPILER_2005)

IF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIResamplingSlicer3Module_SOURCE_DIR})
  SET (LIBRARY_OUTPUT_PATH ${DWIResamplingSlicer3Module_BINARY_DIR}/lib CACHE PATH "Single output directory for building all libraries.")
  SET (EXECUTABLE_OUTPUT_PATH ${DWIResamplingSlicer3Module_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
ENDIF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIResamplingSlicer3Module_SOURCE_DIR})

if( NOT NO_FIND )
  include( FindTools.cmake )
endif( NOT NO_FIND )

FIND_PACKAGE(Slicer3 QUIET NO_DEFAULT_PATH)
IF (Slicer3_FOUND)
  INCLUDE(${Slicer3_USE_FILE})
  slicer3_set_default_install_prefix_for_external_projects()
  if( NOT GenerateCLP_FOUND)
    message( FATAL_ERROR "GenerateCLP not found. Please set GenerateCLP_DIR. " )
  endif(NOT GenerateCLP_FOUND)
  if(NOT BatchMake_FOUND )
    message( FATAL_ERROR "BatchMake not found. Please set BatchMake_DIR. " )
  endif(NOT BatchMake_FOUND )
  if(NOT ITK_FOUND )
    message( FATAL_ERROR "ITK not found. Please set ITK_DIR. " )
  endif(NOT ITK_FOUND )
ELSE (Slicer3_FOUND)
  find_package(ITK REQUIRED PATH ${ITK_DIR} )
  include(${ITK_USE_FILE})
  find_package(BatchMake REQUIRED PATH ${BatchMake_DIR} )
  include(${BatchMake_USE_FILE})
  find_package(GenerateCLP REQUIRED PATH ${GenerateCLP_DIR} )
  if(GenerateCLP_FOUND)
    include(${GenerateCLP_USE_FILE})
  endif(GenerateCLP_FOUND)
ENDIF (Slicer3_FOUND)

# Configure a header

FILE( GLOB list_files ${CMAKE_CURRENT_SOURCE_DIR}/*.bms.in )
FILE( COPY ${list_files} DESTINATION ${EXECUTABLE_OUTPUT_PATH} )

configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/SlicerBatchMakeConfig.h.in"
      "${CMAKE_CURRENT_BINARY_DIR}/SlicerBatchMakeConfig.h")

# Set the name of the Slicer3 BatchMake module to be created
set(Slicer3BatchModule DWIResamplingSlicer3Module)

# Set the source code for the Slicer3 BatchMake module
set(Slicer3BatchModule_SOURCE DWIResamplingSlicer3Module.cxx)

generateclp(Slicer3BatchModule_SOURCE   ${Slicer3BatchModule}.xml )

#Do not compile as a library. We need the image files to be saved on the hard drive.
add_executable( ${Slicer3BatchModule} ${Slicer3BatchModule_SOURCE} )
target_link_libraries( ${Slicer3BatchModule} BatchMakeLib )

