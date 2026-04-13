% Version 2.0 -----
%%%% Improvements
     % By David Manfroy
% Ajout de certains cadres (info, remarques)
% Modèle utilisé pour les étudiants M-STICS
%2020-2021    

% Version 1.0 -----
%%%% Template for ULB report %%%%
	  % By Boris Coquelet %

%Dans le cadre du poste aide à la réussite au Bureau des étudiants de Polytechnique%
%2019
%----------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ULBreport}
\LoadClass[a4paper,9pt]{report}

%%%%Structure%%%%

\usepackage{ae,lmodern}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

%Language
\RequirePackage{csquotes}
\RequirePackage[french]{babel}
%silence the annoying warning
\frenchsetup{SuppressWarning}
\RequirePackage[backend=biber,citestyle=alphabetic,bibstyle=authoryear]{biblatex}





%Table
\RequirePackage{tabularx}
\RequirePackage{multirow}
\RequirePackage{array}
\RequirePackage{booktabs}
\RequirePackage[table,xcdraw]{xcolor}
\RequirePackage[normalem]{ulem}
\useunder{\uline}{\ul}{}
\RequirePackage{float}


\RequirePackage[top=2cm,bottom=2cm,left=2cm,right=2cm]{geometry}
\RequirePackage{hyperref}
\RequirePackage{enumitem}
\RequirePackage{xkeyval}
\RequirePackage{ifthen}

%%%%package tikz%%%%

\RequirePackage{tikz}
\usetikzlibrary{mindmap}
\RequirePackage{chemfig}
\RequirePackage{pgfplots}
\pgfplotsset{compat=newest}

%%%%Forme%%%%

%Chapter form
\RequirePackage[Bjornstrup]{fncychap}

%Picture package
\RequirePackage{graphicx}
\RequirePackage{textcomp}
\RequirePackage{eurosym}
\RequirePackage{mwe}
\RequirePackage{listings}
\RequirePackage{etoolbox}
\RequirePackage{setspace}
\RequirePackage{ccaption}
\RequirePackage{colortbl}
\RequirePackage{framed}
\RequirePackage{xcolor}
%\RequirePackage{fourier}
\RequirePackage[pages=some]{background}

%Page de garde
\RequirePackage{pdfpages}


%%%%Math%%%%

\RequirePackage{mathtools}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage{mathrsfs}
\usetikzlibrary{arrows,matrix,positioning}
\usetikzlibrary{3d,calc}
\RequirePackage[makeroom]{cancel}
\RequirePackage{esint}

%%%%Annexe%%%%

\RequirePackage[toc,page]{appendix}
\linespread{1.5}
\renewcommand{\appendixtocname}{Annexes}
\renewcommand{\appendixpagename}{Annexes}

%%%%Couleurs%%%%


% ancienne couleur \definecolor{bleu}{rgb}{0.19, 0.55, 0.91}
% ancienne couleur \definecolor{rouge}{rgb}{0.77, 0.12, 0.23}

\definecolor{rouge}{rgb}{0.886, 0, 0.235}
\definecolor{bleu}{rgb}{0, 0.588, 0.823}
\definecolor{vert}{rgb}{0.13, 0.55, 0.13}
\definecolor{antiquefuchsia}{rgb}{0.57, 0.36, 0.51}
\definecolor{ocre}{RGB}{243,102,25}
\definecolor{apricot}{rgb}{0.98, 0.81, 0.69}

\colorlet{shadecolor}{cyan!30!white}
\colorlet{framecolor}{blue!50!black}

%%%%Custom command%%%%

