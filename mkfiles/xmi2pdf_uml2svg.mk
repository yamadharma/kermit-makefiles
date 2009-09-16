# autolatex - xmi2pdf_uml2svg.mk
# Copyright (C) 1998-09  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

ifeq ("$(call isTranslatorLoaded,xmi2pdf)","false")

# If the images must be auto-generated, the following lines
# permits to change the generators
#   xxx_BIN is the command to launch
#   xxx_FLAGS are the command line options to pass to the converter
#   xxx_INPUT_FLAGS are the options which must appear just before
#                   then input filename
#   xxx_OUTPUT_FLAGS are the options which must appear just before
#                    then input filename
#   xxx_POST_FLAGS are the options which must appear just after
#                  all the rest
#   xxx_OUTPUT_INPUT switch the order of the output options and the
#                    input option. If set to yes, the output options
#                    will appear before the input options. if set to
#                    no, the input options will appear before the
#                    output options.
#   xxx_OUTPUT_STDOUT if set to yes, the output options will be ignored
#                     and the command's standard output will be sent
#                     to the target file.


# Command definition.
# Required synoptics of the command:
# <binfile> <flags> <inputflags> <input.xmi> <outputflags> <output.eps>
XMI2SVG_BIN           = uml2svg
XMI2SVG_FLAGS         =
XMI2SVG_INPUT_FLAGS   =
XMI2SVG_OUTPUT_FLAGS  = -o
XMI2SVG_POST_FLAGS    =
XMI2SVG_OUTPUT_INPUT  = yes
XMI2SVG_OUTPUT_STDOUT = no

#-----------------------------------
#----------- DO NOT CHANGE BELOW
#-----------------------------------

# The commands to convert an EPS file into PDF are required
ifeq ("$(call isTranslatorLoaded,eps2pdf)","false")
include $(call getTranslatorMkfile,eps2pdf)
endif

# Notify of the loading of this module
LOADED_TRANSLATORS += xmi2pdf

XMI_FIG = $(call launchShell, ${FIND_CMD} ${AUTO_GENERATE_IMAGE_DIRECTORY} -name "*.xmi" -o -name "*.uml")

SVG_XMI = $(addsuffix .svg,          $(basename ${XMI_FIG}))
EPS_XMI = $(addsuffix .eps,          $(basename ${XMI_FIG}))
PDF_XMI = $(addsuffix .pdf,          $(basename ${XMI_FIG}))

SOURCE_IMAGES += ${XMI_FIG}
TMPIMAGES     += ${SVG_XMI} ${EPS_XMI}
IMAGES        += ${PDF_XMI}

# Compile the convertion parameters
ifeq ("-$(findstring =,$(XMI2SVG_INPUT_FLAGS))","-")
XMI2SVG_INPUT_FLAGS_EX = $(strip $(XMI2SVG_INPUT_FLAGS)) "$<"
else
XMI2SVG_INPUT_FLAGS_EX = $(strip $(XMI2SVG_INPUT_FLAGS))"$<"
endif
ifeq ("-$(findstring =,$(XMI2SVG_OUTPUT_FLAGS))","-")
XMI2SVG_OUTPUT_FLAGS_EX = $(strip $(XMI2SVG_OUTPUT_FLAGS)) "$@"
else
XMI2SVG_OUTPUT_FLAGS_EX = $(strip $(XMI2SVG_OUTPUT_FLAGS))"$@"
endif

# Compile the convertion commands
ifeq ("${XMI2SVG_OUTPUT_STDOUT}","yes")
XMI2SVG_SHELL_CMD = $(XMI2SVG_BIN) $(XMI2SVG_FLAGS) $(XMI2SVG_INPUT_FLAGS_EX) $(XMI2SVG_POST_FLAGS) > "$@"
else
ifeq ("${XMI2SVG_OUTPUT_INPUT}","yes")
XMI2SVG_SHELL_CMD = $(XMI2SVG_BIN) $(XMI2SVG_FLAGS) $(XMI2SVG_OUTPUT_FLAGS_EX) $(XMI2SVG_INPUT_FLAGS_EX) $(XMI2SVG_POST_FLAGS)
else
XMI2SVG_SHELL_CMD = $(XMI2SVG_BIN) $(XMI2SVG_FLAGS) $(XMI2SVG_INPUT_FLAGS_EX) $(XMI2SVG_OUTPUT_FLAGS_EX) $(XMI2SVG_POST_FLAGS)
endif
endif


$(SVG_XMI): %.svg: %.xmi
	@ ${ECHO_CMD} "$< -> $@" && $(XMI2SVG_SHELL_CMD)

$(EPS_XMI): %.eps: %.svg
	@ ${ECHO_CMD} "$< -> $@" && $(SVG2EPS_SHELL_CMD)

$(PDF_XMI): %.pdf: %.eps
	@ ${ECHO_CMD} "$< -> $@" && $(EPS2PDF_SHELL_CMD)

endif
