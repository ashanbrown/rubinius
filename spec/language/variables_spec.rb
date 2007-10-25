require File.dirname(__FILE__) + '/../spec_helper'

describe "Basic assignment" do
  
  it "should allow the rhs to be assigned to the lhs" do
    a = nil;       a.should == nil
    a = 1;         a.should == 1
    a = [];        a.should == []
    a = [1];       a.should == [1]
    a = [nil];     a.should == [nil]
    a = [[]];      a.should == [[]]
    a = [1,2];     a.should == [1,2]
    a = [*[]];     a.should == []
    a = [*[1]];    a.should == [1]
    a = [*[1,2]];  a.should == [1, 2]
  end

  it "should allow the assignment of the rhs to the lhs using the rhs splat operator" do
    a = *nil;      a.should == nil
    a = *1;        a.should == 1
    a = *[];       a.should == nil
    a = *[1];      a.should == 1
    a = *[nil];    a.should == nil
    a = *[[]];     a.should == []
    a = *[1,2];    a.should == [1,2]
    a = *[*[]];    a.should == nil
    a = *[*[1]];   a.should == 1
    a = *[*[1,2]]; a.should == [1,2]
  end

  it "should allow the assignment of the rhs to the lhs using the lhs splat operator" do
    *a = nil;      a.should == [nil]
    *a = 1;        a.should == [1]
    *a = [];       a.should == [[]]
    *a = [1];      a.should == [[1]]
    *a = [nil];    a.should == [[nil]]
    *a = [[]];     a.should == [[[]]]
    *a = [1,2];    a.should == [[1,2]]
    *a = [*[]];    a.should == [[]]
    *a = [*[1]];   a.should == [[1]]
    *a = [*[1,2]]; a.should == [[1,2]]
  end
  
  it "should allow the assignment of rhs to the lhs using the lhs and rhs splat operators simultaneously" do
    *a = *nil;      a.should == [nil]
    *a = *1;        a.should == [1]
    *a = *[];       a.should == []
    *a = *[1];      a.should == [1]
    *a = *[nil];    a.should == [nil]
    *a = *[[]];     a.should == [[]]
    *a = *[1,2];    a.should == [1,2]
    *a = *[*[]];    a.should == []
    *a = *[*[1]];   a.should == [1]
    *a = *[*[1,2]]; a.should == [1,2]
  end

  it "should allow multiple values to be assigned" do
    a,b,*c = nil;       [a,b,c].should == [nil, nil, []]
    a,b,*c = 1;         [a,b,c].should == [1, nil, []]
    a,b,*c = [];        [a,b,c].should == [nil, nil, []]
    a,b,*c = [1];       [a,b,c].should == [1, nil, []]
    a,b,*c = [nil];     [a,b,c].should == [nil, nil, []]
    a,b,*c = [[]];      [a,b,c].should == [[], nil, []]
    a,b,*c = [1,2];     [a,b,c].should == [1,2,[]]
    a,b,*c = [*[]];     [a,b,c].should == [nil, nil, []]
    a,b,*c = [*[1]];    [a,b,c].should == [1, nil, []]
    a,b,*c = [*[1,2]];  [a,b,c].should == [1, 2, []]
    
    a,b,*c = *nil;      [a,b,c].should == [nil, nil, []]
    a,b,*c = *1;        [a,b,c].should == [1, nil, []]
    a,b,*c = *[];       [a,b,c].should == [nil, nil, []]
    a,b,*c = *[1];      [a,b,c].should == [1, nil, []]
    a,b,*c = *[nil];    [a,b,c].should == [nil, nil, []]
    a,b,*c = *[[]];     [a,b,c].should == [[], nil, []]
    a,b,*c = *[1,2];    [a,b,c].should == [1,2,[]]
    a,b,*c = *[*[]];    [a,b,c].should == [nil, nil, []]
    a,b,*c = *[*[1]];   [a,b,c].should == [1, nil, []]
    a,b,*c = *[*[1,2]]; [a,b,c].should == [1, 2, []]
  end
  
  it "should allow assignment through lambda" do
    f = lambda {|r,| r.should == []}
    f.call([], *[])

    f = lambda {|r,*l| r.should == []; l.should == [1]}
    f.call([], *[1])

    f = lambda{|x| x}
    f.call(42).should == 42
    f.call([42]).should == [42]
    f.call([[42]]).should == [[42]]
    f.call([42,55]).should == [42,55]

    f = lambda{|x,| x}
    f.call(42).should == 42
    f.call([42]).should == [42]
    f.call([[42]]).should == [[42]]
    f.call([42,55]).should == [42,55]

    f = lambda{|*x| x}
    f.call(42).should == [42]
    f.call([42]).should == [[42]]
    f.call([[42]]).should == [[[42]]]
    f.call([42,55]).should == [[42,55]]
    f.call(42,55).should == [42,55]
  end
  
  it 'should allow chained assignment' do
    (a = 1 + b = 2 + c = 4 + d = 8).should == 15
    d.should == 8
    c.should == 12
    b.should == 14
    a.should == 15
  end
