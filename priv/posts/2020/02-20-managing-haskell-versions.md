%{
  title: "Managing Haskell versions",
  author: "Daniel King",
  tags: ~w(software haskell),
  description: "The issues with using asdf to manage Haskell versions"
}
---
The need for a tool to manage language versions can be a little confusing for new developers, but as soon as you’re working professionally with legacy projects the need to have multiple versions of the same language installed becomes clear.

Projects built years apart will have different dependencies, each expecting different language runtimes. Manually managing different interpreters and build tools in your [path](https://en.wikipedia.org/wiki/PATH_(variable)) is painful, and just not practical.

As a Ruby user, my first exposure to language version managers was with RVM and rbenv. Eventually I moved to [chruby](//github.com/postmodern/chruby), a lightweight manager written in shell script, and it worked great for me for several years. However, when you being to work with multiple languages, each with their own version managers, the appeal of a single, modular tool becomes clear.

## asdf

[asdf](//asdf-vm.com) is that modular tool. I moved to it a couple of years ago for managing Ruby and Javascript versions, and would recommend it in most cases.

Until recently I had been using it for Haskell too, which was fine for my simple beginner projects. However, I have started to work on bigger projects with several dependencies, and to do this I’ve been using [Stack](//danielking.dev/posts/haskellstack.org/) build tool.

## Haskell, Stack and Cabal

Most tutorials will tell Haskellers to start with just GHC, the Haskell compiler. I think part of this comes out of the slightly messy story it has around tooling. As well as Stack which pulls packages from a repository called Stackage, there’s an older packaging tool called Cabal. Cabal is used by Stack, but it has its own package repository, and its own share of [issues](//en.wikipedia.org/wiki/Cabal_(software)#Criticism) around dependency management.


I’m still trying to understand the differences and best practice around packaging and managing dependencies.

This all recently led me to this error:

```
‘fail’ is not a (visible) method of class ‘Monad’
```

That line was highlighted in red, along with a few others, when I attempted to build a new Stack project with a lot of dependencies. It left me with a failing build, and Googling for answers offered few clues.

The error message suggested to pin the version of the “primitive” library, a dependency somewhere in the tree. I tried this and also tried to run the build with the `allow_new` flag set.

The issue came down to a detail I overlooked when installing Stack. Managing installed instances of GHC (the compiler) is one of Stack’s [main features](//docs.haskellstack.org/en/stable/GUIDE/#stacks-functions). So, when running `stack build` it was attempting to build with a particular version of Haskell (lts-12.26) as set in the “resolver” parameter, but asdf-haskell had filled my environment with references with a newer incompatible version.

**The problem was solved by removing asdf-haskell and just installing Stack directly.**

Even though [Stack’s FAQ](//docs.haskellstack.org/en/stable/faq/#where-is-stack-installed-and-will-it-interfere-with-ghc-etc-i-already-have-installed) says it shouldn’t affect any other installations of Haskell, it obviously can’t account for other tools interfering with its own build process.

## More options for building

I might have a clearer idea on managing installed versions of Haskell now, but I’m still trying to understand the best options for managing builds, there seem to be trade-offs with whatever you use.

I have noticed a few Haskell users prefer [Nix](//nixos.org/nix/), a purely functional package manager with its own language. I read through a few tutorials and might come back to it, but right now it doesn’t seem worth taking on along with learning Haskell.

Added to that there is also [Shake](//shakebuild.com/why), a make-like build too for Haskell, although it is not for managing dependencies itself it does have some crossover with Stack in features.

If you’re counting along that means we have Cabal, Stack, Nix, and if you include the built-in dependency tracking, GHC. So many options for tracking dependencies that I’m starting to miss the simplicity of Ruby gems.
