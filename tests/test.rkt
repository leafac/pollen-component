#lang racket
(module+ test
  (require rackunit pollen/cache)

  (require (prefix-in index: "index.html.pm"))
  (check-equal?
   index:doc
   '(root (p (a ((href "https://www.leafac.com")) "Website which originated Pollen Component.")) (p (a ((href "https://www.github.com/leafac")) "@leafac on GitHub"))))
  (reset-cache)

  (require (prefix-in feed: "feed.atom.pm"))
  (check-equal?
   feed:doc
   '(root (link ((href "https://example.com"))) "\n" "\n" (author "@" "leafac")))
  (reset-cache)

  (require (prefix-in pollen: "pollen.rkt"))
  (check-equal?
   (pollen:components/css)
   '((body-text . "body {font-size: 18px;}") (link . "a {background-color: pink;}")))
  (reset-cache))

(module+ test
  (require (only-in pollen-component current-pollen-component-dynamic-type)
           (prefix-in parameter: "parameter.rkt"))

  ;; error if metas is undefined and current-pollen-component-dynamic-type is not set
  (check-exn
   exn:fail:user?
   (lambda () (parameter:tag "hello who?")))

  (check-equal?
   (parameterize ([current-pollen-component-dynamic-type "html"])
     (parameter:tag "hello html"))
   '(div ((id "hello html"))))

  (check-equal?
   (parameterize ([current-pollen-component-dynamic-type "atom"])
     (parameter:tag "hello atom"))
   '(some-tag "@" "hello atom")))