#lang scribble/manual

@(require (for-label racket pollen-component pollen/tag)
          racket/string file/sha1 racket/format racket/file racket/system)

@(define (tikz . sources)
   (define path/images (findf directory-exists? '("documentation/images" "images")))
   (define source
     @~a{
 \documentclass[tikz]{standalone}
 \usepackage{fontspec}
 \setmainfont{Fira Sans Light}
 \usetikzlibrary{fit, matrix, shapes.geometric, positioning}
 \begin{document}
 \begin{tikzpicture}
 @(string-join sources)
 \end{tikzpicture}
 \end{document}
 })
   (define name (sha1 (open-input-string source)))
   (define path/latex (~a path/images "/" name ".tex"))
   (define path/pdf (~a path/images "/" name ".pdf"))
   (define path/image (~a path/images "/" name ".png"))
   (unless (file-exists? path/latex) (display-to-file source path/latex))
   (unless (file-exists? path/pdf) (system (~a "xelatex '" path/latex "'")))
   (unless (file-exists? path/image)
     (system (~a "convert -density 2000 -resize 5.5% '" path/pdf "' '" path/image "'")))
   (image path/image))

@title{Pollen Component}
@author{@author+email["Leandro Facchinetti" "me@leafac.com"]}

@defmodule[pollen-component]

@emph{Component-based development for @hyperlink["http://pollenpub.com/"]{Pollen}.}

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:row-properties '(bottom-border)
         `((, @bold{Version} , @seclink["changelog/0.0.3"]{0.0.3})
           (, @bold{Documentation} , @hyperlink["https://docs.racket-lang.org/pollen-component"]{https://docs.racket-lang.org/pollen-component})
           (, @bold{License} , @hyperlink["https://gnu.org/licenses/gpl-3.0.txt"]{GNU General Public License Version 3})
           (, @bold{Code of Conduct} , @hyperlink["http://contributor-covenant.org/version/1/4/"]{Contributor Covenant v1.4.0})
           (, @bold{Distribution} , @hyperlink["https://pkgd.racket-lang.org/pkgn/package/pollen-component"]{Racket package})
           (, @bold{Source} , @hyperlink["https://git.leafac.com/pollen-component"]{https://git.leafac.com/pollen-component})
           (, @bold{Bug Reports} , @para{Write emails to @hyperlink["mailto:pollen-component@leafac.com"]|{pollen-component@leafac.com}|.})
           (, @bold{Contributions} , @para{Send @hyperlink["https://git-scm.com/docs/git-format-patch"]{patches} and @hyperlink["https://git-scm.com/docs/git-request-pull"]{pull requests} via email to @hyperlink["mailto:pollen-component@leafac.com"]|{pollen-component@leafac.com}|.}))]

@section[#:tag "overview"]{Overview}

@hyperlink["http://pollenpub.com/"]{Pollen} projects are generally structured like the following:

@racketmod[
 #:file "pollen.rkt"
 racket

 (provide (all-defined-out))

 (define (link href . elements)
   `(a ((href ,href)) ,@elements))
 ]

@nested[#:style 'code-inset
        @filebox["styles.css.pp"
                 @codeblock0|{
#lang pollen

a { color: red; }
  }|]]


@nested[#:style 'code-inset
        @filebox["scripts.js.pp"
                 @codeblock0|{
#lang pollen

var links = document.getElementsByTagName('a'); // …
                          }|]]

@nested[#:style 'code-inset
        @filebox["index.html.pm"
                 @codeblock0|{
#lang pollen

Without ◊link["http://…"]{Pollen Component}.
                          }|]]

The separation of structure (@filepath{pollen.rkt}), appearance (@filepath{styles.css.pp}), behavior (@filepath{scripts.js.pp}) and content (@filepath{index.html.pm}) is a good idea that stood the test of time. So much so, that it is not particular of Pollen projects, but the standard in document-preparation systems like the web and LaTeX. Its main advantage is consistency: generated documents use the same fonts, colors, sizes and so on throughout the pages because those are specified in a single place.

