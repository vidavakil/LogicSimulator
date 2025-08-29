@ 2025 Vida Vakilotojar

/* examples\log100.pro */
/*trace	op,op1,op2,op3,op4,op5,fire,run*/
code=3000
domains
	file=outfile;con;prn
	input=i(integer);c(char);w(integer)
	inputlist=input*
	intlist=integer*
database
	y(intlist)
	s(intlist)
	o(integer,char)
	last(integer,char)
	node(integer,symbol,inputlist,intlist)
	l(intlist)
	in(integer,intlist,char)

predicates
	gate(integer,symbol,inputlist,char)
	g_and(integer,char,char)
	g_or(integer,char,char)
	g_nand(integer,char,char)
	g_nor(integer,char,char)
	g_not(integer,char,char)		    	
	g_mux(integer,char,char)
	op(integer,char)
	op1(integer,symbol,inputlist,char)
	op2(integer,char)
	op4(integer,char)
	op5(integer,char)
/*	prop(intlist,char)*/
	list(integer,intlist)
	run(intlist)	
	del(integer,intlist,intlist)
	delall(integer,intlist,intlist)
	append(integer,intlist,intlist)
	app(input,inputlist,inputlist)
  	next(integer,char)
	next1(integer,char)
	check(integer)
	pop(integer,intlist)
	delet(intlist)
	proces(inputlist)
	op3(integer,char)
	prop1(intlist,input,input)
	popx
	popy(integer)
	replace(input,input,inputlist,inputlist)
	find(integer,intlist)
	less(integer,intlist)
	result(integer)
	go(integer,char)
	fire
	repeat
	answr(integer,char)
	neg(char,char)
	writeto(integer,char)
	initial
	init(integer,intlist,char)
	release
/*	test	*/

goal
/*	write("Topology File : "),readln(Top),*/
	write("Input File    : "),readln(Inp),
/*	write("State File    : "),readln(Stt),*/
/*	write("No. of nodes  : "),readint(Num),*/
/*	consult(Top),consult(Inp),consult(Stt),*/
	consult("not.pro"),consult("not1.pro"),consult(Inp),
	openwrite(outfile,"not1.pro"),openwrite(con,"CON"),	
	openwrite(prn,"prn"),writedevice(prn),
	not(initial),
	list(3,[]),asserta(s([])),asserta(y([-1])),
	time(A,B,C,D),fire,
	time(E,F,G,H),result(3),release,
	write(A,':',B,':',C,':',D),nl,
	write(E,':',F,':',G,':',H),nl,
	closefile(outfile).
clauses

	release:-retract(node(_,_,_,_)),fail,!.
	release:-retract(last(_,_)),fail,!.
	release:-retract(s(_)),retract(y(_)),retract(l(_)),!.

