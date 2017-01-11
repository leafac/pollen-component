#lang pollen

◊(string-join
  (for/list ([(component javascript)
              (in-dict (components/javascript))])
    (~a "/*" component "*/" javascript)))