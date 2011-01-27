cmake_minimum_required(VERSION 2.6)
project (DWIResamplingSlicer3Module)

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

# Set the name of the Slicer3 BatchMake module to be created
set(Slicer3BatchModule DWIResamplingSlicer3Module)

# Set the source code for the Slicer3 BatchMake module
set(Slicer3BatchModule_SOURCE DWIResamplingSlicer3Module.cxx)

  find_package(ITK REQUIRED)
  include(${ITK_USE_FILE})


  find_package(BatchMake REQUIRED)
  include(${BatchMake_USE_FILE})
  # Find GenerateCLP
  find_package(GenerateCLP REQUIRED)
  if(GenerateCLP_FOUND)
    include(${GenerateCLP_USE_FILE})
  endif(GenerateCLP_FOUND)
  # Disable MSVC 8 warnings
  if(WIN32)
    option(DISABLE_MSVC8_DEPRECATED_WARNINGS 
          "Disable Visual Studio 8 deprecated warnings" ON)
    mark_as_advanced(FORCE DISABLE_MSVC8_DEPRECATED_WARNINGS)  
    if(DISABLE_MSVC8_DEPRECATED_WARNINGS)
      add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
    endif(DISABLE_MSVC8_DEPRECATED_WARNINGS)
  endif(WIN32)
    if(WIN32)
      set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE})
    else(WIN32)
      set(BatchMake_WRAPPED_APPLICATION_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif(WIN32)


# Configure a header
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
configure_file( "${CMAKE_CURRENT_SOURCE_DIR}/SlicerBatchMakeConfig.h.in"
      "${CMAKE_CURRENT_BINARY_DIR}/SlicerBatchMakeConfig.h")

generateclp(Slicer3BatchModule_SOURCE 
            ${Slicer3BatchModule}.xml)


#Do not compile as a library. We need the image files to be saved on the hard drive.
add_executable(${Slicer3BatchModule} ${Slicer3BatchModule_SOURCE})
target_link_libraries(${Slicer3BatchModule} BatchMakeLib)

FIND_PACKAGE(Subversion)
IF(NOT Subversion_FOUND)
  MESSAGE(FATAL_ERROR "error: Install SVN and try to re-configure")
ENDIF()
