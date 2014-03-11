MON
===

MON is now on an alpha stage.

MON(Meta Object Notation) for Ruby. 'Meta' denotes the state careless about a certain language.

MON *partially* supports Marshal.dump format now. And generates results that can be a boilerplate code to many languages like JavaScript, i.e. it generates **runnable code** rather than **data** .(with specific functions pre-defined, which mainly beings with *put_*. See examples)

I'm not aimed to or not to support Rails. 



See examples below.


Examples
========

Array & Fixnum
--------------


```ruby
irb(main):001:0> print MDump.new.mdump [1,2,3,4,5]
major_version(4);
minor_version(8);
put_array_begin();
put_fixnum(1);
put_fixnum(2);
put_fixnum(3);
put_fixnum(4);
put_fixnum(5);
put_array_end();
=> nil
```

Hash
----

```ruby
irb(main):003:0> print MDump.new.mdump({1=>3, 2=>5})
major_version(4);
minor_version(8);
put_hash_begin();
put_hash_key();
put_fixnum(1);
put_hash_value();
put_fixnum(3);
put_hash_key();
put_fixnum(2);
put_hash_value();
put_fixnum(5);
put_hash_end();
=> nil

```

Simple Objects

```ruby
irb(main):004:0> a = Object.new
=> #<Object:0x1252a88>
irb(main):005:0> a.instance_eval {@a = 3; @b = 5}
=> 5
irb(main):006:0> print MDump.new.mdump(a)
major_version(4);
minor_version(8);
put_object_begin();
put_classname();
put_symbol("Object");
put_ivar_name();
put_symbol("@a");
put_ivar_value();
put_fixnum(3);
put_ivar_name();
put_symbol("@b");
put_ivar_value();
put_fixnum(5);
put_object_end();
=> nil
```


String with encodings:

E=true for UTF-8

E=false for US-ASCII

otherwise, 

  encoding="GBK" for GBK, etc.

```ruby
irb(main):009:0* print MDump.new.mdump("abc")
major_version(4);
minor_version(8);
put_string("abc");
comment("has_ivar", 1);
put_ivar_name();
put_symbol("E");
put_ivar_value();
put_true();
=> nil
```

Symbol, Bignum, Float

```ruby
irb(main):010:0> print MDump.new.mdump [:abc, 1111111111111111111111, 3.5]
major_version(4);
minor_version(8);
put_array_begin();
put_symbol("abc");
put_bignum("+", "1111111111111111111111");
put_float(3.5);
put_array_end();
=> nil
```
