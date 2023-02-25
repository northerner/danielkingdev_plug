%{
  title: "Detecting slow plugins in Vim",
  author: "Daniel King",
  tags: ~w(software profiling vim ruby),
  description: "Debugging Vim performance issues"
}
---
Like most Vim/Neovim users I&#8217;ve built up a set of plugins and config files over the years that get the text editor customized for me. If you're interested in my current setup you can see it in my [dotfiles repo](//github.com/northerner/.dotfiles).

Since most of the time I'm adding a new plugin or setting individually, I can usually work out the culprit when Neovim starts running much slower. However, over the past few weeks I've had a [particular issue with eruby files](//github.com/neovim/neovim/issues/12562) and there was no obvious cause.

I thought commenting out recent changes to my config, including new plugins, would be a good start. Eventually I got down to loading with no plugins and the default config, but still the issue persisted.

This is where I went searching for help and discovered the the built-in profiling tool. It is really simple to run:

```
:profile start profile.log
:profile file *
:profile func *
[[ Trigger the slow action here ]]
:profile pause
```

Inspecting your generated log file will show a list of the slowest functions, at the top of the list for me was the cause of my slow eruby files.

```
FUNCTIONS SORTED ON TOTAL TIMEcount  total (s)   self (s)  function
    6  95.409081   0.015457  <SNR>14_LoadFTPlugin()
   80   0.321129   0.008854  airline#check_mode()
   16   0.305660   0.041821  airline#highlighter#highlight()
 1749   0.213133   0.108977  airline#highlighter#get_highlight()
  365   0.199579   0.019541  <SNR>82_exec_separator()
  819   0.191419   0.054809  airline#highlighter#exec()
   33   0.175094   0.002036  <SNR>112_NeoVimCallback()
   12   0.171814   0.001186  <SNR>108_ExitCallback()
   11   0.166302   0.001700  <SNR>107_HandleExit()
   11   0.155716   0.008071  ale#engine#HandleLoclist()
   12   0.108573   0.000808  airline#extensions#tabline#get()
   12   0.107765   0.002524  airline#extensions#tabline#buffers#get()
    6   0.101130   0.000250  ale#events#LintOnEnter()
    6   0.100799   0.000365  ale#Queue()
    6   0.099583   0.001838  <SNR>100_Lint()
    6   0.097989   0.003567  17()
  730   0.097386   0.010310  airline#themes#get_highlight()
   18   0.096341   0.017089  14()
    6   0.095190   0.002562  ale#engine#RunLinters()
 3498   0.088748             <SNR>82_get_syn()
```

95 seconds in one function!

```
93.687760 let &l:path = s:path . (s:path =~# ',$\|^$' ? '' : ',') . &l:path
```

Searching through the rest of the log even gave me the specific line of ftplugin/eruby.vim causing the issue. Unfortunately my vimscript knowledge is not up to fixing this, but commenting it out appears to be enough for now without any other side effects.

For more details on the profile feature there's a detailed help doc at `:help profile`, it can be limited to specific files too, useful if you're debugging your own config or a particular plugin.