\newcommand{\rouge}[1]{\textcolor{rouge}{#1}}
\newcommand{\bleu}[1]{\textcolor{bleu}{#1}}
\newcommand{\verts}[1]{\textcolor{vert}{#1}}

\makeatletter

%Keys for title page

%Encadrement
\usepackage[most]{tcolorbox}



\define@cmdkey [PRE] {fam} {title}{}
\define@cmdkey [PRE] {fam} {studies}{}
\define@cmdkey [PRE] {fam} {course}{}
\define@cmdkey [PRE] {fam} {author}{}
\define@cmdkey [PRE] {fam} {teacher}{}
\define@cmdkey [PRE] {fam} {date}{}
\define@cmdkey [PRE] {fam} {logo}{}
\define@cmdkey [PRE] {fam} {manyAuthor}[1]{}
%Set default value for the keys (used if not specified)
\presetkeys         [PRE] {fam} {title=titre,
								 studies=,
								 course=,
								 author=Auteurs,
								 teacher=,
								 date=,
								 logo=7,
                                 manyAuthor=8,}{}
\tikzset{vertical custom shading/.code={%
 \pgfmathsetmacro\tikz@vcs@middle{#1}
 \pgfmathsetmacro\tikz@vcs@bottom{\tikz@vcs@middle/2}
 \pgfmathsetmacro\tikz@vcs@top{(100-\tikz@vcs@middle)/2+\tikz@vcs@middle}
\pgfdeclareverticalshading[tikz@axis@top,tikz@axis@middle,tikz@axis@bottom]{newaxis}{100bp}{%
  color(0bp)=(tikz@axis@bottom);
  color(\tikz@vcs@bottom bp)=(tikz@axis@bottom);
  color(\tikz@vcs@middle bp)=(tikz@axis@middle);
  color(\tikz@vcs@top bp)=(tikz@axis@top);
  color(100bp)=(tikz@axis@top)}
  \pgfkeysalso{/tikz/shading=newaxis}
  }
}

% Title command
\newcommand*{\titleULB}[1]{\setkeys[PRE]{fam}{#1}

	\begingroup
	\BgThispage
	% Replace logo with nothing if not specified
	\ifthenelse{\equal{\cmdPRE@fam@logo}{7}}{}{\includegraphics[height=3cm,width=8cm,keepaspectratio]{\cmdPRE@fam@logo}\\}
	{\cmdPRE@fam@studies}
	\begin{center}
	\vspace*{\baselineskip}
	{\bfseries \cmdPRE@fam@course}\\[\baselineskip]
	\rule{\textwidth}{1.6pt}\vspace*{-\baselineskip}\vspace*{2pt}
	\rule{\textwidth}{0.4pt}\\[\baselineskip]
	{\LARGE \cmdPRE@fam@title}\\[\baselineskip]
	\rule{\textwidth}{0.4pt}\vspace*{-\baselineskip}\vspace{3.2pt}
	\rule{\textwidth}{1.6pt}\\[\baselineskip]
	\ifthenelse{\equal{\cmdPRE@fam@manyAuthor}{8}}{
	{\Large \cmdPRE@fam@author}\\[\baselineskip]
	{\bfseries \cmdPRE@fam@teacher}}{
	    \begin{minipage}{0.4\textwidth}
	        \begin{flushleft} \large
	        \cmdPRE@fam@author
	        \end{flushleft}
	    \end{minipage}
	    \begin{minipage}{0.4\textwidth}
	        \begin{flushright} \large
	        \cmdPRE@fam@teacher
	        \end{flushright}
	    \end{minipage}
	}
	\vfill
	{\cmdPRE@fam@date}
	\end{center}
	\vspace*{3\baselineskip}
	\pagenumbering{gobble}
	\newpage
	\tableofcontents
    \newpage
    \pagenumbering{arabic}
\endgroup}

% Fix on chapter overful hbox
\renewcommand{\DOCH}{%
    \settowidth{\py}{\CNoV\thechapter}%
    \addtolength{\py}{-10pt}%     % Amount of space by which the
%                                  % number is shifted right
    \fboxsep=0pt%
    \colorbox[gray]{.85}{\rule{0pt}{40pt}\parbox[b]{\textwidth}{\hfill}}%
\kern-\myhi
    \kern-\py\raise20pt%
    \hbox{\color[gray]{.5}\CNoV\thechapter}%
%\kern-\myhi
\\%
  }

%------
%Code trouvé sur https://www.mathematex.fr/viewtopic.php?t=9178 
%------

\makeatletter
\renewcommand{\DOTI}[1]{% pour format titre des chapter
    \nointerlineskip\raggedright%
    \fboxsep=\myhi%
    \vskip-1ex%
    \colorbox[gray]{.85}{\parbox[t]{\mylen}{\CTV\FmTi{#1}}}\par\nobreak%
    \vskip 35\p@%
  }

  \renewcommand{\DOTIS}[1]{% pour format titre des chapter*
    \fboxsep=0pt
    \colorbox[gray]{.85}{\rule{0pt}{40pt}\parbox[b]{\textwidth}{\hfill}}\\%
    \nointerlineskip\raggedright%
    \fboxsep=\myhi%
    \colorbox[gray]{.85}{\parbox[t]{\mylen}{\CTV\FmTi{#1}}}\par\nobreak%
    \vskip 35\p@%
  }

\def\@makechapterhead#1{%
  \vspace*{-20pt}% <------------- changement ici (était 50pt avant)
  {\parindent \z@ \raggedright \normalfont
    \ifnum \c@secnumdepth >\m@ne
      \if@mainmatter%%%%% Fix for frontmatter, mainmatter, and backmatter 040920
        \DOCH
      \fi
    \fi
    \interlinepenalty\@M
    \if@mainmatter%%%%% Fix for frontmatter, mainmatter, and backmatter 060424
      \DOTI{#1}%
    \else%
      \DOTIS{#1}%
    \fi
  }}
\makeatother
%Fin du code , si on l'enlève, il faut laisser un /makeatother
%\makeatother





\newpage
%Boxed environement
\newenvironment{frshaded*}{%
	\def\FrameCommand{\fboxrule=\FrameRule\fboxsep=\FrameSep \fcolorbox{framecolor}{shadecolor}}%
	\MakeFramed {\advance\hsize-\width \FrameRestore}}%
{\endMakeFramed}

%Command to put the seal of ULB in Background of the first page
\newcommand{\sceau}[1]{\backgroundsetup{
scale=1,
color=black,
opacity=0.05,
angle=10,
position={12cm,-22cm},
contents={%
  \includegraphics[height=20cm,width=20cm,keepaspectratio]{#1}
  }%
}}


%Création de remarque (TEST)
\RequirePackage[framemethod=default]{mdframed}
% Exercise box	  
\newmdenv[skipabove=7pt,
skipbelow=7pt,
rightline=false,
leftline=true,
topline=false,
bottomline=false,
backgroundcolor=ocre!10,
linecolor=ocre,
innerleftmargin=5pt,
innerrightmargin=5pt,
innertopmargin=5pt,
innerbottommargin=5pt,
leftmargin=0cm,
rightmargin=0cm,
linewidth=4pt]{rBox}
\newtheorem{exerciseT}{Remarque}[chapter]

\newenvironment{remarque}{\begin{rBox}\begin{exerciseT}}{\hfill{\color{ocre}\tiny\ensuremath{\blacksquare}}\end{exerciseT}\end{rBox}}	

%création de Attention
\RequirePackage[framemethod=default]{mdframed}
% Exercise box	  
\newmdenv[skipabove=7pt,
skipbelow=7pt,
rightline=false,
leftline=true,
topline=false,
bottomline=false,
backgroundcolor=rouge!10,
linecolor=rouge,
innerleftmargin=5pt,
innerrightmargin=5pt,
innertopmargin=5pt,
innerbottommargin=5pt,
leftmargin=0cm,
rightmargin=0cm,
linewidth=4pt]{aBox}
\newtheorem{attentionT}{Attention}[chapter]

\newenvironment{attention}{\begin{aBox}\begin{attentionT}}{\hfill{\color{rouge}\tiny\ensuremath{\blacksquare}}\end{attentionT}\end{aBox}}	



%Add small heading in the left corner of the page.
%\usepackage{fancyhdr}
%\pagestyle{fancy}
%\fancyhf{}

%\fancyhead[LO]{Travail d'initiation à la recherche}
%\fancyfoot[C,CO]{\leftmark}
%\fancyfoot[L,RO]{\thepage}
%\fancyfoot[C,CO]{\thepage}

%Add small heading in the left corner of the page.
%\pagestyle{headings}

%This is used to force the label alphabetic for the citation of biblio
% begin: excerpt from `alphabetic.bbx'
\DeclareFieldFormat{labelalphawidth}{\mkbibbrackets{#1}}
 
\defbibenvironment{bibliography}
   {\list
      {\printtext[labelalphawidth]{%
         \printfield{prefixnumber}%
     \printfield{labelalpha}%
         \printfield{extraalpha}}}
      {\setlength{\labelwidth}{\labelalphawidth}%
       \setlength{\leftmargin}{\labelwidth}%
       \setlength{\labelsep}{\biblabelsep}%
       \addtolength{\leftmargin}{\labelsep}%
       \setlength{\itemsep}{\bibitemsep}%
       \setlength{\parsep}{\bibparsep}}%
       \renewcommand*{\makelabel}[1]{##1\hss}}
   {\endlist}
   {\item}
% end: excerpt from `alphabetic.bbx'