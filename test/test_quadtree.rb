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
require File.dirname(__FILE__) + '/../lib/quadtree'
require File.dirname(__FILE__) + '/../lib/vector'

class TestQuadTree < Test::Unit::TestCase
  def standard_quad
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(10, 10), :a))
    q.add(QuadTreePayload.new(Vector.new(75, 75), :b))
    q.add(QuadTreePayload.new(Vector.new(5, 99), :c))
    q.add(QuadTreePayload.new(Vector.new(99, 5), :d))
    q.add(QuadTreePayload.new(Vector.new(99, 4), :e))
    q
  end
  
  def test_new_quadtree
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    assert_equal 0, q.size
  end
  
  def test_adding_element
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(10, 10), 'hello'))
    assert_equal 1, q.size
    assert_equal 'hello', q.payload.first.data
  end
  
  def test_adding_a_few_elements
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(10, 10), :a))
    q.add(QuadTreePayload.new(Vector.new(75, 75), :b))
    q.add(QuadTreePayload.new(Vector.new(5, 99), :c))
    q.add(QuadTreePayload.new(Vector.new(99, 5), :d))
    assert_equal 4, q.size
    assert_equal nil, q.payload
    assert_equal 1, q.tlq.size
    assert_equal 1, q.trq.size
    assert_equal 1, q.blq.size
    assert_equal 1, q.brq.size
    assert_equal :c, q.tlq.payload.first.data
    assert_equal :b, q.trq.payload.first.data
    assert_equal :a, q.blq.payload.first.data
    assert_equal :d, q.brq.payload.first.data
  end
  
  def test_greedy_adding_of_elements_on_boundaries
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(50, 50), :a))
    assert_equal 1, q.size
    assert_equal :a, q.payload.first.data
    q.add(QuadTreePayload.new(Vector.new(0, 50), :b))
    assert_equal :a, q.tlq.brq.payload.first.data
    assert_equal :b, q.tlq.blq.payload.first.data    
  end
  
  def test_adding_two_identical_elements
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(10, 10), 'hello'))
    assert_equal 1, q.size
    assert_equal 'hello', q.payload.first.data
    q.add(QuadTreePayload.new(Vector.new(10, 10), 'hi!'))
    assert_equal 2, q.size
    assert_equal 2, q.payload.length
    assert_equal 'hello', q.payload.first.data
    assert_equal 'hi!', q.payload.last.data
  end
  
  def test_approx_near
    q = standard_quad
    assert_equal 5, q.approx_near(Vector.new(50, 50), 5).length
    assert_equal 5, q.approx_near(Vector.new(50, 50), 10).length
    assert_equal true, q.approx_near(Vector.new(99, 1), 3).any? {|i| i.vector == Vector.new(99, 4)}
    assert_equal true, q.approx_near(Vector.new(99, 1), 3).any? {|i| i.vector == Vector.new(99, 5)}
    assert_equal false, q.approx_near(Vector.new(99, 1), 3).any? {|i| i.vector == Vector.new(10, 10)}
  end
  
  def test_payloads_in_region_in_small_region
    q = standard_quad
    assert_equal 2, q.payloads_in_region(Vector.new(98, 10), Vector.new(100, 0)).length
    assert_equal 1, q.payloads_in_region(Vector.new(98, 10), Vector.new(100, 0), 1).length
    assert_equal true, q.payloads_in_region(Vector.new(98, 10), Vector.new(100, 0)).any? {|i| i.vector == Vector.new(99, 4)}
    assert_equal true, q.payloads_in_region(Vector.new(98, 10), Vector.new(100, 0)).any? {|i| i.vector == Vector.new(99, 5)}
    assert_equal false, q.payloads_in_region(Vector.new(98, 10), Vector.new(100, 0)).any? {|i| i.vector == Vector.new(10, 10)}
  end

  def test_payloads_in_region_in_large_region
    q = standard_quad
    assert_equal 5, q.payloads_in_region(Vector.new(0, 100), Vector.new(100, 0)).length
  end
  
  def test_adding_a_third_element_to_two_identical_elements
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(10, 10), 'hello'))
    assert_equal 1, q.size
    assert_equal 'hello', q.payload.first.data
    q.add(QuadTreePayload.new(Vector.new(10, 10), 'hi!'))
    assert_equal 2, q.size
    assert_equal 2, q.payload.length
    assert_equal 'hello', q.payload.first.data
    assert_equal 'hi!', q.payload.last.data
    
    q.add(QuadTreePayload.new(Vector.new(20,20), 'third wheel'))
    assert_equal 3, q.size
    assert_equal nil, q.payload
    assert_equal 2, q.blq.blq.blq.payload.length
    assert_equal 1, q.blq.blq.trq.payload.length
    assert_equal 'third wheel', q.blq.blq.trq.payload.first.data
    
    # And test get_contained_payloads while we're at it.
    assert_equal 3, q.get_contained_payloads.length
    assert_equal 3, q.blq.blq.get_contained_payloads.length
    assert_equal 1, q.blq.blq.trq.get_contained_payloads.length
    assert_equal 2, q.blq.blq.blq.get_contained_payloads.length
    assert_equal 0, q.blq.blq.brq.get_contained_payloads.length
  end
  
  def test_get_contained_payloads_with_number_limit
    q = standard_quad
    assert_equal 1, q.get_contained_payloads(:max_count => 1).length
    assert_equal 4, q.get_contained_payloads(:max_count => 4).length
    assert_equal 5, q.get_contained_payloads(:max_count => 20).length
    assert_equal 5, q.get_contained_payloads.length
    
    assert_equal true, q.get_contained_payloads(:max_count => 4).any? {|i| i.vector == Vector.new(10, 10)}
    assert_equal true, q.get_contained_payloads(:max_count => 4).any? {|i| i.vector == Vector.new(75, 75)}
    assert_equal true, q.get_contained_payloads(:max_count => 4).any? {|i| i.vector == Vector.new(5, 99)}
    assert_equal true, q.get_contained_payloads(:max_count => 4).any? {|i| i.vector == Vector.new(99, 5)}
    assert_equal false, q.get_contained_payloads(:max_count => 4).any? {|i| i.vector == Vector.new(11, 10)} # because it's lower and quads go clockwise
  end
  
  def test_center_of_mass
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    q.add(QuadTreePayload.new(Vector.new(30, 55), :a))
    q.add(QuadTreePayload.new(Vector.new(70, 55), :b))
    assert_equal Vector.new(50,55), q.center_of_mass
    assert_equal Vector.new(30,55), q.tlq.center_of_mass
    assert_equal Vector.new(70,55), q.trq.center_of_mass    
  end
  
  def test_depth
    q = standard_quad
    assert_equal 1, q.depth
    assert_equal 2, q.tlq.depth
    assert_equal 2, q.trq.depth
    assert_equal 2, q.blq.depth
    assert_equal 2, q.brq.depth
    assert_equal 3, q.brq.brq.depth
  end
  
  def test_leaves_each
    q = standard_quad
    leaves = []
    q.leaves_each(100) do |leaf|
      leaves << leaf
    end
    assert_equal 5, leaves.length

    leaves = []
    q.leaves_each(3) do |leaf|
      leaves << leaf
    end
    assert_equal 4, leaves.length
  end
  
  def test_clip_vector
    q = QuadTree.new(Vector.new(0,100), Vector.new(100,0))
    assert_equal Vector.new(0, 100), q.clip_vector(Vector.new(-1, 100))
    assert_equal Vector.new(100, 100), q.clip_vector(Vector.new(200, 200))
    assert_equal Vector.new(0, 0), q.clip_vector(Vector.new(-200, -200))
    assert_equal Vector.new(100, 0), q.clip_vector(Vector.new(200, -200))
  end
  
  def test_child_of_and_parent_of
    q = standard_quad
    assert_equal true, q.blq.child_of?(q)
    assert_equal true, q.trq.child_of?(q)
    assert_equal true, q.brq.tlq.child_of?(q.brq)
    assert_equal true, q.brq.parent_of?(q.brq.brq)
  end
  
  def test_payloads_and_centers_in_region
    q = standard_quad
    assert_equal 1, q.payloads_and_centers_in_region(Vector.new(0,100), Vector.new(100, 0), 1)[:details].length
    assert_equal 2, q.payloads_and_centers_in_region(Vector.new(0,100), Vector.new(100, 0), 1)[:details].first.last
    assert_equal 3, q.payloads_and_centers_in_region(Vector.new(0,100), Vector.new(100, 0), 1)[:payloads].length
  end
  
  def test_parent
    q = standard_quad
    assert_equal q.brq, q.brq.brq.parent
    assert_equal q, q.brq.parent
    assert_equal nil, q.parent
  end
  
  def test_quadtreepayload_node
    q = standard_quad
    assert_equal q.blq, q.get_contained_payloads(:max_count => 5).find {|i| i.vector == Vector.new(10, 10)}.node
  end
  
  def test_family_size_at_width
    q = standard_quad
    tl = Vector.new(0, 49)
    br = Vector.new(49, 0)
    assert_equal 5, q.family_size_at_width(tl, br)
    assert_equal 5, q.brq.brq.family_size_at_width(tl, br)
    assert_equal 1, q.blq.family_size_at_width(tl, br)
  end
end