The problems with this model begin when changing from questions like “what are all the styles in effect on this document?” to questions like “what constitutes a link on this document?” To answer this, it is necessary to open at least three files—@filepath{pollen.rkt}, @filepath{styles.css.pp} and @filepath{scripts.js.pp}—and search for the snippets relevant to links. One sees only the pieces and has to @emph{imagine} the full picture. Also, as the project grows, it becomes harder to understand the far-reached effects the parts have on one another.

@margin-note{
 @tikz|{
  [grouper/.style = {thick, ellipse, inner sep = -1mm}]
  \definecolor{traditional}{HTML}{0077AA}
  \definecolor{component}{HTML}{228B22}

  \matrix [matrix of nodes, column 1/.style = {anchor = base east}] (matrix) {
         & Link      & List      & $\cdots$ \\
    HTML & $\bullet$ & $\bullet$ & $\cdots$ \\
    CSS  & $\bullet$ & $\bullet$ & $\cdots$ \\
    JS   & $\bullet$ & $\bullet$ & $\cdots$ \\
  };
  \foreach \y in {2, 3, 4} {
    \node [grouper, draw = traditional, fit = (matrix-\y-2) (matrix-\y-3) (matrix-\y-4)] {};
  }
  \foreach \x in {2, 3} {
    \node [grouper, draw = component, fit = (matrix-2-\x) (matrix-3-\x) (matrix-4-\x)] {};
  }
  \node [traditional, anchor = west, xshift = 1mm] at (matrix-3-4 -| matrix.east) {Traditional};
  \node [component, anchor = north west, shift = {(-3mm, -1mm)}] at (matrix-4-2.south) {Component};
  }|
}

Recently, modern web development tools including @hyperlink["https://facebook.github.io/react/"]{React} and @hyperlink["https://www.polymer-project.org"]{Polymer} popularized one solution to these issues: @emph{components}. Components bring together the definitions of structure, appearance and behavior for distinguishable parts of the document.

