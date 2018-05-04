#lang at-exp racket
(require pollen-component)
(provide (all-defined-out))

(components-output-types #:dynamic html txt #:static css javascript)

(define-component (test a)
  #:html
  `(p ,a)
  #:txt
  (format "Hey you wrote : ~a" a))

;; use the parameter to get the html version
(parameterize ([current-pollen-component-dynamic-type "html"])
  (test "hello"))

;; use the parameter to get the txt version
(parameterize ([current-pollen-component-dynamic-type "txt"])
  (test "hello"))