end

describe "Assignment using expansion" do
  
  it "should succeed without conversion" do
    *x = (1..7).to_a
    x.should == [[1, 2, 3, 4, 5, 6, 7]]
  end
  
end

describe "Assigning multiple values" do
  
  it "should allow parallel assignment" do
    a, b = 1, 2
    a.should == 1
    b.should == 2

    a, = 1,2
    a.should == 1
  end
  
  it "should allow safe parallel swapping" do
    a, b = 1, 2
    a, b = b, a
    a.should == 2
    b.should == 1
  end

  it "should bundle remaining values to an array when using the splat operator" do
    a, *b = 1, 2, 3
    a.should == 1
    b.should == [2, 3]
    
    *a = 1, 2, 3
    a.should == [1, 2, 3]
    
    *a = 4
    a.should == [4]
    
    *a = nil
    a.should == [nil]
    
    a,=*[1]
    a.should == 1
    a,=*[[1]]
    a.should == [1]
    a,=*[[[1]]]
    a.should == [[1]]
  end
    
  it "should allow complex parallel assignment" do
    a, (b, c), d = 1, [2, 3], 4
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4
    
    x, (y, z) = 1, 2, 3
    [x,y,z].should == [1,2,nil]
    x, (y, z) = 1, [2,3]
    [x,y,z].should == [1,2,3]
    x, (y, z) = 1, [2]
    [x,y,z].should == [1,2,nil]
  end
  
end

describe "Conditional assignment" do

  it "should assign the lhs if previously unassigned" do
    a=[]
    a[0] ||= "bar"
    a[0].should == "bar"

    h={}
    h["foo"] ||= "bar"
    h["foo"].should == "bar"

    h["foo".to_sym] ||= "bar"
    h["foo".to_sym].should == "bar"

    aa = 5
    aa ||= 25
    aa.should == 5

    bb ||= 25
    bb.should == 25

    cc &&=33
    cc.should == nil

    cc = 5
    cc &&=44
    cc.should == 44
  end
  
end

class OpAsgn
  attr_accessor :a, :side_effect
  def do_side_effect; self.side_effect = true; return @a; end
end

describe "Operator assignment 'var op= expr'" do
  it "is equivalent to 'var = var op expr'" do
    x = 13
    (x += 5).should == 18
    x.should == 18

    x = 17
    (x -= 11).should == 6
    x.should == 6

    x = 2
    (x *= 5).should == 10
    x.should == 10

    x = 36
    (x /= 9).should == 4
    x.should == 4

    x = 23
    (x %= 5).should == 3
    x.should == 3
    (x %= 3).should == 0
    x.should == 0

    x = 2
    (x **= 3).should == 8
    x.should == 8

    x = 4
    (x |= 3).should == 7
    x.should == 7
    (x |= 4).should == 7
    x.should == 7

    x = 6
    (x &= 3).should == 2
    x.should == 2
    (x &= 4).should == 0
    x.should == 0

    # XOR
    x = 2
    (x ^= 3).should == 1
    x.should == 1
    (x ^= 4).should == 5
    x.should == 5

    # Bit-shift left
    x = 17
    (x <<= 3).should == 136
    x.should == 136

    # Bit-shift right
    x = 5
    (x >>= 1).should == 2
    x.should == 2

    x = nil
    (x ||= 17).should == 17
    x.should == 17
    (x ||= 2).should == 17
    x.should == 17

    x = false
    (x &&= true).should == false
    x.should == false
    (x &&= false).should == false
    x.should == false
    x = true
    (x &&= true).should == true
    x.should == true
    (x &&= false).should == false
    x.should == false
  end
  
  it "uses short-circuit arg evaluation for operators ||= and &&=" do
    x = 8
    y = OpAsgn.new
    (x ||= y.do_side_effect).should == 8
    y.side_effect.should == nil
    
    x = nil
    (x &&= y.do_side_effect).should == nil
    y.side_effect.should == nil

    y.a = 5
    (x ||= y.do_side_effect).should == 5
    y.side_effect.should == true
  end
end