/*	test:-retract(node(J,T,I,O)),X=node(J,T,I,O),write(X),*/
/*	      nl,test,asserta(node(J,T,I,O)),!.*/
/*	test:-retract(o(A,B)),T=o(A,B),write(T),nl,test,*/
/*	      asserta(o(A,B)),!.*/
/*	test:-retract(y(A)),T1=y(A),write(T1),asserta(y(A)),*/
/*	      retract(s(B)),T2=s(B),write(T2),asserta(s(B)),*/
/*	      retract(l(C)),T3=l(C),write(T3),asserta(l(C)),*/
/*	      nl,!.*/

	initial:-retract(in(I,L,C)),init(I,L,C),fail.
	
	init(_,[],_):-!.
	init(I,[A|B],C):-retract(node(A,Type,L,O)),replace(c(C),w(I),L,L1),
			 asserta(node(A,Type,L1,O)),init(I,B,C),!.
	repeat.
	repeat:-repeat.
	
	fire:-repeat,l(Y),run(Y).   /*test*/

	result(0):-!.
	result(I):-o(I,'Z'),retract(o(I,'Z')),last(I,Z),
		   writeto(I,Z),I1=I-1,result(I1),!.
	result(I):-retract(o(I,B)),writeto(I,B),
		   I1=I-1,result(I1),!.
	result(I):-writeto(I,'X'),I1=I-1,result(I1),!.
			   
	writeto(A,B):-T=last(A,B),writedevice(outfile),write(T),nl,writedevice(con),
		    write(T),nl,!.

	run([]):-!.
	run([A|_]):-node(A,Type,I,O),asserta(node(A,Type,I,O)),
		    op(A,B),op2(A,B),l(Y),!,less(A,Y).
	
	append(A,[],[A]):-!.
	append(A,[B|X],Y):-append(A,X,Y1),
			   Y=[B|Y1],!.
	app(A,[],[A]):-!.
	app(A,[B|X],Y):-app(A,X,Y1),Y=[B|Y1],!.
	
	list(0,Y):-asserta(l(Y)),!.
	list(I,Y):-I1=I-1,list(I1,[I|Y]),!.

	delall(_,[],[]):-!.	
	delall(A,[A|X],Y):-delall(A,X,Y),!.
	delall(A,[B|X],Y):-delall(A,X,Y1),delall(A,Y1,Y2),Y=[B|Y2],!.
	
	del(_,[],[]):-!.
	del(A,[A|X],X):-!.
	del(A,[B|X],Y):-del(A,X,Y1),Y=[B|Y1],!.

	check(A):-o(A,_),!.
	check(A):-node(A,_,[i(I)|_],_),I<>0,!,fail.
	check(A):-node(A,_,[c(_)|_],_),!,fail.
	check(A):-node(A,Type,I,O),asserta(node(A,Type,I,O)),!.
	
	op(A,B):-o(A,B),!.
	op(A,B):-retract(node(A,Type,[_|Inp],O)),
		 asserta(node(A,Type,Inp,O)),
		 op1(A,Type,Inp,B),go(A,B),!.
	
	go(A,B):-not(o(A,B)),asserta(o(A,B)),
		 retract(node(A,_,_,_)),retract(y(X)),
		 asserta(y([A|X])),!.
	go(_,_):-!.
	
	op1(A,_,[c('X')|_],B):-node(A,_,I1,_),
	     		       proces(I1),answr(A,B),!.
	op1(A,Type,Inp,B):-gate(A,Type,Inp,B),!.
	

	op2(A,'X'):-retract(y(Z)),pop(-1,Z),retract(l(Y)),del(A,Y,Y1),
		    append(A,Y1,Y2),asserta(l(Y2)),retract(s(_)),asserta(s([])),!.
	op2(_,_):-retract(s(_)),asserta(s([])),retract(y(Z)),delet(Z),!.

