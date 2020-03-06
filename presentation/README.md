# latex_project_starter

The directory structure and configuration I use for latex documents.

## Intended Usage

I use this directory structure and configuration files when writing a latex document.
It helps enable aspects of my workflow:

- Keeps files organized logically
- Allows me to separate logical parts of the latex document, reducing them to an `input` line, to ease navigation in the code and easily include/exclude pieces of the documents
- Makes it easy for me to automate the generation of tables and figures, e.g., I usually write `pgfplots` figures and latex tables directly from MATLAB.
- Easy reuse of settings and styles

## Configuration Files

I made a set of configuration files to ease reuse of code and reduce boilerplate in the main document.
I often find that desired functionality, e.g., float handling or pgfplots, require multiple packages or settings.
By placing these in their own file and gating them through options, I keep the main code clean and reduce the demands on my memory.
I can add comments to these separate files to explain settings without a giant preamble in my main code.
Some functionality like bibliographies or pgfplots, can make compilation annoyingly long.
I can easily exclude these (defining dummy versions of the commands I'm using) so compilation is fast when I'm working on some other part of the document.

The options are described in the template files.

## Custom Presentation Styles

I wrote a set of style and configuration code to make presentation slides.
I found that `beamer` is (was? it's been awhile) not compatible with standard functionality, e.g., citations.
There is a different `beamer` way to accomplish most things, but that's a hassle.
At the same time, I don't use any of the advanced functionality, e.g., automated timelines, or forward/backward links.
So I just made a presentation configuration it:

- Sets paper size small enough so that 10-12pt text is "presentation" sized.
  - Sets `section` to make a section title slide
  - Sets `subsection` to make a new slide with the subsection name as the title
  - Sets `subsubsection` to place the name in the upper right of the slide
    - Typically I'm using this to break a topic across multiple slides, e.g., slides: I, II, and III

## Directory Structure

`bibliography`
    ~ For bibliography file, e.g., `.bib`

`conversion_output`
    ~ For documents created by conversion from the latex version, e.g., from `ht4latex`, or `pandoc`

`data`
    ~ For data files for pgf figures

`external_figures`
    ~ For externalized plots from pgfplots.

`figures`
    ~ For `.tex` files containing pgfplots code. Mostly defining figures, but sometimes other code such as cycle lists or colors.

`media`
    ~ For non-`.tex` media files included in the document, e.g., a figure `.pdf`, or a `.png`

`mm_configuration`
    ~ For my custom configuration files, a combination of `.tex` and `.sty` files.

`tables`
    ~ For `.tex` files containing code for tables.
