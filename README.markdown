# GNU Bash Shell Script Template
[![This project's current build status on Travis CI](https://travis-ci.org/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template.svg?branch=master)](https://travis-ci.org/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template)  
This project provides easy-to-use shell script templates for GNU Bash for users to create new scripts.  
<https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template>

![Template Selection Menu in Dolphin FM(KDE)](Pictures/Template%20Selection%20Menu%20in%20Dolphin%20FM%28KDE%29.png)

## Features
### Debugger-friendly

Local debuggers need fresh livers, we made scripts more error-proof and bug-aware by bailing out whenever a potential scripting error is found.

Secure programming paradigms like [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) and [Defensive BASH Programming](http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/) are incorporated into the template design.

### Developer-friendly

We want developers to fucus on their code instead of the template's, so we moved developer related code like the `init`function, `print_help_message` function and `process_commandline_arguments` function to the start of the script and rest of the support code at the bottom.

The template is fully versioned at the bottom of the script, which is useful to upgrade your script to new template versions for new features and fixes.

### Beginner-friendly

The code is documented with essential pointers for beginner to lookup with, like relevant [GNU Bash manual](https://www.gnu.org/software/bash/manual/) sections, [Stack Overflow](https://stackoverflow.com/) answers and [Bash Hackers Wiki](http://wiki.bash-hackers.org) articles.

### Full of Functionalities

We have incorporated the following features into the templates, so that user don't need to recreate wheels.

* Integrated runtime dependency checking
* ERR/EXIT/INT traps for exception handling
* Command-line argument parsing with GNU long variant option support
* `--help` message printing
* Frequently used primitive variables
  * RUNTIME_EXECUTABLE_PATH
    `/home/username/somewhere/My Awesome Script.bash`
  * RUNTIME_EXECUTABLE_FILENAME
    `My Awesome Script.bash`
  * RUNTIME_EXECUTABLE_NAME
    `My Awesome Script`
  * RUNTIME_EXECUTABLE_DIRECTORY
    `/home/username/somewhere`
  * RUNTIME_COMMANDLINE_BASECOMMAND
    A guessed command string that user used to run the script
    * `My Awesome Script.bash` if the script is in the executable search `PATH`s (only in full variant)
    * `${0}`otherwises.
  * RUNTIME_COMMANDLINE_PARAMETERS
    An array of command-line parameters

![Demonstration - Runtime Dependency Checking.png](Pictures/Demonstration%20-%20Runtime%20Dependency%20Checking.png)

![Demonstration - Command-line Argument Parsing and Help Message](Pictures/Demonstration%20-%20Command-line%20Argument%20Parsing%20and%20Help%20Message.png)

![Demonstration - EXIT Trap and Terminal Pausing](Pictures/Demonstration%20-%20EXIT%20Trap%20and%20Terminal%20Pausing.png)

### Space and non-ASCII Characters Friendly

Script won't broke in a foreign environment.

![Unsafe Path Friendly](Pictures/Unsafe%20Path%20Friendly.png)

### With Installer that can Install Templates to XDG-compliant File Manager Applications

Supports:

* Dolphin
* GNOME Files
* and more...(as long as they are compliant)

### Need More or Less?  You're Covered

The following variants are provided:

* **PRIMITIVE**  
  The recommended variant for regular use, core functionalities included.
* **FULL**  
  Hundreds of lines of support code, including additionl features like:
  * Stacktrace printing
  * Multiple installation configuration support: Standalone/SHC/FHS, conforming to the [Flexible Software Installation Specification](https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification)
  * Utility functions like `meta_util_array_shift`
  * ...and more
* **SOURCE'D ** 
  Template for source'd code, with include guard support
* **VANILLA.BASH ** 
  [Vanilla.bash* is a fast, lightweight, backward compatible template for building incredible, powerful GNU Bash applications.](https://github.com/Lin-Buo-Ren/Vanilla.bash)

### Verified

The code is continuously verified by [ShellCheck](https://www.shellcheck.net/) to not containing any potential pitfalls.

## Conforming Specifications
* Use the Unofficial Bash Strict Mode (Unless You Looove Debugging)  
  <http://redsymbol.net/articles/unofficial-bash-strict-mode/>
* Defensive BASH programming - Say what?  
  <http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/>
* Shebang (Unix) - Wikipedia  
  <https://en.wikipedia.org/wiki/Shebang_(Unix)>
* Flexible Software Installation Specification  
  <https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification>

## References
Some information used to improve the project:

* [BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki](http://mywiki.wooledge.org/BashFAQ/028)

## Software Dependencies
### Runtime Dependencies
#### [GNU Core Utilities(Coreutils)](http://www.gnu.org/software/coreutils/coreutils.html)
For fetching script names and paths

### Development Dependencies
#### [ShellCheck – shell script analysis tool](http://www.shellcheck.net/)
To check any potential problems in the script

#### [GNU Sed](https://www.gnu.org/software/sed/)
For implementing script version injection

#### [Git](https://git-scm.com/)

For revision management etc.

## Download Software
Please refer the [releases page](https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template/releases) for ready to use software.

## Intellectual Property License
GNU General Public License v3+ *with an exception of only using this software as a template of a shell script(which you can use any license you prefer, attribution appreciated)*

This means that GPL is enforced only when you're making another "shell script template" using this software, which you're demanded to also using GPL for your work

## Similar Projects
Similar projects that we may benefit from:

* [BASH3 Boilerplate – Template for writing better Bash scripts](http://bash3boilerplate.sh/)