describe "Operator assignment 'obj.meth op= expr'" do
  it "is equivalent to 'obj.meth = obj.meth op expr'" do
    @x = OpAsgn.new
    @x.a = 13
    (@x.a += 5).should == 18
    @x.a.should == 18

    @x.a = 17
    (@x.a -= 11).should == 6
    @x.a.should == 6

    @x.a = 2
    (@x.a *= 5).should == 10
    @x.a.should == 10

    @x.a = 36
    (@x.a /= 9).should == 4
    @x.a.should == 4

    @x.a = 23
    (@x.a %= 5).should == 3
    @x.a.should == 3
    (@x.a %= 3).should == 0
    @x.a.should == 0

    @x.a = 2
    (@x.a **= 3).should == 8
    @x.a.should == 8

    @x.a = 4
    (@x.a |= 3).should == 7
    @x.a.should == 7
    (@x.a |= 4).should == 7
    @x.a.should == 7

    @x.a = 6
    (@x.a &= 3).should == 2
    @x.a.should == 2
    (@x.a &= 4).should == 0
    @x.a.should == 0

    # XOR
    @x.a = 2
    (@x.a ^= 3).should == 1
    @x.a.should == 1
    (@x.a ^= 4).should == 5
    @x.a.should == 5

    @x.a = 17
    (@x.a <<= 3).should == 136
    @x.a.should == 136

    @x.a = 5
    (@x.a >>= 1).should == 2
    @x.a.should == 2

    @x.a = nil
     (@x.a ||= 17).should == 17
    @x.a.should == 17
    (@x.a ||= 2).should == 17
    @x.a.should == 17

    @x.a = false
    (@x.a &&= true).should == false
    @x.a.should == false
    (@x.a &&= false).should == false
    @x.a.should == false
    @x.a = true
    (@x.a &&= true).should == true
    @x.a.should == true
    (@x.a &&= false).should == false
    @x.a.should == false
  end
  
  it "uses short-circuit arg evaluation for operators ||= and &&=" do
    x = 8
    y = OpAsgn.new
    (x ||= y.do_side_effect).should == 8
    y.side_effect.should == nil
    
    x = nil
    (x &&= y.do_side_effect).should == nil
    y.side_effect.should == nil

    y.a = 5
    (x ||= y.do_side_effect).should == 5
    y.side_effect.should == true
  end
end

describe "Operator assignment 'obj[idx] op= expr'" do
  it "is equivalent to 'obj[idx] = obj[idx] op expr'" do
    x = [2,13,7]
    (x[1] += 5).should == 18
    x.should == [2,18,7]

    x = [17,6]
    (x[0] -= 11).should == 6
    x.should == [6,6]

    x = [nil,2,28]
    (x[2] *= 2).should == 56
    x.should == [nil,2,56]

    x = [3,9,36]
    (x[2] /= x[1]).should == 4
    x.should == [3,9,4]

    x = [23,4]
    (x[0] %= 5).should == 3
    x.should == [3,4]
    (x[0] %= 3).should == 0
    x.should == [0,4]

    x = [1,2,3]
    (x[1] **= 3).should == 8
    x.should == [1,8,3]

    x = [4,5,nil]
    (x[0] |= 3).should == 7
    x.should == [7,5,nil]
    (x[0] |= 4).should == 7
    x.should == [7,5,nil]

    x = [3,6,9]
    (x[1] &= 3).should == 2
    x.should == [3,2,9]
    (x[1] &= 4).should == 0
    x.should == [3,0,9]

    # XOR
    x = [0,1,2]
    (x[2] ^= 3).should == 1
    x.should == [0,1,1]
    (x[2] ^= 4).should == 5
    x.should == [0,1,5]

    x = [17]
    (x[0] <<= 3).should == 136
    x.should == [136]

    x = [nil,5,8]
    (x[1] >>= 1).should == 2
    x.should == [nil,2,8]

    x = [1,nil,12]
    (x[1] ||= 17).should == 17
    x.should == [1,17,12]
    (x[1] ||= 2).should == 17
    x.should == [1,17,12]
  
    x = [true, false, false]
    (x[1] &&= true).should == false
    x.should == [true, false, false]
    (x[1] &&= false).should == false
    x.should == [true, false, false]
    (x[0] &&= true).should == true
    x.should == [true, false, false]
    (x[0] &&= false).should == false
    x.should == [false, false, false]
  end

  it "uses short-circuit arg evaluation for operators ||= and &&=" do
    x = 8
    y = OpAsgn.new
    (x ||= y.do_side_effect).should == 8
    y.side_effect.should == nil
    
    x = nil
    (x &&= y.do_side_effect).should == nil
    y.side_effect.should == nil

    y.a = 5
    (x ||= y.do_side_effect).should == 5
    y.side_effect.should == true
  end

  it "handles complex index (idx) arguments" do
    x = [1,2,3,4]
    (x[0,2] += [5]).should == [1,2,5]
    x.should == [1,2,5,3,4]
    (x[0,2] += [3,4]).should == [1,2,3,4]
    x.should == [1,2,3,4,5,3,4]
    
    (x[2..3] += [8]).should == [3,4,8]
    x.should == [1,2,3,4,8,5,3,4]
    
    y = OpAsgn.new
    y.a = 1
    (x[y.do_side_effect] *= 2).should == 4
    x.should == [1,4,3,4,8,5,3,4]
    
    h = {'key1' => 23, 'key2' => 'val'}
    (h['key1'] %= 5).should == 3
    (h['key2'] += 'ue').should == 'value'
    h.should == {'key1' => 3, 'key2' => 'value'}
  end
