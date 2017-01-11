#lang pollen

◊(string-join
  (for/list ([(component css) (in-dict (components/css))])
    (~a "/*" component "*/" css)))