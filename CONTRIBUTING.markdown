# 如何貢獻本專案<br>How to Contribute This Project
This documents explains how to contribute this project in many aspects, make sure to read them thoroughly before making any contributions

## 語言問題<br>Language Issues
This project is initially a native linguo project, which means Chinese is used as the first priority language.  However I acknowlege the importance of using a much universal language(id. est. English) for a collaborative project so here's the policy:

* Once a collaborator whose not familiar with Chinese starts to colab. with the project, this project will start the tranfer process to become a fully English project, which required the following to be in English or Multi-lingual which English is required as a first priority language:
	* document contents
	* patch info
	* code strings and comments
* If you have any questions about a previously used Chinese content, feel free to ask on the issue tracker

## 回報議題<br>Reporting Issues
The so-called "issue" includes but not limited to software bugs and suggestions

### 在建檔新議題前總是先搜尋重複議題<br>Always search for duplicates before filing a new one
There is possibility that your issue is already been filed on the issue tracker, please search it before considering filing a new one

Use keywords instead of full sentences as search query, for example search "crash unbounded variable" instead of "The program crashes with 'unbounded variable' message printed on screen"

### 有效率地回報軟體缺陷<br>Report Software Bugs Effectively
How you report software bugs greatly effects how fast it has been processed and fixed, refer [How to Report Bugs Effectively](http://www.chiark.greenend.org.uk/~sgtatham/bugs.html) for more information

## 改進程式碼<br>Improving Code
There's so many aspects of the code that can be improved, however please consider the following topics while doing so.

### 程式碼風格<br>Coding Style
It is required to mimic the coding style of the current code

#### 縮排<br>Indentation
This project uses tab characters as indentation character as it's width can be flexibly configured in any modern text editors

#### 不同類型內容間的留白<br>Space padding between different kind of context
* Padding are required for operators
* Padding are avoided for the outer of the curly braces

#### 名稱隔字方式<br>Word Separating Method
* Underscore for variable names
* Underscore for function names(with some exceptions which camel case is mixed used with underscores)

## 參數(?)使用<br>Parameter Usage
### Defensive Bash Programming
#### 所有不會變動的已賦值參數必須設為唯讀<br>READONLY all parameters that is assigned a value and is not variable

#### 所有確定不再被使用的參數必須被取消設定<br>All parameters that is confirmed to not be used should be UNSET

### 檔案字元編碼<br>Character Encoding of File
We use UTF-8 for all of our files

## 推廣本專案給他人<br>Promote This Project to Others
It is welcomed to share this project to others so that they can try it.  Also if you write an article about this project plese share with us, we'd love to hear!
