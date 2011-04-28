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
  find_package(ITK REQUIRED)
  include(${ITK_USE_FILE})
  find_package(BatchMake REQUIRED)
  include(${BatchMake_USE_FILE})
  find_package(GenerateCLP REQUIRED)
  if(GenerateCLP_FOUND)
    include(${GenerateCLP_USE_FILE})
  endif(GenerateCLP_FOUND)
ENDIF (Slicer3_FOUND)

#Find tools
find_program(RESAMPLEDTILOGEUCLIDEANTOOL ResampleDTIlogEuclidean )
if(NOT RESAMPLEDTILOGEUCLIDEANTOOL )
  message( WARNING "${RESAMPLEDTILOGEUCLIDEANTOOL} ResampleDTIlogEuclidean was not found on your system. ResampleDTI will be used instead")
endif(NOT RESAMPLEDTILOGEUCLIDEANTOOL )
find_program(RESAMPLEDTITOOL ResampleDTI )
find_program(REGISTERIMAGESTOOL RegisterImages )
find_program(COMPUTEORIENTATIONTOOL ManualImageOrient )
find_program(ITKTRANSFORMTOOLSTOOL ITKTransformTools )
find_program(RESAMPLEVOLUME2TOOL ResampleVolume2 )
find_program(DIFFUSIONTENSORESTIMATIONTOOL DiffusionTensorEstimation )
find_program(DTIESTIMTOOL dtiestim )
find_program(DTIPROCESSTOOL dtiprocess )
find_program(CREATEMRMLTOOL CreateMRML )
find_program(ImageMathTOOL ImageMath )
find_program(HistogramMatchingTOOL HistogramMatching )
find_program(MaskTOOL MaskComputationWithThresholding )
if( NOT MaskTOOL )
  message( WARNING "MaskTool not found. CMake external used to download it and compile it" )
  set( MaskTOOLext ON )
  set( MaskTOOL ${DWIResamplingSlicer3Module_BINARY_DIR}/bin/MaskComputationWithThresholding )
else( NOT MaskTOOL )
  set( MaskTOOLext OFF )
endif( NOT MaskTOOL )

# Configure a header
if(WIN32)
   set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
else(WIN32)
   set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR})
endif(WIN32)

configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/BatchMakeScript.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/BatchMakeScript.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Prepare.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Prepare.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Registration.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Registration.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/Transform.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/Transform.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/PostProcessing.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/PostProcessing.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/CreateMRMLScene.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/CreateMRMLScene.bms" COPYONLY )
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/MaskImage.bms.in"
      "${BatchMake_WRAPPED_APPLICATION_DIR}/MaskImage.bms" COPYONLY )
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

#FIND_PACKAGE(Subversion)
#IF(NOT Subversion_FOUND)
#  MESSAGE(FATAL_ERROR "error: Install SVN and try to re-configure")
#ENDIF()


#--------COMPILE DWIResamplingSlicer3Module AS STANDALONE PACKAGE--------
OPTION(COMPILE_EXTERNAL_PROJECTS "Compile External Projects." ON)
IF(COMPILE_EXTERNAL_PROJECTS)

  #External Projects
  include(ExternalProject)
  if(CMAKE_EXTRA_GENERATOR)
    set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(gen "${CMAKE_GENERATOR}")
  endif()
  OPTION(COMPILE_EXTERNAL_NEUROLib "Compile External NEUROLib" ON)
  IF(COMPILE_EXTERNAL_NEUROLib)
    # Build NeuroLib cvs -d :pserver:anonymous@demeter.ia.unc.edu:/cvsroot
    set(proj NeuroLib)
      ExternalProject_Add(${proj}
        CVS_REPOSITORY ":pserver:anonymous@demeter.ia.unc.edu:/cvsroot/"
        CVS_MODULE ${proj}
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCOMPILE_NeuroLib_LIBS:BOOL=OFF
          -DCOMPILE_ITKTransformTools:BOOL=ON
          -DUSE_ITK_LIBRARY:BOOL=ON
          -DCOMPILE_ResampleDTI-LogEuclidean:BOOL=ON
          -DCOMPILE_IMAGEMATH:BOOL=ON
          -DCOMPILE_NeuroLib_APPLICATIONS:BOOL=ON
          -DSTATIC_RESAMPLEDTI:BOOL=OFF
          -DSlicer3_FOUND:BOOL=TRUE
          -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
          -DSlicer3_DIR:PATH=${Slicer3_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_NEUROLib)
  OPTION(COMPILE_EXTERNAL_CreateMRML "Compile External CreateMRML" ON)
  IF(COMPILE_EXTERNAL_CreateMRML)
    set(proj CreateMRML)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/CreateMRML.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DSlicer3_FOUND:BOOL=TRUE
          -DSlicer3_USE_FILE:PATH=${Slicer3_USE_FILE}
          -DSlicer3_DIR:PATH=${Slicer3_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_CreateMRML)
  OPTION(COMPILE_EXTERNAL_dtiprocess "Compile External dtiprocessToolkit" ON)
  IF(COMPILE_EXTERNAL_dtiprocess)
    set(proj dtiprocessTK)
      ExternalProject_Add(${proj}
        SVN_REPOSITORY "https://www.nitrc.org/svn/dtiprocess/trunk"
        SVN_USERNAME slicerbot
        SVN_PASSWORD slicer
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DBUILD_TESTING:BOOL=OFF
 #         -DVTK_DIR:PATH=${VTK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
#          -DCMAKE_INSTALL_PREFIX:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}
#        INSTALL_DIR ${DWIResamplingSlicer3Module_BINARY_DIR}
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_dtiprocess)
  OPTION(COMPILE_EXTERNAL_ManualImageOrient "Compile External ManualImageOrient" ON)
  IF(COMPILE_EXTERNAL_ManualImageOrient)
    set(proj ManualImageOrient)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/ManualImageOrient.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_ManualImageOrient)
  OPTION(COMPILE_EXTERNAL_MaskComputationWithThresholding "Compile External MaskComputationWithThresholding" ${MaskTOOLext})
  IF(COMPILE_EXTERNAL_MaskComputationWithThresholding)
    set(proj MaskComputationWithThresholding)
      ExternalProject_Add(${proj}
        GIT_REPOSITORY "git://github.com/booboo69500/MaskComputationWithThresholding.git"
        SOURCE_DIR ${proj}
        BINARY_DIR ${proj}-build
        DEPENDS  ${ITK_DEPEND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS
          ${LOCAL_CMAKE_BUILD_OPTIONS}
          -DITK_DIR:PATH=${ITK_DIR}
          -DGenerateCLP_DIR:PATH=${GenerateCLP_DIR}
          -DModuleDescriptionParser_DIR:PATH=${ModuleDescriptionParser_DIR}
          -DTCLAP_DIR:PATH=${TCLAP_DIR}
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DEXECUTABLE_OUTPUT_PATH:PATH=${DWIResamplingSlicer3Module_BINARY_DIR}/bin
      INSTALL_COMMAND ""
      )
  ENDIF(COMPILE_EXTERNAL_MaskComputationWithThresholding)
ENDIF(COMPILE_EXTERNAL_PROJECTS)



