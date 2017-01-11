#lang racket
(require pollen-component pollen/decode racket/dict racket/string racket/format)

(provide (all-defined-out) (all-from-out racket/dict racket/string racket/format))

(components-output-types #:dynamic html atom #:static css)

(define-component (root . elements)
  #:html `(root ,@(decode-elements elements #:txexpr-elements-proc decode-paragraphs)))

(define-component body-text
  #:css "body {font-size: 18px;}")

(define-component (link href . components)
  #:html `(a ((href ,href)) ,@components)
  #:css "a {background-color: pink;}")

(define-component (github handle)
  #:html (link (~a "https://www.github.com/" handle) (~a "@" handle " on GitHub"))
  #:atom `(author "@" ,handle))

(define-component (nothing-function))
(define-component nothing-non-function)