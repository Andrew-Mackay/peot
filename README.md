# Peot (Psalm Errors over Time)

Peot is a command line application used to analyse the number of errors in a PHP application over time using the [psalm](https://github.com/vimeo/psalm) static analysis tool. 

The target project must use git for version control.

## Project Status
This project is in an alpha state. The program does work but it has in no way been thoroughly tested. For now, it works well enough for my use case and so it is unlikely that I will be making any significant changes in the near future. If you do try it out and come across any bugs or have any suggestions I would be interested to know about them so please submit an issue or pull request.

## Requirements
- [git](https://git-scm.com/)
- [composer installed globally](https://getcomposer.org/doc/00-intro.md#globally)

## Installation
Option 1 (recommended): Download the project and compile yourself.
```
dart pub get
dart compile exe bin/peot.dart -o peot
./peot -h
```

Option 2: Download the repository and run using the Dart VM. 
```
dart pub get
dart bin/peot.dart -h
```

Option 3: Download a pre-compiled executable from the latest [release](https://github.com/Andrew-Mackay/peot/releases). I provide no guarantee on compatibility.
```
./peot -h
```

## Usage
```
./peot -h

peot (psalm errors over time)

Reports the number of static errors in a PHP project over time by running the 
psalm static code analysis tool.

Usage: peot <git-repository> [args]

Results will be written to results.csv.

    --from                    Date to start the analysis from in format YYYY-MM-DD. Example: 2020-02-24.
    --to                      Date to run the analysis until in format YYYY-MM-DD. Example: 2020-02-24.
    --psalm-config            Path to the desired psalm.xml configuration file. If this argument is not
                              provided, the program will check for an existing psalm.xml file in the project
                              repository. If no psalm.xml is found in the project repository, a new psalm.xml
                              file will be initialised using `psalm --init`.
    --frequency               How frequently to analyse the project.
                              [all, daily, weekly, monthly (default), yearly]
    --psalm-version           Which psalm version to use.
                              (defaults to "4.1.1")
-a, --consider-all-commits    By default, analysis is only run on merge commits into the main/master branch.
                              This is found to give a more accurate insight into the state of the codebase
                              over time for projects using some form of branching strategy. Use this flag to
                              override this behaviour and instead consider all commits in the analysis.
-h, --help                    Print this usage information.

```

## Examples
The graphing for these examples was done manually using the data from the outputted results.csv file. Peot does not currently have any in-built graphing support.

### [Andrew-Mackay/laravel_vue_blog_spa](https://github.com/Andrew-Mackay/laravel-vue-spa-blog)
```
./peot git@github.com:Andrew-Mackay/laravel-vue-spa-blog.git --to 2019-09-30 --frequency weekly -a
```

![Peot Results for Andrew-Mackay_laravel_vue_blog_spa](https://user-images.githubusercontent.com/22844315/107846848-fe353800-6dde-11eb-9873-b43485a6e66b.png)

## License
[MIT](LICENSE)
