#lang racket/base
(require (for-syntax racket/base syntax/parse pollen/setup racket/dict racket/list racket/syntax)
         pollen/core pollen/setup pollen/file pollen/tag sugar/file syntax/parse/define racket/list)

(provide components-output-types)

(define-syntax-parser components-output-types
  [(components-output-types (~or (~optional (~seq #:dynamic dynamic:identifier ...))
                         (~optional (~seq #:static static:identifier ...)))
                    ...)
   (with-syntax ([define-component (datum->syntax #'components-output-types 'define-component)]
                 [((dynamic/keyword dynamic/expr dynamic/expr:expr) ...)
                  (for/list ([the-dynamic
                              (if (attribute dynamic) (syntax->datum #'(dynamic ...)) '())])
                    `(,(string->keyword (symbol->string the-dynamic))
                      ,(format-id #'components-output-types "~a/expr" the-dynamic)
                      ,(format-id #'components-output-types "~a/expr:expr" the-dynamic)))]
                 [((static/keyword static/expr static/expr:expr components/static) ...)
                  (for/list ([the-static
                              (if (attribute static) (syntax->datum #'(static ...)) '())])
                    `(,(string->keyword (symbol->string the-static))
                      ,(format-id #'components-output-types "~a/expr" the-static)
                      ,(format-id #'components-output-types "~a/expr:expr" the-static)
                      ,(format-id #'components-output-types "components/~a" the-static)))]
                 [syntax/parse/define (datum->syntax #'components-output-types 'syntax/parse/define)])
     #'(begin
         (require syntax/parse/define)
         (define-syntax-parser define-component
           [(define-component signature:expr
              (~or (~optional (~seq dynamic/keyword dynamic/expr:expr (... ...+))) ...
                   (~optional (~seq static/keyword static/expr:expr (... ...+))) ...)
              (... ...))
            (define output-types/dynamic
              (filter cdr `((dynamic . ,(attribute dynamic/expr)) ...)))
            (define output-types/static
              (filter cdr `((components/static . ,(attribute static/expr)) ...)))
            (with-syntax ([the-component
                           (if (identifier? #'signature) #'signature (car (syntax-e #'signature)))]
                          [metas (datum->syntax #'signature 'metas)]
                          [((output-type . (output-type/expr (... ...))) (... ...))
                           (datum->syntax #'signature output-types/static)])
              (define component-macro
                (if (not (empty? output-types/dynamic))
                    #`((define-syntax-parser the-component
                         [(the-component argument (... (... ...)))
                          #'((make-keyword-procedure
                              (λ (keywords keyword-arguments . rest)
                                (keyword-apply the-component keywords keyword-arguments rest)))
                             argument (... (... ...)))]
                         [the-component
                          (with-syntax ([metas* (datum->syntax #'the-component 'metas)])
                            #'(let* ([metas metas*]
                                     [here (select-from-metas 'here-path metas)]
                                     [here/output-path (->output-path here)]
                                     [here/extension (get-ext here/output-path)]
                                     [here/output-type
                                      (if (equal? here/extension (setup:poly-source-ext))
                                          (current-poly-target)
                                          (string->symbol here/extension))])
                                (case here/output-type
                                  #,@(for/list ([(output-type output-type/expr)
                                                 (in-dict output-types/dynamic)])
                                       #`[(#,output-type)
                                          (define signature #,@output-type/expr)
                                          the-component])
                                  [else (default-tag-function 'the-component)])))]))
                    #'()))
              (define static-assignments
                #'((output-type
                    (append (output-type)
                            `((the-component . ,(let () output-type/expr (... ...))))))
                   (... ...)))
              #`(begin
                  #,@component-macro
                  #,@static-assignments))])
         (define components/static (make-parameter empty))
         ...))])