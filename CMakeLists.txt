cmake_minimum_required(VERSION 2.8)
CMAKE_POLICY(VERSION 2.8)

project (DWIProcessPipeline-Gen)

set( CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/CMake" )

include( CMakeCommonExternalDefinitions )

IF(CMAKE_COMPILER_2005)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
ENDIF(CMAKE_COMPILER_2005)

IF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIProcessPipeline-Gen_SOURCE_DIR})
  SET (LIBRARY_OUTPUT_PATH ${DWIProcessPipeline-Gen_BINARY_DIR}/lib CACHE PATH "Single output directory for building all libraries.")
  SET (EXECUTABLE_OUTPUT_PATH ${DWIProcessPipeline-Gen_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
ENDIF (${CMAKE_SOURCE_DIR} STREQUAL ${DWIProcessPipeline-Gen_SOURCE_DIR})

if( NOT EXECUTABLE_OUTPUT_PATH )
  SET (EXECUTABLE_OUTPUT_PATH ${DWIProcessPipeline-Gen_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
  message( WARNING "EXECUTABLE_OUTPUT_PATH was not set. Set to ${DWIProcessPipeline-Gen_BINARY_DIR}/bin" )
endif( NOT EXECUTABLE_OUTPUT_PATH )

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
  include(ExternalProject)
  if(CMAKE_EXTRA_GENERATOR)
    set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(gen "${CMAKE_GENERATOR}")
  endif()
  PACKAGE_NEEDS_ITK( ${CMAKE_GENERATOR} )
  PACKAGE_NEEDS_BatchMake( ${CMAKE_GENERATOR} )
  PACKAGE_NEEDS_SlicerExecutionModel( ${CMAKE_GENERATOR} )
  mark_as_advanced( BUILD_SHARED_LIBS )
ENDIF (Slicer3_FOUND)

if( ${OPT_USE_SYSTEM_ITK} AND NOT ${ITK_USE_REVIEW} )
  set( OPT_USE_SYSTEM_ITK OFF )
  message( SEND_ERROR "ITK was compiled with ITK_USE_REVIEW set to off. Please recompile it setting this option to ON or set OPT_USE_SYSTEM_ITK to OFF" )
endif( ${OPT_USE_SYSTEM_ITK} AND NOT ${ITK_USE_REVIEW} )

include( Source/FindTools.cmake )

#External Projects
include(ExternalProject)
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}")
endif()

set(proj Source)
ExternalProject_Add(${proj}
  URL ${CMAKE_SOURCE_DIR}/Source/
  SOURCE_DIR ${proj}
  BINARY_DIR ${proj}-build
  DEPENDS  ${ITK_DEPEND} ${SlicerExecutionModel_DEPEND} ${BatchMake_DEPEND}
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${LOCAL_CMAKE_BUILD_OPTIONS}
    -DSlicer3_FOUND:BOOL=TRUE
    -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
    -DSlicer3_DIR:PATH=${Slicer3_DIR}
    -DITK_DIR:PATH=${ITK_DIR}
    -DBatchMake_DIR:PATH=${BatchMake_DIR}
    -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
    -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
    -DTCLAP_DIR:PATH=${TCLAP_DIR}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DEXECUTABLE_OUTPUT_PATH:PATH=${EXECUTABLE_OUTPUT_PATH}
    -DLIBRARY_OUTPUT_PATH:PATH=${LIBRARY_OUTPUT_PATH}
    -DRESAMPLEDTILOGEUCLIDEANTOOL:PATH=${RESAMPLEDTILOGEUCLIDEANTOOL}
    -DRESAMPLEDTITOOL:PATH=${RESAMPLEDTITOOL}
    -DREGISTERIMAGESTOOL:PATH=${REGISTERIMAGESTOOL}
    -DCOMPUTEORIENTATIONTOOL:PATH=${COMPUTEORIENTATIONTOOL}
    -DITKTRANSFORMTOOLSTOOL:PATH=${ITKTRANSFORMTOOLSTOOL}
    -DRESAMPLEVOLUME2TOOL:PATH=${RESAMPLEVOLUME2TOOL}
    -DDIFFUSIONTENSORESTIMATIONTOOL:PATH=${DIFFUSIONTENSORESTIMATIONTOOL}
    -DDTIESTIMTOOL:PATH=${DTIESTIMTOOL}
    -DDTIPROCESSTOOL:PATH=${DTIPROCESSTOOL}
    -DCREATEMRMLTOOL:PATH=${CREATEMRMLTOOL}
    -DImageMathTOOL:PATH=${ImageMathTOOL}
    -DHistogramMatchingTOOL:PATH=${HistogramMatchingTOOL}
    -DMaskTOOL:PATH=${MaskTOOL}
    -DN4TOOL:PATH=${N4TOOL}
    -DNO_FIND:BOOL=ON
  INSTALL_COMMAND ""
)
