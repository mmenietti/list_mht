# `list_mht` Repository

This repository holds a presentation for discussing "Multiple hypothesis testing in experimental economics" by List, Shaik, and Xu.
An implementation of the associated algorithm is provided in Matlab.
The presentation is a latex document contained in the `presentation` directory. 
The Matlab implementation resides in the `matlab` directory.

The authors of "Multiple hypothesis testing in experimental economics" provide a sample implementation in Matlab as well. 
It can be found at: [https://github.com/seidelj/mht](https://github.com/seidelj/mht)

## References

The following works are referenced in the presentation.

+ List, John A., Azeem M. Shaikh, and Yang Xu (Jan. 29, 2019). “Multiple hypothesis testing in experimental economics.” In: Experimental Economics.
+ Romano, Joseph P. and Michael Wolf (Mar. 5, 2005). “Stepwise Multiple Testing as Formalized Data Snooping.” In: Econometrica.
+ White, Halbert (Sept. 1, 2000). “A Reality Check for Data Snooping.” In: Econometrica

## Presentation

The main file is `presentation/presentation.tex`.
It builds under a full installation of Texlive 2019 on Windows 10.
Other environments have not been tested.
`presentation/presentation.pdf` is the compiled presentation.

## Matlab

The Matlab implementation of the List (2019) MHT algorithm resides in the `matlab` directory.
The algorithm is implemented as a class in `mht.m`.
A test `script_list_mht_test.m` is included. 
