# GNU Bash Shell Script 範本<br>GNU Bash Shell Script Template
[![This project's current build status on Travis CI](https://travis-ci.org/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template.svg?branch=master)](https://travis-ci.org/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template)  
本專案設計易於重複使用的 GNU Bash Shell Script，方便使用者設計新的 shell script  
<https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template>

![Template Selection Menu in Dolphin FM(KDE)](Pictures/Template%20Selection%20Menu%20in%20Dolphin%20FM%28KDE%29.png)

## 特色<br>Features
### 引進了 [Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)、[Defensive BASH programming](http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/)，地方的 debugger 需要新鮮的肝

### 內建執行時期依賴軟體檢查、ERR/EXIT traps、命令列參數分析、印出幫助訊息等功能可以快速套用
![Demonstration - Runtime Dependency Checking.png](Pictures/Demonstration%20-%20Runtime%20Dependency%20Checking.png)

![Demonstration - Command-line Argument Parsing and Help Message](Pictures/Demonstration%20-%20Command-line%20Argument%20Parsing%20and%20Help%20Message.png)

![Demonstration - EXIT Trap and Terminal Pausing](Pictures/Demonstration%20-%20EXIT%20Trap%20and%20Terminal%20Pausing.png)

### 空白字元、CJK 路徑友善，不會換個目錄程式就爆掉
![Unsafe Path Friendly](Pictures/Unsafe%20Path%20Friendly.png)

### 附有安裝到使用者範本目錄的安裝程式，支援 GNOME Files/DolphinFM 與任何遵從 XDG 規範的軟體

### 如果不需要超過 500 行的輔助功能另外還提供了少於 50 行的基本款，方便撰寫較簡單的 script

### 每個版本都通過 [ShellCheck](http://www.shellcheck.net/) 驗證，品質有保障

## 遵從規範<br>Conforming Specifications
* Use the Unofficial Bash Strict Mode (Unless You Looove Debugging)  
  <http://redsymbol.net/articles/unofficial-bash-strict-mode/>
* Defensive BASH programming - Say what?  
  <http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/>
* Shebang (Unix) - Wikipedia  
  <https://en.wikipedia.org/wiki/Shebang_(Unix)>
* 彈性化軟體安裝規範  
  Flexible Software Installation Specification  
  <https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification>

## 軟體依賴資訊<br>Software Dependency Information
### 執行時期依賴軟體<br>Runtime Dependencies
#### [GNU Core Utilities(Coreutils)](http://www.gnu.org/software/coreutils/coreutils.html)
用於得出程式檔名與路徑

### 開發時期依賴軟體<br>Development Dependencies
#### [ShellCheck – shell script analysis tool](http://www.shellcheck.net/)
用於檢查 shell script 的各種潛在問題

#### [GNU Sed](https://www.gnu.org/software/sed/)
用來實現版本號注入

## 下載軟體<br>Download Software
請至本專案的[軟體釋出頁面](https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template/releases)下載建構好的軟體與來源代碼

## 智慧財產授權條款<br>Intellectual Property License
GNU General Public License v3+ *with an exception of only using this software as a template of a shell script(which you can use any license you prefer, attribution appreciated)*

This means that GPL is enforced only when you're making another "shell script template" using this software, which you're demanded to also using GPL for your work

## 類似專案<br>Similar Projects
Similar projects that we may benifit from:

* [BASH3 Boilerplate – Template for writing better Bash scripts](http://bash3boilerplate.sh/)
