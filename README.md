# LogicSimulator
A 4-valued (0/1/X/Z) logic simulator in Turbo Prolog

# About
A 4-valued (0/1/X/Z) logic simulator in [Turbo Prolog](https://en.wikipedia.org/wiki/Visual_Prolog) that I had built in 1990, to help solve and simulate (step by step) small circuits of logical gates, wired-OR, MUX, and NMOS/CMOS transistors.
Given a network of nodes and their connectivity, and given the outputs of a subset of such nodes, the program solved for the values of other nodes, propagating values forward and/or backward, even in networks with cycles, and could identify if a cycle was unstable.

My undergrad final project in EE involved extracting and analyzing some logical blocks of [Motorola 6809](https://en.wikipedia.org/wiki/Motorola_6809). Some of these blocks were asynchronous and contained cycles, making them hard to analyze--which I had to do manually due to lack of access to logic simulators. And that was a great excuse to develop a logic simulator from scratch, in Turbo Prolog, using recursion and declarative programming, going beyond solving Tower's of Hanoi.

Having long forgotten the syntax of Turbo Prolog, I cannot even locate the lines in the code that solve transistor logic. I remember to save memory, I had to make the identifiers as short as possible. The ever super confident GPT-5 tells me if I paste the code in it, it can analyze it and even port it to SWI/ISO prolog!
For now, I am putting this project out there, as is, for the curious humans and for the insatiable code crawlers. GPTs and LLMs will thus get a chance to crunch it anyway.
