################################################################################################################
##### External Global Args Declaration and Defaults
################################################################################################################
# Any args that will need to be set, first declare them here, then later redeclare them within stage that uses.
# Also, for those with defaults, set those up here so that's easier to find.

# Swap or override this as needed (below are the "standard" types from
#   https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#default-and-custom-configurations)
ARG DOCKER_INTERNAL_REGISTRY \
    #NGEN_BUILD_CONFIG_TYPE="Debug" \
    NGEN_BUILD_CONFIG_TYPE="Release" \
    #NGEN_BUILD_CONFIG_TYPE="RelWithDebInfo" \
    #NGEN_BUILD_CONFIG_TYPE="MinSizeRel" \
    DATASET_DIRECTORIES="config forcing hydrofabric observation output" 
ARG REPO_URL=https://github.com/NOAA-OWP/ngen.git \
    BRANCH=master \
    COMMIT \
    WORKDIR=/ngen \
    TROUTE_REPO_URL=https://github.com/NOAA-OWP/t-route.git \
    TROUTE_BRANCH=master \
    TROUTE_COMMIT \
#### Default arguments for required dependencies needed during various build stages
# The Rocky-Linux-based "base" stage, rocky-base
    ROCKY_BASE_REQUIRED="sudo bash git" \
# The Rocky-Linux-based "ngen-deps" stage, rocky-ngen-deps
# TODO: later look at separating build and run images again, and install static lib netcdf packages in run images
#ARG ROCKY_NGEN_DEPS_REQUIRED="mpich mpich-devel sudo gcc gcc-c++ make cmake tar git gcc-gfortran libgfortran \
#    python39 python39-devel python39-pip python39-numpy \
#    netcdf-cxx4-devel netcdf-cxx4-mpich-devel netcdf-fortran-devel netcdf-fortran-mpich-devel \
#    hdf5 hdf5-devel hdf5-mpich hdf5-mpich-devel \
#    bzip2 expat expat-devel flex bison udunits2 udunits2-devel"
    ROCKY_NGEN_DEPS_REQUIRED="sudo gcc gcc-c++ make cmake tar git gcc-gfortran libgfortran \
    python3 python3-devel python3-pip gdal gdal-devel\
    bzip2 expat expat-devel flex bison udunits2 udunits2-devel zlib-devel" \
# TODO: removed texinfo from list because it couldn't be found; make sure this doesn't lead to issues
    BOOST_VERSION=1.72.0 \
#TODO Try mpich 4.x for native arm build support (https://raw.githubusercontent.com/pmodels/mpich/v4.1.1/CHANGES)
#mpich 3.2 doesn't work well gfortran 11 it seems, an alignment error crops up, but 3.3.2 seems to work...
    MPICH_VERSION="3.3.2" \
    MIN_PYTHON="3.8.0" \
    MIN_NUMPY="1.18.0" \
    NETCDF_C_VERSION=4.8.1 \
    NETCDF_CXX_VERSION=4.3.1 \
    NETCDF_FORTRAN_VERSION=4.6.0 \
    HD5_VERSION=1.10.9 \
    BLOSC2_VERSION=v2.2.0 \
    FCFLAGS="-w -fallow-argument-mismatch -O2" \
    FFLAGS="-w -fallow-argument-mismatch -O2" \
    MPICH_CONFIGURE_OPTIONS="" \
    MPICH_MAKE_OPTIONS \
    NGEN_ACTIVATE_C="ON" \
    NGEN_ACTIVATE_FORTRAN="ON" \
    NGEN_ACTIVATE_PYTHON="ON" \
    NGEN_NETCDF_ACTIVE="ON" \
    NGEN_ROUTING_ACTIVE="ON" \
    NGEN_UDUNITS_ACTIVE="ON" \
    NGEN_UDUNITS_QUIET="ON" \
    BUILD_NGEN_SERIAL="true" \
    BUILD_NGEN_PARALLEL="true" \
    BUILD_NGEN_PARTITIONER="true" \
    BUILD_NOAH_OWP="true" \
    BUILD_CFE="true" \
    BUILD_TOPMODEL="true" \
    BUILD_PET="true" \
    BUILD_SLOTH="true" 

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for Rocky-Linux-based "base"
FROM rockylinux:9.1 as rocky-base

