require 'spec_helper'

describe Unidata::SelectList do
  def create_list(items, should_cache=false)
    list = StubUniSelectList.new(items)
    Unidata::SelectList.new(list, should_cache)
  end

  let(:list) { create_list ['1', '2', '3'] }

  describe '#each' do
    it 'should yield each of the items in the select list' do
      expect {|b| list.each &b }.to yield_successive_args '1', '2', '3'
    end

    context 'without caching' do
      it 'should only be able to iterate once' do
        list.each{|i| i}
        expect {|b| list.each &b }.not_to yield_control
      end
    end

    context 'with caching' do
      it 'should be able to iterate many times' do
        list = create_list ['1', '2', '3'], true
        list.each{|i| i}
        expect {|b| list.each &b }.to yield_successive_args '1', '2', '3'
      end
    end
  end

  it 'should have the enumerable methods' do
    list.map{|i| ":#{i}:" }.should == [':1:', ':2:', ':3:']
  end
end