Components do not replace the traditional architecture. For example, the cascading behavior of CSS is still useful to guarantee consistency throughout the document. But components yield better organization for elements that make sense on their own: links, menus and @seclink["Tags___tag_functions" #:doc '(lib "pollen/scribblings/pollen.scrbl")]{tag functions} in general.

While tools like React and Polymer target application development, we believe that document-preparation systems can benefit from components as well. Thus, we present @emph{Pollen Component}: an extension to Pollen that allows for component-based development.

The example above becomes the following with Pollen Component:

@racketmod[
 #:file "pollen.rkt"
 racket
 (require pollen-component
          racket/dict racket/string racket/format)

 (provide (all-defined-out)
          (all-from-out racket/dict racket/string racket/format))

 (components-output-types #:dynamic html #:static css javascript)

 (define-component (link href . elements)
   #:html
   `(a ((href ,href)) ,@elements)
   #:css
   "a { color: red; }"
   #:javascript
   "var links = document.getElementsByTagName('a'); // …")
 ]

@nested[#:style 'code-inset
        @filebox["styles.css.pp"
                 @codeblock0|{
#lang pollen

◊(string-join
  (for/list ([(component css) (in-dict (components/css))])
    (~a "/*" component "*/" css)))
                          }|]]

@nested[#:style 'code-inset
        @filebox["scripts.js.pp"
                 @codeblock0|{
#lang pollen

◊(string-join
  (for/list ([(component javascript)
              (in-dict (components/javascript))])
    (~a "/*" component "*/" javascript)))
                          }|]]

@nested[#:style 'code-inset
        @filebox["index.html.pm"
                 @codeblock0|{
#lang pollen

Welcome to ◊link["http://…"]{Pollen Component}.
}|]]

Unleash the full power of Pollen Component by defining CSS with @hyperlink["https://docs.racket-lang.org/css-expr"]{CSS-expressions} and JavaScript with @hyperlink["https://github.com/soegaard/urlang"]{Urlang}:

@racketmod[
 #:file "pollen.rkt"
 racket
 (require pollen-component css-expr urlang)

 (provide (all-defined-out))

 (current-urlang-echo? #t)

 (components-output-types #:dynamic html
                          #:static css javascript)

 (define-syntax-rule (javascript expressions ...)
   (with-output-to-string
       (λ ()
         (urlang
          (urmodule
           javascript-module expressions ...)))))

 (define-component (link href . elements)
   #:html
   `(a ((href ,href)) ,@elements)
   #:css
   (css-expr [a #:color red])
   #:javascript
   (javascript
    (import document)
    (define links (document.getElementsByTagName "a"))))]

@section[#:tag "installation"]{Installation}

Pollen Component is a @hyperlink["https://pkgd.racket-lang.org/pkgn/package/pollen-component"]{Racket package}. Install it in DrRacket or with the following command line:

@nested[#:style 'code-inset
        @verbatim|{
$ raco pkg install pollen-component
         }|]

@section[#:tag "usage"]{Usage}

@defform[(components-output-types
          [#:dynamic dynamic ...] [#:static static ...])
         #:contracts ([dynamic identifier?]
                      [static identifier?])]{
 @margin-note{See Pollen Component in action on my @hyperlink["https://www.leafac.com"]{personal website} (@hyperlink["https://git.leafac.com/www.leafac.com/"]{source}). It also uses @hyperlink["https://docs.racket-lang.org/css-expr"]{CSS-expressions} to define CSS.}

 Use @racket[components-output-types] in @filepath{pollen.rkt} to specify the output types supported by components. The @racket[dynamic] output types are those for which one would create tag functions, for example, HTML, Atom and LaTeX. The @racket[static] output types are the styles and behavior that support the document, for example, CSS, JavaScript and LaTeX styles.

 Using @racket[components-output-types] introduces bindings for @racket[define-component] and @racket[components/<static>]s (one for each @racket[static] output type) in the current environment. Thus, @racket[components-output-types] @emph{must come first and appear only once}.
}

@defform[(define-component form
           [#:output-type body ...+]
           ...)]{
 The available @racket[#:output-type]s are those declared in @racket[components-output-types].

 The @racket[body] corresponding to @racket[dynamic] output types turn into a function tag that detects the output type of the current document and executes the appropriate code. Undefined @racket[dynamic] output types fall back to @racket[default-tag-function].

 The @racket[body] corresponding to @racket[static] output types are accumulated in parameters of association lists named @racket[components/<static>]. There is one @racket[components/<static>] parameter for each static output type. The keys are the components’ names (as symbols) and the values are the components’ contents for that output type as defined by @racket[body].
}

@section[#:tag "acknowledgments"]{Acknowledgments}

Thank you @hyperlink["http://typographyforlawyers.com/about.html"]{Matthew Butterick} for Pollen and for the feedback given in private email conversations. Thank you Greg Trzeciak for the feedback given in private conversations. Thank you all Racket developers. Thank you all users of this library.

@section[#:tag "changelog"]{Changelog}

This section documents all notable changes to pollen-component. It follows recommendations from @hyperlink["http://keepachangelog.com/"]{Keep a CHANGELOG} and uses @hyperlink["http://semver.org/"]{Semantic Versioning}. Each released version is a Git tag.

@;{
 @subsection[#:tag "changelog/unreleased"]{Unreleased} @; 0.0.1 · 2016-02-23

 @subsubsection[#:tag "changelog/unreleased/added"]{Added}

 @subsubsection[#:tag "changelog/unreleased/changed"]{Changed}

 @subsubsection[#:tag "changelog/unreleased/deprecated"]{Deprecated}

 @subsubsection[#:tag "changelog/unreleased/removed"]{Removed}

 @subsubsection[#:tag "changelog/unreleased/fixed"]{Fixed}

 @subsubsection[#:tag "changelog/unreleased/security"]{Security}
}

@subsection[#:tag "changelog/0.0.3"]{0.0.3 · 2017-02-13}

@subsubsection[#:tag "changelog/0.0.3/added"]{Added}

@itemlist[
 @item{Automated tests.}]

@subsection[#:tag "changelog/0.0.2"]{0.0.2 · 2017-02-12}

@subsubsection[#:tag "changelog/0.0.2/added"]{Added}

@itemlist[
 @item{Example in documentation of how to use Pollen Component with CSS-expressions and Urlang.}
 @item{Acknowledgment to Greg Trzeciak.}]

@subsection[#:tag "changelog/0.0.1"]{0.0.1 · 2017-01-21}

@subsubsection[#:tag "changelog/0.0.1/added"]{Added}

@itemlist[
 @item{Basic functionality.}]