#USER=root

ARG ROCKY_BASE_REQUIRED \
    WORKDIR=/ngen 
RUN dnf update -y \
    && dnf install -y 'dnf-command(config-manager)' \
    && dnf config-manager --set-enabled crb \
    && dnf install -y epel-release \
    && dnf -y install ${ROCKY_BASE_REQUIRED} 
    # Note that adduser -p expects an encrypted/hashed password, so it will ignore a simple password \
    # Config SSH Daemon \
    # Unlock non-password USER to enable SSH login \
    #&& passwd -u ${USER} 




# Switch back to default user when continue the build process

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for downloading Boost
FROM rockylinux:9.1 AS download_boost

# Redeclaring inside this stage to get default from before first FROM
ARG BOOST_VERSION

RUN curl -L -o boost_${BOOST_VERSION//./_}.tar.bz2 https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION//./_}.tar.bz2/download \
    && mkdir /boost \
    && mv boost_${BOOST_VERSION//./_}.tar.bz2 /boost/.

################################################################################################################
##https://support.hdfgroup.org/ftp/HDF5/releases##############################################################################################################
##### Create intermediate Docker build stage for downloading MPICH
FROM rockylinux:9.1 AS download_mpich

# Redeclaring inside this stage to get default from before first FROM
ARG MPICH_VERSION

RUN curl -o /tmp/mpich-${MPICH_VERSION}.tar.gz https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz


################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for downloading MPICH
FROM rockylinux:9.1 AS download_hd5

# Redeclaring inside this stage to get default from before first FROM
ARG HD5_VERSION

RUN curl -o /tmp/hdf5-${HD5_VERSION}.tar.gz https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-${HD5_VERSION}/src/hdf5-${HD5_VERSION}.tar.gz

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for downloading netcdf
FROM rocky-base AS download_netcdf

# Redeclaring inside this stage to get default from before first FROM
ARG NETCDF_C_VERSION

RUN if [[ "${NETCDF_C_VERSION}" == "latest" ]]; then \
            curl -s https://api.github.com/repos/Unidata/netcdf-c/releases/latest \
                | grep "tarball_url" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz ; \
        else \
            curl -s https://api.github.com/repos/Unidata/netcdf-c/releases \
                | grep "tarball_url" \
                | grep "${NETCDF_C_VERSION}" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz ; \
        #fi \
        #&& mkdir /tmp/netcdf \
        #&& tar -xzf /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz -C /tmp/netcdf --strip 1 \
        #&& rm /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz
        fi

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for downloading netcdf-fortran
FROM rocky-base AS download_netcdf_fortran

# Redeclaring inside this stage to get default from before first FROM
ARG NETCDF_FORTRAN_VERSION

RUN if [[ "${NETCDF_FORTRAN_VERSION}" == "latest" ]]; then \
            curl -s https://api.github.com/repos/Unidata/netcdf-fortran/releases/latest \
                | grep "tarball_url" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz ; \
        else \
            curl -s https://api.github.com/repos/Unidata/netcdf-fortran/releases \
                | grep "tarball_url" \
                | grep "${NETCDF_FORTRAN_VERSION}" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz ; \
        #fi \
        #&& mkdir /tmp/netcdf-fortran \
        #&& tar -xzf /tmp/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz -C /tmp/netcdf-fortran --strip 1 \
        #&& rm /tmp/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz
        fi

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for downloading NetCDF C++
FROM rocky-base AS download_netcdf_cxx

# Redeclaring inside this stage to get default from before first FROM
ARG NETCDF_CXX_VERSION

RUN if [[ "${NETCDF_CXX_VERSION}" == "latest" ]]; then \
            curl -s https://api.github.com/repos/Unidata/netcdf-cxx4/releases/latest \
                | grep "tarball_url" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz ; \
        else \
            curl -s https://api.github.com/repos/Unidata/netcdf-cxx4/releases \
                | grep "tarball_url" \
                | grep "${NETCDF_CXX_VERSION}" \
                | cut -d '"' -f 4 \
                | xargs curl -L -o /tmp/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz ; \
        #fi \
        #&& mkdir /tmp/netcdf-cxx4 \
        #&& tar -xzf /tmp/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz -C /tmp/netcdf-cxx4 --strip 1 \
        #&& rm /tmp/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz
        fi
    # This URL might also work for the analogous version:
    #   https://downloads.unidata.ucar.edu/netcdf-cxx/4.3.1/netcdf-cxx4-4.3.1.tar.gz
################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for just prior to "ngen-deps" for installing packaged deps
FROM rocky-base as rocky-ngen-packaged-deps

ARG ROCKY_NGEN_DEPS_REQUIRED

# Note that this includes numpy, which is needed for Python BMI support, regardless of BMI module 
#USER root
RUN dnf update -y && dnf install -y ${ROCKY_NGEN_DEPS_REQUIRED} \
    && pip3 install --upgrade pip \
    && if [ "${NGEN_ACTIVATE_PYTHON}" == "ON" ]; then pip3 install numpy; fi
#USER ${USER}

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for Rocky-Linux-based "ngen-deps"
FROM rocky-ngen-packaged-deps as rocky-ngen-deps

#USER root
ARG BOOST_VERSION \
    WORKDIR  \
    MPICH_VERSION \
    MIN_PYTHON \
    MIN_NUMPY \
    ROCKY_NGEN_DEPS_REQUIRED \
    MPICH_CONFIGURE_OPTIONS \
    MPICH_MAKE_OPTIONS \
    HD5_VERSION \
    NETCDF_C_VERSION \
    NETCDF_CXX_VERSION \
    NETCDF_FORTRAN_VERSION 

ENV WORKDIR=${WORKDIR} \
    BOOST_ROOT=${WORKDIR}/boost \
    MPICH_CONFIGURE_OPTIONS=${MPICH_CONFIGURE_OPTIONS} \
    MPICH_MAKE_OPTIONS=${MPICH_MAKE_OPTIONS} \
    HD5_VERSION=${HD5_VERSION} \
    NETCDF_C_VERSION=${NETCDF_C_VERSION} \
    NETCDF_CXX_VERSION=${NETCDF_CXX_VERSION} \
    NETCDF_FORTRAN_VERSION=${NETCDF_FORTRAN_VERSION} \
    HYDRA_HOST_FILE=/etc/opt/hosts

COPY --from=download_boost /boost ${WORKDIR}/boost 
COPY --from=download_mpich /tmp/mpich-${MPICH_VERSION}.tar.gz /tmp/ngen-deps/mpich-${MPICH_VERSION}.tar.gz  
COPY --from=download_hd5 /tmp/hdf5-${HD5_VERSION}.tar.gz /tmp/ngen-deps/hdf5-${HD5_VERSION}.tar.gz 
COPY --from=download_netcdf /tmp/netcdf-${NETCDF_C_VERSION}.tar.gz /tmp/ngen-deps/netcdf-${NETCDF_C_VERSION}.tar.gz 
COPY --from=download_netcdf_cxx /tmp/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz /tmp/ngen-deps/netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz 
COPY --from=download_netcdf_fortran /tmp/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz /tmp/ngen-deps/netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz

RUN pip3 install --upgrade pip \
    && pip3 install -t /ngen numpy pandas pyyaml bmipy Cython netCDF4 wheel packaging opencv-contrib-python-headless \
    # Hostfile location for mpirun. This file will be updated automatically.
    && echo "export HYDRA_HOST_FILE=${HYDRA_HOST_FILE}" >> /etc/profile \
    && touch ${HYDRA_HOST_FILE} \
    ################### Build and install dependencies from source ################### \
    ##### Prep temp build root directory \
    && mkdir -p /tmp/ngen-deps \
    ##### Build and install mpich \
    && cd /tmp/ngen-deps \
    && tar xfz mpich-${MPICH_VERSION}.tar.gz  \
    && cd mpich-${MPICH_VERSION} \
    # mpich3 and gfortran > 10 don't get along...https://gcc.gnu.org/bugzilla/show_bug.cgi?id=91731
    && FFLAGS="-w -fallow-argument-mismatch -O2" ./configure ${MPICH_CONFIGURE_OPTIONS} \
    && make -j $(nproc) ${MPICH_MAKE_OPTIONS} && make install \
    ##### Build and install HDF5 \
    && cd /tmp/ngen-deps \
    && tar -xzf hdf5-${HD5_VERSION}.tar.gz \
    && cd hdf5-${HD5_VERSION} \
    && ./configure --enable-parallel --prefix=/usr \
    && make -j $(nproc) && make install \
    ##### Build and install NetCDF C \
    && cd /tmp/ngen-deps \
    && mkdir netcdf \
    && tar -xzf netcdf-${NETCDF_C_VERSION}.tar.gz -C netcdf --strip 1 \
    && cd netcdf \
    && LIBS=curl && ./configure --prefix=/usr \
    && make -j $(nproc) && make install \
    # TODO: if we run into any problem, might need to reactivate this \
    #&& make check \
    ##### Build and install NetCDF Fortran \
    && cd /tmp/ngen-deps \
    && mkdir netcdf-fortran \
    && tar -xzf netcdf-fortran-${NETCDF_FORTRAN_VERSION}.tar.gz -C netcdf-fortran --strip 1 \
    && cd netcdf-fortran \
    && export NCDIR=/usr NFDIR=/usr \
    && LD_LIBRARY_PATH=/usr/lib CPPFLAGS=-I/usr/include LDFLAGS=-L/usr/lib ./configure --prefix=/usr \
    && make -j $(nproc) \ 
    && make install \
    ##### Build and install NetCDF C++ 
    && cd /tmp/ngen-deps \
    && mkdir netcdf-cxx4 \
    && tar -xzf netcdf-cxx4-${NETCDF_CXX_VERSION}.tar.gz -C netcdf-cxx4 --strip 1 \
    && mkdir netcdf-cxx4/build \
    && cd netcdf-cxx4/build \
    && ../configure --enable-parallel --prefix=/usr \
    && cmake .. \
    && make \
    # TODO: if we run into any problem, might need to reactivate this \
    #&& ctest \
    && make install \
    # Install required python dependency packages with Pip \
    # Except blosc2, since packaged wheels on pypi seem to have some issues, build it ourselves
    && cd /tmp/ngen-deps \
    && git clone https://github.com/Blosc/python-blosc2/ \
    && cd python-blosc2 \
    #checkout a release tag
    && git checkout ${BLOSC2_VERSION} \ 
    && git submodule update --init --recursive \
    && python3 -m pip install -r requirements-build.txt \
    && pip3 install . \
    && pip3 install numpy pandas pyyaml bmipy Cython netCDF4 wheel packaging \
    && HDF5_DIR=/usr pip3 install -v --no-build-isolation tables \
    # Make aliases for convenience \
    && alias pip='pip3' \
    && echo "alias pip='pip3'" >> /etc/profile \
    && alias python='python3'  \
    && echo "alias python='python3'" >> /etc/profile \
    # Also set up boost here, since we copied the download but only just installed bzip2 to work with it \
    && cd ${BOOST_ROOT} \
    && tar -xjf boost_${BOOST_VERSION//./_}.tar.bz2 \
    && rm boost_${BOOST_VERSION//./_}.tar.bz2 \
    && rm -rf /tmp/ngen-deps 

ENV PATH=${PATH}:/usr/lib64/mpich/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib:/usr/local/lib64

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for building t-route in Rocky Linux environment
FROM rocky-base as rocky_init_troute_repo
ARG TROUTE_REPO_URL \
    TROUTE_BRANCH \
    TROUTE_COMMIT \
    WORKDIR \
    UPDATE=2023-04-26

WORKDIR ${WORKDIR}

RUN cd ${WORKDIR} \
    && git clone --single-branch --branch $TROUTE_BRANCH $TROUTE_REPO_URL \
    && cd ./t-route \
    && if [ "x$TROUTE_COMMIT" != "x" ]; then git checkout $TROUTE_COMMIT; fi \
    && git submodule update --init

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for building framework in Rocky Linux environment
FROM rocky-base as rocky_init_repo
ARG REPO_URL \
    BRANCH \
    COMMIT \
    WORKDIR \
    UPDATE=2023-04-27

WORKDIR ${WORKDIR}

RUN cd ${WORKDIR} \
    && if [ "x$COMMIT" != "x" ]; then \
        git clone --single-branch --branch $BRANCH $REPO_URL \
        && cd ./ngen \
        && git checkout $COMMIT; \
    else \
        git clone --depth 1 --branch $BRANCH $REPO_URL \
        && cd ./ngen ; \
    fi \
    && echo "#!/bin/bash" > build_sub \
    && echo "cmake -B \$1/cmake_build -DCMAKE_BUILD_TYPE=${NGEN_BUILD_CONFIG_TYPE} -S \$1" >> build_sub \
    && echo "cmake --build \$1/cmake_build" >> build_sub \
    #&& echo "cd \$1/cmake_build && make install" >> build_sub \
    && chmod u+x build_sub \
    && git submodule update --init --depth 1 test/googletest \
    && git submodule update --init --recursive --depth 1

################################################################################################################
################################################################################################################
FROM rocky-ngen-deps as rocky_ngen_build_testing

COPY --chown=${USER} --from=rocky_init_repo ${WORKDIR}/ngen ${WORKDIR}/ngen
ENV BOOST_ROOT=${WORKDIR}/boost
WORKDIR ${WORKDIR}/ngen

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for building t-route in Rocky Linux environment
FROM rocky-ngen-deps as rocky_build_troute

ARG REPO_URL \
    BRANCH \
    COMMIT

COPY --chown=root --from=rocky_init_troute_repo ${WORKDIR}/t-route ${WORKDIR}/t-route

RUN cp -s /usr/bin/python3 /usr/bin/python \
    #&& python(){ /usr/bin/python3 \$@; } && export -f python \
    && cd ${WORKDIR}/t-route \
    && mkdir wheels \
    && pip3 install -r ./requirements.txt \
    && pip3 install wheel deprecated dask pyarrow geopandas
    RUN export FC=gfortran NETCDF=/usr/include \
    && cd ${WORKDIR}/t-route \
    && ./compiler.sh \
    && cd ./src/troute-network \
    && python3 setup.py --use-cython bdist_wheel \
    && cp dist/*.whl ${WORKDIR}/t-route/wheels/ \
    && cd ../troute-routing \
    && python3 setup.py --use-cython bdist_wheel \
    && cp dist/*.whl ${WORKDIR}/t-route/wheels/ \
    && cd ../troute-nwm \
    && python3 setup.py bdist_wheel \
    && cp dist/*.whl ${WORKDIR}/t-route/wheels/ 

RUN rm /usr/bin/python

################################################################################################################
################################################################################################################
##### Create intermediate Docker build stage for building framework in Rocky Linux environment
FROM rocky-ngen-deps as rocky_build_ngen

ARG REPO_URL \
    BRANCH \
    COMMIT \
    NGEN_BUILD_CONFIG_TYPE \
    NGEN_ACTIVATE_C \
    NGEN_ACTIVATE_FORTRAN \
    NGEN_ACTIVATE_PYTHON \
    NGEN_NETCDF_ACTIVE \
    NGEN_ROUTING_ACTIVE \
    NGEN_UDUNITS_ACTIVE \
    NGEN_UDUNITS_QUIET \
    BUILD_NGEN_SERIAL \
    BUILD_NGEN_PARALLEL \
    BUILD_NGEN_PARTITIONER \
    BUILD_NOAH_OWP \
    BUILD_CFE \
    BUILD_TOPMODEL \
    BUILD_PET \
    BUILD_SLOTH

COPY --chown=${USER} --from=rocky_init_repo ${WORKDIR}/ngen ${WORKDIR}/ngen
COPY --chown=${USER} --from=rocky_build_troute ${WORKDIR}/t-route/wheels /tmp/t-route-wheels
COPY --chown=${USER} --from=rocky_build_troute ${WORKDIR}/t-route/requirements.txt /tmp/t-route-requirements.txt
ENV BOOST_ROOT=${WORKDIR}/boost

USER root
RUN if [ "${NGEN_ACTIVATE_PYTHON}" == "ON" ]; then \
        chgrp -R ${USER} /usr/local/lib*/python3.* ; \
        chmod -R g+sw /usr/local/lib*/python3.* ; \
    fi \
    && if [ "${NGEN_ROUTING_ACTIVE}" == "ON" ]; then \
        # These packages install command line tools, which try to go in /usr/local/bin \
        pip3 install pyarrow pyproj fiona; \
    fi
USER ${USER}

#These patches are from ngen commit 7551590a415b89026559c1c570d4154e4746161b
#and are needed to fix an I/O bug in the sub modules (and bmi tests) that cause an infinite loop
#https://github.com/NOAA-OWP/ngen/pull/515, https://github.com/NOAA-OWP/ngen/pull/518 both merged upstream, patch no longer needed
# All the affected submodules have patched/merged in their respective upstream repos, 
# but ngen submodules have not been updated to the current HEAD
# of all the submdoules, and that might prove difficult to do in the near future, but if that does happen,
# then this can be removed at that point.
COPY fix_io_sub_7551590a415b89026559c1c570d4154e4746161b.patch ${WORKDIR}/ngen/fix_io_sub.patch
# Apply the IO fix to submodules, once they all get patched/merged, this can be dropped...
RUN cd ${WORKDIR}/ngen && git apply --reject --whitespace=fix \
    #patch the submodules
    fix_io_sub.patch

RUN cd ${WORKDIR}/ngen \
    && if [ "${NGEN_ACTIVATE_PYTHON}" == "ON" ]; then \
        pip3 install -r extern/test_bmi_py/requirements.txt; \
        if [ "${NGEN_ROUTING_ACTIVE}" == "ON" ] ; then \
            pip3 install /tmp/t-route-wheels/*.whl; \
            pip3 install -r /tmp/t-route-requirements.txt; \
            pip3 install deprecated geopandas ; \
            fi; \
        fi \
    &&  if [ "${NGEN_ACTIVATE_FORTRAN}" == "ON" ]; then \
                ./build_sub extern/iso_c_fortran_bmi; \
                if [ "${BUILD_NOAH_OWP}" == "true" ] ; then ./build_sub extern/noah-owp-modular; fi; \
        fi \
    &&  if [ "${NGEN_ACTIVATE_C}" == "ON" ]; then \
                if [ "${BUILD_CFE}" == "true" ] ; then ./build_sub extern/cfe; fi; \
                if [ "${BUILD_PET}" == "true" ] ; then ./build_sub extern/evapotranspiration/evapotranspiration; fi; \
                if [ "${BUILD_TOPMODEL}" == "true" ] ; then ./build_sub extern/topmodel; fi; \
        fi \
    && if [ "${BUILD_SLOTH}" == "true" ] ; then ./build_sub extern/sloth; fi \
    && if [ "${BUILD_NGEN_SERIAL}" == "true" ]; then \
        cmake -B cmake_build_serial -S . \
        -DMPI_ACTIVE:BOOL=OFF \
        -DNETCDF_ACTIVE:BOOL=${NGEN_NETCDF_ACTIVE} \
        -DBMI_C_LIB_ACTIVE:BOOL=${NGEN_ACTIVATE_C} \
        -DBMI_FORTRAN_ACTIVE:BOOL=${NGEN_ACTIVATE_FORTRAN} \
        -DNGEN_ACTIVATE_PYTHON:BOOL=${NGEN_ACTIVATE_PYTHON} \
        -DNGEN_ACTIVATE_ROUTING:BOOL=${NGEN_ROUTING_ACTIVE} \
        -DUDUNITS_ACTIVE:BOOL=${NGEN_UDUNITS_ACTIVE} \
        -DUDUNITS_QUIET:BOOL=${NGEN_UDUNITS_QUIET} \
        -DCMAKE_INSTALL_PREFIX=${WORKDIR} \
        -DNETCDF_INCLUDE_DIR=/usr/include \
        -DNETCDF_LIBRARY=/usr/lib/libnetcdf.so \
        -DNETCDF_CXX_INCLUDE_DIR=/usr/local/include \
        -DNETCDF_CXX_LIBRARY=/usr/local/lib64/libnetcdf-cxx4.so ; \
    fi \
    && if [ "${BUILD_NGEN_PARALLEL}" == "true" ]; then \
        cmake -B cmake_build_parallel -S . \
        -DMPI_ACTIVE:BOOL=ON \
        -DNETCDF_ACTIVE:BOOL=${NGEN_NETCDF_ACTIVE} \
        -DBMI_C_LIB_ACTIVE:BOOL=${NGEN_ACTIVATE_C} \
        -DBMI_FORTRAN_ACTIVE:BOOL=${NGEN_ACTIVATE_FORTRAN} \
        -DNGEN_ACTIVATE_PYTHON:BOOL=${NGEN_ACTIVATE_PYTHON} \
        -DNGEN_ACTIVATE_ROUTING:BOOL=${NGEN_ROUTING_ACTIVE} \
        -DUDUNITS_ACTIVE:BOOL=${NGEN_UDUNITS_ACTIVE} \
        -DUDUNITS_QUIET:BOOL=${NGEN_UDUNITS_QUIET} \
        -DCMAKE_INSTALL_PREFIX=${WORKDIR} \
        -DNETCDF_INCLUDE_DIR=/usr/include \
        -DNETCDF_LIBRARY=/usr/lib/libnetcdf.so \
        -DNETCDF_CXX_INCLUDE_DIR=/usr/local/include \
        -DNETCDF_CXX_LIBRARY=/usr/local/lib64/libnetcdf-cxx4.so ; \
    fi \
    && ln -s $(if [ "${BUILD_NGEN_PARALLEL}" == "true" ]; then echo "cmake_build_parallel"; else echo "cmake_build_serial"; fi) cmake_build \
    # Build the required submodules/external libs needed for running the tests later \
    # C++ functionality isn't separate, so always build the test_bmi_cpp shared lib (also needed for test_bmi_multi) \
    && ./build_sub extern/test_bmi_cpp \
    # For the external language BMI integrations, conditionally build the test packages/libraries and run tests \
    &&  if [ "${NGEN_ACTIVATE_C}" == "ON" ]; then \
            ./build_sub extern/test_bmi_c; \
        fi \
    &&  if [ "${NGEN_ACTIVATE_FORTRAN}" == "ON" ]; then \
            ./build_sub extern/test_bmi_fortran; \
        fi \
    &&  for BUILD_DIR in $(if [ "${BUILD_NGEN_PARALLEL}" == "true" ]; then echo "cmake_build_parallel"; fi) $(if [ "${BUILD_NGEN_SERIAL}" == "true" ]; then echo "cmake_build_serial"; fi) ; do \
        cmake --build $BUILD_DIR --target all -j $(nproc); \
    done \
    # run the serial tests \
    && cd ${WORKDIR}/ngen && cmake --build cmake_build_serial --target test \ 
    # have to remove the output from the previous tests runs for routing test to be run again... \
    && rm -f ./test/data/routing/*.parquet \
    # run the parallel tests \
    && cmake --build cmake_build_parallel --target test \
    # clean these up again... \
    && rm -f ./test/data/routing/*.parquet \
    #Run the MPI tests manually, they don't play well with ctest and are skipped in the above tests \
    && mpirun -n 2 cmake_build_parallel/test/test_remote_nexus \
    && mpirun -n 3 cmake_build_parallel/test/test_remote_nexus \
    && mpirun -n 4 cmake_build_parallel/test/test_remote_nexus \
    && find cmake_build* -type f -name "*" ! \( -name "*.so" -o -name "ngen" -o -name "partitionGenerator" \) -exec rm {} + 

################################################################################################################
################################################################################################################
##### Penultimate stage for image
FROM rocky_build_ngen as rocky_build_staging

ARG DATASET_DIRECTORIES

#RUN cd ./ngen && mkdir ${WORKDIR}/bin && cp cmake_build/ngen ${WORKDIR}/bin && cp -r data ${WORKDIR}/data \
#    && cd $WORKDIR && rm -rf ngen boost


# Remove the boost headers now that ngen is compiled; also update path and make sure dataset directory is there
RUN rm -rf ${BOOST_ROOT} && echo "export PATH=${PATH}" >> /etc/profile \
    && mkdir -p /dmod/datasets && chown root /dmod/datasets \
    && mkdir -p /dmod/datasets/static && chown root /dmod/datasets/static \
    && mkdir -p /dmod/shared_libs && chown root /dmod/shared_libs \
    && mkdir -p /dmod/bin && chown root /dmod/bin 

# Change permissions for entrypoint and make sure dataset volume mount parent directories exists
# chmod +x ${WORKDIR}/entrypoint.sh \
RUN for d in ${DATASET_DIRECTORIES}; do mkdir -p /dmod/datasets/${d}; done \
    && for d in iso_c_fortran_bmi noah-owp-modular topmodel cfe sloth 'evapotranspiration/evapotranspiration'; do \
        if [ -d ${WORKDIR}/ngen/extern/${d}/cmake_build ]; then \
            cp -a ${WORKDIR}/ngen/extern/${d}/cmake_build/*.so* /dmod/shared_libs/.; \
        fi; \
    done \
    && find ${WORKDIR}/ngen/extern/noah-owp-modular -type f -iname "*.TBL" -exec cp '{}' /dmod/datasets/static  \; \
    && ( cp -a ${WORKDIR}/ngen/cmake_build_parallel/ngen /dmod/bin/ngen-parallel || true ) \
    && ( cp -a ${WORKDIR}/ngen/cmake_build_serial/ngen /dmod/bin/ngen-serial || true ) \
    && ( cp -a ${WORKDIR}/ngen/cmake_build/partitionGenerator /dmod/bin/partitionGenerator || true ) \
    && pushd /dmod/bin \
    && ( ( stat ngen-parallel && ln -s ngen-parallel ngen ) || ( stat ngen-serial && ln -s ngen-serial ngen ) ) \
    && popd 

WORKDIR ${WORKDIR}
ENV PATH=${WORKDIR}:$PATH


################################################################################################################
##### Final stage for image
FROM rockylinux:9.1-minimal

########################################Copy over the NGEN artifacts############################################
COPY --chown=root --from=rocky_build_staging /dmod/ /dmod/
#COPY --chown=root --from=rocky_build_staging /usr/lib64/ /usr/lib64/
COPY --chown=root --from=rocky_build_staging /usr/ /usr/
########################################Relink the files########################################################
RUN echo "/dmod/shared_libs/" >> /etc/ld.so.conf.d/ngen.conf && ldconfig -v

COPY   HelloNGEN.sh /ngen/HelloNGEN.sh
RUN chown -R root /dmod /ngen /root
RUN chmod a+x /dmod/bin/* /ngen/HelloNGEN.sh /root
RUN rm -rf tmp var opt 
WORKDIR /ngen

ENTRYPOINT ["./HelloNGEN.sh"]
CMD [""]
