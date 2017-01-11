#lang racket
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