end

describe 'Single assignment' do
  it 'Assignment does not modify the lhs, it reassigns its reference' do
    a = 'Foobar'
    b = a
    b = 'Bazquux'
    a.should == 'Foobar'
    b.should == 'Bazquux'
  end

  it 'Assignment does not copy the object being assigned, just creates a new reference to it' do
    a = []
    b = a
    b << 1
    a.should == [1]
  end

  it 'If rhs has multiple arguments, lhs becomes an Array of them' do
    a = 1, 2, 3
    a.should == [1, 2, 3]
  end
end

describe 'Multiple assignment without grouping or splatting' do
  it 'An equal number of arguments on lhs and rhs assigns positionally' do
    a, b, c, d = 1, 2, 3, 4
    a.should == 1
    b.should == 2
    c.should == 3
    d.should == 4
  end 

  it 'If rhs has too few arguments, the missing ones on lhs are assigned nil' do
    a, b, c = 1, 2
    a.should == 1
    b.should == 2
    c.should == nil
  end

  it 'If rhs has too many arguments, the extra ones are silently not assigned anywhere' do
    a, b = 1, 2, 3
    a.should == 1
    b.should == 2
  end

  it 'The assignments are done in parallel so that lhs and rhs are independent of eachother without copying' do
    o_of_a, o_of_b = Object.new, Object.new
    a, b = o_of_a, o_of_b
    a, b = b, a
    a.equal?(o_of_b).should == true
    b.equal?(o_of_a).should == true
  end
end

describe 'Multiple assignments with splats' do
  # TODO make this normal once rubinius eval works
  compliant :mri do
    it '* on the lhs has to be applied to the last parameter' do
      should_raise(SyntaxError) { eval 'a, *b, c = 1, 2, 3' }
    end
  end

  it '* on the lhs collects all parameters from its position onwards as an Array or an empty Array' do
    a, *b = 1, 2
    c, *d = 1
    e, *f = 1, 2, 3
    g, *h = 1, [2, 3]
    *i = 1, [2,3]
    *j = [1,2,3]
    *k = 1,2,3

    a.should == 1
    b.should == [2]
    c.should == 1
    d.should == []
    e.should == 1
    f.should == [2, 3]
    g.should == 1
    h.should == [[2, 3]]
    i.should == [1, [2, 3]]
    j.should == [[1,2,3]]
    k.should == [1,2,3]
  end
end

describe 'Multiple assignments with grouping' do
  it 'A group on the lhs is considered one position and treats its corresponding rhs position like an Array' do
    a, (b, c), d = 1, 2, 3, 4
    e, (f, g), h = 1, [2, 3, 4], 5
    i, (j, k), l = 1, 2, 3
    a.should == 1
    b.should == 2
    c.should == nil
    d.should == 3
    e.should == 1
    f.should == 2
    g.should == 3
    h.should == 5
    i.should == 1
    j.should == 2
    k.should == nil
    l.should == 3
  end

  compliant :mri do
    it 'rhs cannot use parameter grouping, it is a syntax error' do
      should_raise(SyntaxError) { eval '(a, b) = (1, 2)' }
    end
  end
end

def reverse_foo(a,b);return b,a;end

describe "Multiple assignment" do
  it "should have the proper return value" do
    (a,b,*c = *[5,6,7,8,9,10]).should == [5,6,7,8,9,10]
    (d,e = reverse_foo(4,3)).should == [3,4]
    (f,g,h = reverse_foo(6,7)).should == [7,6]
    (i,*j = *[5,6,7]).should == [5,6,7]
    (k,*l = [5,6,7]).should == [5,6,7]
    a.should == 5
    b.should == 6
    c.should == [7,8,9,10]
    d.should == 3
    e.should == 4
    f.should == 7
    g.should == 6
    h.should == nil
    i.should == 5
    j.should == [6,7]
    k.should == 5
    l.should == [6,7]
  end
end

describe "Multiple assignment, array-style" do
  it "should have the proper return value" do
    (a,b = 5,6,7).should == [5,6,7]
    a.should == 5
    b.should == 6

    (c,d,*e = 99,8).should == [99,8]
    c.should == 99
    d.should == 8
    e.should == []

    (f,g,h = 99,8).should == [99,8]
    f.should == 99
    g.should == 8
    h.should == nil
  end
end

