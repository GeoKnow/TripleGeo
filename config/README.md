## Configuration

This directory contains configuration file templates.
These templates document all available run-time options and can also be used to generate 
(on-the-fly) configuration files to be passed to triplegeo.

Use ordinary text substitution techniques to generate an applicable configuration file 
(eg. via _sed_ or via _genshi_):

    sed -f substitutions.sed shp_options.conf.template > shp_options-1.conf