/*	prop([],_):-!.*/
/*	prop([X|Y],'0'):-node(X,"and",_,_),op2(X,'0'),prop(Y,'0'),!.*/
/*	prop([X|Y],'0'):-node(X,"not",_,_),op2(X,'1'),prop(Y,'0'),!.*/
/*	prop([_|Y],'0'):-prop(Y,'0'),!.*/
/*	prop([X|Y],'1'):-node(X,"or",_,_),op2(X,'1'),prop(Y,'1'),!.*/
/*	prop([X|Y],'1'):-node(X,"not",_,_),op2(X,'0'),prop(Y,'1'),!.*/
/*	prop([_|Y],'1'):-prop(Y,'1'),!.	*/
		
	gate(_,"and",[],'1'):-!.
	gate(_,"and",[c('0')|_],'0'):-!.	 
	gate(B,"and",[c('1')|_],Z):-op(B,Z),!.
	gate(B,"and",[i(A)|_],S):-check(A),op(A,Z),g_and(B,S,Z),!.
	gate(B,"and",_,S):-next(B,S),!.

	gate(_,"nand",[],'0'):-!.
	gate(_,"nand",[c('0')|_],'1'):-!.	 
	gate(B,"nand",[c('1')|_],Z):-op(B,Z),!.
	gate(B,"nand",[i(A)|_],S):-check(A),op(A,Z),g_nand(B,S,Z),!.
	gate(B,"nand",_,S):-next(B,S),!.	

	gate(_,"or",[],'0'):-!.
	gate(_,"or",[c('1')|_],'1'):-!.
	gate(B,"or",[c('0')|_],Z):-op(B,Z),!.
	gate(B,"or",[i(A)|_],S):-check(A),op(A,Z),g_or(B,S,Z),!.
	gate(B,"or",_,S):-next(B,S),!.	
	
	gate(_,"nor",[],'1'):-!.
	gate(_,"nor",[c('1')|_],'0'):-!.
	gate(B,"nor",[c('0')|_],Z):-op(B,Z),!.
	gate(B,"nor",[i(A)|_],S):-check(A),op(A,Z),g_nor(B,S,Z),!.
	gate(B,"nor",_,S):-next(B,S),!.	
	
	gate(_,"not",[c('0')|_],'1'):-!.
	gate(_,"not",[c('1')|_],'0'):-!.
	gate(B,"not",[i(A)|_],S):-check(A),op(A,Z),g_not(B,S,Z),!.
	gate(B,"not",_,S):-next(B,S),!.
	
	gate(_,"pas",[c('0')|_],'Z'):-!.
	gate(B,"pas",[c('Z')|C],Z):-node(B,"pas",[i(A)|C],_),
				    last(A,S),gate(B,"pas",[c(S)|C],Z),!.
	gate(_,"pas",[c('1'),c(I)],I):-!.
	gate(_,"pas",[c('1'),i(A)],Z):-check(A),op(A,Z),!.
	gate(_,"pas",[c('1'),i(A)],'X'):-retract(s(Z)),asserta(s([A|Z])),!.
	gate(B,"pas",[i(A),C],Z):-check(A),op(A,S),
			          gate(B,"pas",[c(S),C],Z),!.
	gate(_,"pas",[i(A)|_],'X'):-retract(s(Z)),asserta(s([A|Z])),!.

	gate(_,"mux",[c('Y')|_],'1'):-!.
	gate(_,"mux",[],'Z'):-!.
	gate(_,"mux",[c('0')|_],'0'):-!.	 
	gate(B,"mux",[c('1')|_],Z):-retract(node(B,X,Y,O)),
				    app(c('Y'),Y,Y1),
				    asserta(node(B,X,Y1,O)),op(B,Z),!.
	gate(B,"mux",[i(A)|_],S):-check(A),op(A,Z),g_mux(B,S,Z),!.
	gate(B,"mux",_,S):-next(B,S),!.
	
	g_and(B,S,_):-o(B,S),!.
	g_and(B,S,'Z'):-node(B,_,[i(A)|_],_),last(A,Z),g_and(B,S,Z),!.
	g_and(_,'0','0'):-!.
	g_and(B,S,'1'):-op(B,S),!.
	g_and(B,S,'X'):-next1(B,S),!.

	g_nand(B,S,_):-o(B,S),!.
	g_nand(B,S,'Z'):-node(B,_,[i(A)|_],_),last(A,Z),g_nand(B,S,Z),!.
	g_nand(_,'1','0'):-!.
	g_nand(B,S,'1'):-op(B,S),!.
	g_nand(B,S,'X'):-next1(B,S),!.	
	
	g_or(B,S,_):-o(B,S),!.
	g_or(B,S,'Z'):-node(B,_,[i(A)|_],_),last(A,Z),g_or(B,S,Z),!.
	g_or(_,'1','1'):-!.
	g_or(B,S,'0'):-op(B,S),!.
	g_or(B,S,'X'):-next1(B,S),!.
	
	g_nor(B,S,_):-o(B,S),!.
	g_nor(B,S,'Z'):-node(B,_,[i(A)|_],_),last(A,Z),g_nor(B,S,Z),!.
	g_nor(_,'0','1'):-!.
	g_nor(B,S,'0'):-op(B,S),!.
	g_nor(B,S,'X'):-next1(B,S),!.

	g_not(_,'0','1'):-!.
	g_not(B,S,'Z'):-node(B,_,[i(A)|_],_),last(A,Z),g_not(B,S,Z),!.
	g_not(_,'1','0'):-!.	  	
	g_not(B,S,'X'):-next1(B,S),!.

	g_mux(B,S,_):-o(B,S),!.
	g_mux(B,S,'Z'):-op(B,S),!.
	g_mux(_,'0','0'):-!.
	g_mux(B,S,'1'):-retract(node(B,X,Y,O)),app(c('Y'),Y,Y1),
			asserta(node(B,X,Y1,O)),op(B,S),!.
	g_mux(B,S,'X'):-next1(B,S),!.
	
	next(B,S):-retract(node(B,X,[I|Y],O)),app(c('X'),Y,Y1),
		   app(I,Y1,Y2),
	           asserta(node(B,X,[I|Y2],O)),
	           op(B,S),!.

	next1(B,S):-retract(node(B,X,Y,O)),app(c('X'),Y,Y1),
		    asserta(node(B,X,Y1,O)),op(B,S),!.
		    
	proces([]):-!.
	proces([c('X')|Y]):-proces(Y),!.
	proces([i(A)|Y]):-retract(s(Z)),
		           asserta(s([A|Z])),proces(Y),!.
		           
	answr(A,B):-op3(A,B),!.
	answr(A,B):-op4(A,B),!.
	answr(A,B):-op5(A,B),!.

	op3(A,'X'):-s(Y),not(find(A,Y)),!.
	op3(A,B):-not(popx),retract(y(G)),asserta(y([0|G])),retract(node(A,_,_,_)),
		  retract(s(Y)),delall(A,Y,Y1),asserta(s(Y1)),node(A,_,_,O),
		  last(A,W),		  
		  prop1(O,c(W),i(A)),node(A,Type,I,O),asserta(node(A,Type,I,O)),
		  op(A,C),prop1(O,i(A),c(W)),!,C=W,B=W,
		  retract(y(K)),del(0,K,K1),asserta(y(K1)),!.

	op4(A,B):-retract(y(Z)),pop(0,Z),node(A,_,_,O),
	          last(A,W),neg(W,U),prop1(O,c(U),i(A)),
		  node(A,Type,I,O),asserta(node(A,Type,I,O)),
		  op(A,C),prop1(O,i(A),c(U)),!,C=U,B=U,
		  retract(y(K)),del(0,K,K1),asserta(y(K1)),!.

	op5(A,'X'):-retract(y(Z)),pop(0,Z),
		    node(A,Type,I,O),asserta(node(A,Type,I,O)),retract(y(K)),
		    del(0,K,K1),asserta(y(K1)),!.
	
	replace(A,B,[B|Z],[A|Z]):-!.
	replace(A,B,[C|Z],Y):-replace(A,B,Z,Y1),Y=[C|Y1],!.
	
	prop1([],_,_):-!.
	prop1([X|Y],i(A),W):-retract(node(X,"pas",_,_)),
			     prop1(Y,i(A),W),!.
	prop1([X|Y],A,i(W)):-node(X,"pas",I1,O),replace(A,i(W),I1,I2),
			     asserta(node(X,"pas",I2,O)),prop1(Y,A,i(W)),!.
	prop1([X|Y],A,W):-retract(node(X,Type,I1,O)),replace(A,W,I1,I2),
			  asserta(node(X,Type,I2,O)),prop1(Y,A,W),!.
			
	popx:-retract(o(A,'X')),popy(A),fail,!.
	popy(A):-retract(y(Z)),delall(A,Z,Z1),asserta(y(Z1)),!.
	
	find(_,[]):-!,fail.
	find(I,[I|_]):-!.
	find(I,[_|X]):-find(I,X),!.
	
	pop(I,[I|B]):-asserta(y([I|B])),!.
	pop(I,[A|B]):-retract(o(A,_)),pop(I,B),!.
	
	delet([0|Y]):-retract(o(0,_)),delet(Y),!.
	delet([-1]):-asserta(y([-1])),!.
	delet([A|Y]):-o(A,'X'),retract(o(A,'X')),delet(Y),!.
	delet([A|Y]):-retract(l(Z)),del(A,Z,Z1),
		      asserta(l(Z1)),delet(Y),!.       

	less(_,[]):-!.
	less(A,[B|_]):-A<B,!,fail.
	less(_,_):-!.       				
	
	neg('0','1'):-!.
	neg('1','0'):-!.
	neg(Z,Z):-!.
