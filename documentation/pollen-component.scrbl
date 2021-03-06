#lang scribble/manual

@(require (for-label racket pollen-component pollen/tag)
          racket/string file/sha1 racket/format racket/file racket/system)

@(define path/images (if (directory-exists? "documentation/") "documentation/" ""))

@title{Pollen Component}
@author{@author+email["Leandro Facchinetti" "me@leafac.com"]}

@defmodule[pollen-component]

@emph{Component-based development for @hyperlink["http://pollenpub.com/"]{Pollen}.}

@tabular[#:style 'boxed
         #:sep @hspace[1]
         #:row-properties '(bottom-border)
         `((, @bold{Version} , @seclink["changelog/0.0.5"]{0.0.5})
           (, @bold{Documentation} , @hyperlink["https://docs.racket-lang.org/pollen-component/"]{Racket Documentation})
           (, @bold{License} , @hyperlink["https://gnu.org/licenses/gpl-3.0.txt"]{GNU General Public License Version 3})
           (, @bold{Code of Conduct} , @hyperlink["http://contributor-covenant.org/version/1/4/"]{Contributor Covenant v1.4.0})
           (, @bold{Distribution} , @hyperlink["https://pkgs.racket-lang.org/package/pollen-component"]{Racket Package})
           (, @bold{Source} , @hyperlink["https://github.com/leafac/pollen-component"]{GitHub})
           (, @bold{Bug Reports} , @hyperlink["https://github.com/leafac/pollen-component/issues"]{GitHub Issues})
           (, @bold{Contributions} , @hyperlink["https://github.com/leafac/pollen-component/pulls"]{GitHub Pull Requests}))]

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

The separation of structure (@filepath{pollen.rkt}), appearance (@filepath{styles.css.pp}), behavior (@filepath{scripts.js.pp}) and content (@filepath{index.html.pm}) is a good idea that stood the test of time. So much so, that it is not particular of Pollen projects, but the standard in document-preparation systems like the web and @hyperlink["https://www.latex-project.org/"]{LaTeX}. Its main advantage is consistency: generated documents use the same fonts, colors, sizes and so on throughout the pages because those are specified in a single place.

The problems with this model begin when changing from questions like “what are all the styles in effect on this document?” to questions like “what constitutes a link on this document?” To answer this, it is necessary to open at least three files—@filepath{pollen.rkt}, @filepath{styles.css.pp} and @filepath{scripts.js.pp}—and search for the snippets relevant to links. One sees only the pieces and has to @emph{imagine} the full picture. Also, as the project grows, it becomes harder to understand the far-reached effects the parts have on one another.

@margin-note{@image[@~a{@|path/images|traditional-vs-component-based.png}]}

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

Pollen Component is a @hyperlink["https://pkgs.racket-lang.org/package/pollen-component"]{Racket package}. Install it in DrRacket or with the following command line:

@nested[#:style 'code-inset
        @verbatim|{
$ raco pkg install pollen-component
         }|]

@section[#:tag "usage"]{Usage}

@defform[(components-output-types
          [#:dynamic dynamic ...] [#:static static ...])
         #:contracts ([dynamic identifier?]
                      [static identifier?])]{
 @margin-note{See Pollen Component in action on my @hyperlink["https://www.leafac.com"]{personal website} (@hyperlink["https://github.com/leafac/www.leafac.com/tree/pollen-component"]{source}). It also uses @hyperlink["https://docs.racket-lang.org/css-expr"]{CSS-expressions} to define CSS.}

 Use @racket[components-output-types] in @filepath{pollen.rkt} to specify the output types supported by components. The @racket[dynamic] output types are those for which one would create tag functions, for example, HTML, Atom and LaTeX. The @racket[static] output types are the styles and behavior that support the document, for example, CSS, JavaScript and LaTeX styles.

 @margin-note{The @racket[static] output types receive this name because, with respect to the component being defined, the contents of the @racket[static] output types are always the same and known at the time of defining the component. In contrast, the contents of @racket[dynamic] output types will not be known until the component is used. For example, there may be many different HTML links on a page, so a @racket[link] component would have HTML as a @racket[dynamic] output type; but the styles associated with links are always the same, defined in a stylesheet, so CSS would be a @racket[static] output type.}

 Using @racket[components-output-types] introduces bindings for @racket[define-component] and @racket[components/<static>]s (one for each @racket[static] output type) in the current environment. Thus, @racket[components-output-types] @emph{must come first and appear only once}.
}

@defform[(define-component form
           [#:output-type body ...+]
           ...)]{
 The available @racket[#:output-type]s are those declared in @racket[components-output-types].

 The @racket[body] corresponding to @racket[dynamic] output types turn into a function tag that detects the output type of the current document and executes the appropriate code. Undefined @racket[dynamic] output types fall back to @racket[default-tag-function].

 The @racket[body] corresponding to @racket[static] output types are accumulated in @seclink["parameterize" #:doc '(lib "scribblings/guide/guide.scrbl")]{Racket parameters} of association lists named @racket[components/<static>]. There is one @racket[components/<static>] parameter for each static output type. The keys are the components names (as symbols) and the values are the components contents for that output type as defined by @racket[body].
}

@defparam[current-pollen-component-dynamic-type type string?]{
A parameter that for using component outside a Pollen scope. Use this to set the dynamic output type in places where the Pollen @racket[metas] variable is undefined, for example, to define components in files other than @filepath{pollen.rkt}.
}

@racketmod[
 #:file "component.rkt"
 racket
 (require pollen-component)
 (provide (all-defined-out))

 (components-output-types #:dynamic html txt #:static css javascript)

 (define-component (test a)
   #:html
   `(p ,a)
   #:txt
   (format "Hey you wrote : ~a" a))

 (code:comment "get the html version")
 (parameterize ([current-pollen-component-dynamic-type "html"])
   (test "hello"))

 (code:comment "get the txt version")
 (parameterize ([current-pollen-component-dynamic-type "txt"])
   (test "hello"))]

@section[#:tag "acknowledgments"]{Acknowledgments}

Thank you @hyperlink["http://typographyforlawyers.com/about.html"]{Matthew Butterick} for Pollen and for the feedback given in private email conversations. Thank you Greg Trzeciak for the feedback given in private conversations. Thank you Luke Whittlesey for contributing @racket[current-pollen-component-dynamic-type]. Thank you all Racket developers. Thank you all users of this library.

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

@subsection[#:tag "changelog/0.0.5"]{0.0.5 · 2018-05-03}

@subsubsection[#:tag "changelog/0.0.5/added"]{Added}

@itemlist[
 @item{Added @racket[current-pollen-component-dynamic-type]. (Thanks Luke Whittlesey.)}]

@subsection[#:tag "changelog/0.0.4"]{0.0.4 · 2017-03-08}

@subsubsection[#:tag "changelog/0.0.4/fixed"]{Fixed}

@itemlist[
 @item{Fix automated tests by ommitting examples directory.}]

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
