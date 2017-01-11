#lang racket

(provide (all-defined-out))

(define (link href . elements)
  `(a ((href ,href)) ,@elements))
