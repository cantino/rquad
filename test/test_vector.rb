#!/usr/bin/env ruby
# SOFTWARE INFO
#
# This file is part of the quadtree.rb Ruby quadtree library, distributed 
# subject to the 'MIT License' below.  This software is available for 
# download at http://iterationlabs.com/free_software/quadtree.
#
# If you make modifications to this software and would be willing to 
# contribute them back to the community, please send them to us for 
# possible inclusion in future releases!
#
# LICENSE
#  
# Copyright (c) 2008, Iteration Labs, LLC, http://iterationlabs.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 

require 'test/unit'
require 'fileutils'
require File.dirname(__FILE__) + '/../lib/vector'

class TestVector < Test::Unit::TestCase
  def test_new_vector
    assert_equal nil, Vector.new.x
    assert_equal nil, Vector.new.y
    assert_equal nil, Vector.new.z
    
    v = Vector.new(1, 2, 3)
    v2 = Vector.new(v)
    assert_equal 1, v2.x
    assert_equal 2, v2.y
    assert_equal 3, v2.z
    assert_equal v, v2
    
    v3 = Vector.new([1, 2, 3])
    assert_equal v, v3
  end

  def test_multiply
    assert_equal Vector.new(4, 6), Vector.new(2, 3) * 2
    assert_equal Vector.new(0, -10), Vector.new(0, 1) * -10
    assert_equal Vector.new(2, -10, 100), Vector.new(-0.2, 1, -10) * -10
  end
  
  def test_add
    assert_equal Vector.new(2, 3), Vector.new(1, 1) + Vector.new(1, 2)
    assert_equal Vector.new(2, 3), Vector.new(-1, 10) + Vector.new(3, -7.0)
    assert_equal Vector.new(2, 3, -1), 
                 Vector.new(-1, 10, 2) + Vector.new(3, -7.0, -3)
  end
  
  def test_subtract
    assert_equal Vector.new(2, 3), Vector.new(4, 4) - Vector.new(2, 1)
    assert_equal Vector.new(5, -1), Vector.new(-1, 10) - Vector.new(-6, 11)
    assert_equal Vector.new(5, -1, 10), 
                 Vector.new(-1, 10, 12) - Vector.new(-6, 11, 2)
  end
  
  def test_length
    assert_equal 5, Vector.new(5, 0).length
    assert_equal 5.0, Vector.new(0, 5, 0).length
    assert_equal 5, Vector.new(3, 4, 0).length
    assert_equal 5, Vector.new(0, 3, 4).length
  end
  
  def test_equality
    assert_equal Vector.new(5, 0), Vector.new(5, 0)
    assert_equal Vector.new(-1, -2), Vector.new(-1, -2)
    assert_equal Vector.new(-1, -2, -4), Vector.new(-1, -2, -4)
    assert_not_equal Vector.new(-1, -2, 5), Vector.new(-1, -2, 4)
    assert_not_equal Vector.new(-1, -2), Vector.new(-1, -2, 4)
    assert_not_equal Vector.new(-2, -2), Vector.new(-1, -2)
  end
end
