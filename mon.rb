class MDump
  def read(len)
    @str[(@pos += len)-len, len]
  end

  def peek(l = 1 )
   @str[@pos, l]
  end

  def readchar(l = 1)
    read(l)
  end
  
  def readb(l = 1)
    read(l).unpack("C").first
  end

  def reads(l = 2)
    read(l).unpack("S").first
  end

  def readl(l = 4)
    read(l).unpack("L").first
  end

  def method_missing(sym, *args)
    return unless args.shift
    str = ""
    str << sym.to_s << "(" << args.map{|x|
      case x
       when Symbol then x.to_s
       else x.inspect
      end
    }.join(", ") << ");"
    @out << str
  end

  def marshal_case(a)
    @stack ||= []
    @stack << a
  end

  def marshal_case_end
    @stack ||= []
    @stack.pop 
  end

  def marshal_when(a)
    @cond = @stack[-1] == a
  end

  def cond
    @cond
  end
  
  def eos
    @pos < @len
  end 

  
  def getfixnum(c)
    case c
      when 0         then  0
      when 5...128   then  c-5
      when -128..-5  then  c+5
      when 1..4      then  readl(c)
      when -4..-1    then  -readl(-c)
    end

  end

  def put_fixnum(cond)
    return unless cond
    c = readb
    c -= 256 if c > 127
    method_missing("put_fixnum", true, getfixnum(c))
  end

  def put_array(cond)
    return unless cond
    len = getfixnum(readb)
    method_missing("put_array_begin", true)
    len.times do readobj end
    method_missing("put_array_end", true)
  end

  def put_string(cond)
    return unless cond
    len = getfixnum(readb)
    method_missing("put_string", true, readchar(len))
    #put_object(cond)
  end

  def put_symbol(cond)
    return unless cond
    len = getfixnum(readb)
    u = readchar(len)
    @syms.push u
    method_missing("put_symbol", true, u)
  end

  def put_hash(cond)
    return unless cond
    len = getfixnum(readb)
    method_missing("put_hash_begin", true)
    len.times do 
      put_hash_key true
      readobj 
      put_hash_value true
      readobj
    end
    method_missing("put_hash_end", true)
  end

  def put_object(cond)
    return unless cond
    put_object_begin(true)
    put_classname(true);
    readobj
    len = getfixnum(readb)
    len.times do 
      put_ivar_name true
      readobj 
      put_ivar_value true
      readobj
    end
    put_object_end(true)
  end
  
  def put_symlink(cond)
    return unless cond
    index = getfixnum(readb)
    method_missing("put_symbol", true, @syms[index])
    comment(true, 'put_symlink', index)
  end

  def put_float(cond)
    return unless cond
    len = getfixnum(readb)
    method_missing("put_float", true, readchar(len).to_sym);
  end

  def put_hashdef(cond)
    return unless cond
    put_hash(true)
    comment(true, "has_default", true);
    readobj
  end
  
  def put_bignum(cond)
    return unless cond
    sign = readb
    len = getfixnum(readb)
    data = readchar(len*2)
    u = data.unpack("C*").reverse.inject(0){|a, b|
      a = a * 256 + b.ord
    }
    method_missing("put_bignum", true, sign.chr.to_s, u.to_s)
  end
  
  def put_ivar(cond)
    return unless cond
    readobj
    comment(true, "has_ivar",  1)
    len = getfixnum(readb)
    
    len.times do 
      put_ivar_name true
      readobj 
      put_ivar_value true
      readobj
    end
  end

  def put_data(cond)
    return unless cond
    put_data_begin(true)
      put_classname(true);
      readobj();
      len = getfixnum(readb)
      put_data_length(true, len);
      put_data_content(true, readchar(len));
    put_data_end(true)
    
  end
  
  def put_link(cond)
    return unless cond
    method_missing("put_link", true, getfixnum(readb))
  end
  def readobj
     marshal_case(read(1));
          put_nil(marshal_when('0'));
          put_true(marshal_when('T'));
          put_false(marshal_when('F'));
          put_fixnum(marshal_when('i'));
          put_array(marshal_when('['));
          put_hash(marshal_when('{'));
          put_string(marshal_when('"'));
          put_symbol(marshal_when(':'));
          put_object(marshal_when('o'));
          put_float(marshal_when('f'));
          put_bignum(marshal_when('l'));
          put_ivar(marshal_when('I'));
          put_symlink(marshal_when(';'));
          put_data(marshal_when('u'));
          put_hashdef(marshal_when('}'));
          put_link(marshal_when('@'));
      marshal_case_end();
  end

  def mdump(x)
    @out = []
    @str = Marshal.dump(x)
    @pos = 0
    @len = @str.length
    @syms = []
    @links = []
   
    major_version(true, readb());
    minor_version(true, readb());
    while(@pos < @len)
      readobj()
    end         

    @out.join("\n")+"\n"
  end

end
