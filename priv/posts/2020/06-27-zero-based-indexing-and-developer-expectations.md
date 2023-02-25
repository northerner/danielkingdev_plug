%{
  title: "Zero-based indexing and developer expectations",
  author: "Daniel King",
  tags: ~w(software data-structures javascript ruby),
  description: "Thoughts on how data structures map to real world data models"
}
---
The array is one of the most common data structures in programming, in simple terms it is an indexed (ordered) collection of elements. They work differently depending on the language you’re writing, for example in C you define the types of all the elements up front, whereas in a dynamic language like JavaScript you can throw just about anything in there.

Because arrays are everywhere in software most developers quickly learn their behaviour and use them without much thought.

One common property of arrays across most languages is starting their indexing at zero, it can seem odd to new developers, but it’s just another behaviour you internalise and rarely think of again.

```
my_beatles_array = [“George”, “John”, “Paul”, “Ringo”]
my_beatles_array[0]
>> “George”
```

I recently needed a list of months to iterate over in Ruby, so I reached for the standard library and the [MONTHNAMES](//ruby-doc.org/stdlib-2.7.1/libdoc/date/rdoc/Date.html) array.

I did not read the documentation first as I just expected it to be a list of months, if I had read it I might have noticed the warning that it starts with nil.

The Ruby Date library designers are clearly thinking about use with indexing first, as opposed to the use of the whole list for iterating over. Padding the array with a nil makes each lookup match the month number.

```
Date::MONTHNAMES[1]
>> “January”

Date::MONTHNAMES[5]
>> “May”
```

This is a case where zero-indexing could seem confusing when mapped to a real-world concept, and I can see how you might want to design for the ergonomics of a month name lookup.

The designers of JavaScript took a different approach, call [getMonth()](//developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/getMonth) on a Date object and you’ll get a zero-indexed month.

Since you’re not dealing with an array directly in the JavaScript case you might expect months being zero-indexed to be even less likely, this is a function on the Date prototype. The API design here was showing a clear preference for zero indexing, even if January being month zero makes little sense outside of software.

I’m not sure there’s a right answer here, reflecting the real world in software always involves trade-offs, you just have to be consistent if you want to keep your language users happy.
