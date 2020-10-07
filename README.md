# Edge of Chaos

## Introduction

This repository contains libraries including some essential building blocks 
for the implementation of musical complex adaptive systems in the Faust 
programming environment. (https://faust.grame.fr.)

It includes a set of time-domain algorithms, some of which are original, for 
the processing of low-level and high-level information as well as the 
processing of sound using standard and non-conventional techniques. It also 
includes functions for the realisation of networks with different topologies, 
linear and nonlinear mapping strategies to render positive and negative 
feedback relationships, and different kinds of energy-preserving techniques 
for the stability of self-oscillating systems.

Edge of Chaos is being developed and maintained by Dario Sanfilippo, and it 
is the library through which he creates his music. 

http://dariosanfilippo.com

## Overview of the library modules

    allEOC.lib:         access to all Edge of Chaos library modules from a 
                        single point.

    auxiliaryEOC.lib:   auxiliary functions library for testing, analysis, 
                        inspection, and debugging.

    delaysEOC.lib:      delay line functions library with 
                        samplerate-independent delay parameters based on 
                        aust's delay lines for integer and fractional delays.

    edgeofchaos.lib:    this file provides access to all the Edge of Chaos 
                        library modules through a series of environments.

    filtersEOC.lib:     filters library containing bilinear transform and 
                        topology preserving transform implementations 
                        (zero-delay feedback) of allpass, lowpass, highpass, 
                        bandpass, bandstop, shelving, and state-variable 
                        filters. Furthermore, there are implementations of 
                        crossovers, comb-integrator circuits, analytic filters, 
                        and integrators, among others.

    informationEOC.lib: information processing functions library including 
                        low-level and high-level algorithms both based on 
                        hard-coded and adaptive mechanisms. The low-level 
                        functions provide time-domain techniques for feature 
                        extraction that are normally based on FFT processing, 
                        such as spectral centroid and spectral flatness 
                        (noisiness). The high-level functions provide an 
                        analysis of the state space of low-level information 
                        signals to determine, based on notions of complexity 
                        theory and music perception, characteristics such as 
                        dynamicity, heterogeneity, and complexity of audio 
                        streams.

    mathsEOC.lib:       math library containing functions for statistics, 
                        linear and nonlinear fuzzy logic, interpolators, 
                        network topologies, matrices, linear and nonlinear 
                        mapping, windowing functions, hysteresis, angular 
                        frequency, and several time constants for exponential 
                        decays in one-pole systems.

    oscillatorsEOC.lib: mainly oscillators based on band-limited impulse 
                        trains and an excellent recursive quadrature
                        oscillator.
    
    outformationEOC.lib:audio processing library containing standard and 
                        original techniques for audio transformations.
                        The functions include delay-line granulators with 
                        non-homogenous windowing, windowless granulation 
                        through zero-crossing detection, modulations, 
                        FDN-based processes, and time-variant transfer 
                        functions. The library also includes dynamical
                        systems such as chaotic systems and cellular
                        automata.

    stabilityEOC.lib:   stability processing functions including standard 
                        dynamics processing as well as self-regulating designs.

## Coding conventions

–   80 characters per line.

–   Infix syntax should be used when possible to increace conciseness.

–   Spacing should be used between operands and operators to increase 
    readability.

–   Spacing should be used between operators and arguments for partial 
    application with infix operators (see the Faust manual for a complete list 
    of such operators).

–   No spacing should be used between operators and arguments for partial 
    application with functions.

–   Spacing should be used between the first operand and the parallel composition 
    operator (comma operator), while the second operand should be on a new line 
    indented with the first one.

–   When separating arguments, there should be no spacing between the comma and 
    the argument on its left to distinguish it from the parallel composition 
    operator (comma).

–   The recursive composition operator and its right-operand should be on a new 
    line and indented with the operator where the recursion is connected.
