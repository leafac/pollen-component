#lang racket
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
   (define links (document.getElementsByTagName "a"))))
