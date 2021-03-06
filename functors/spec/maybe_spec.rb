require 'pry'
require_relative '../lib/maybe'

# These are not production ready specs, they were for quick iteration

RSpec.describe Maybe do
  let(:nothing) { Maybe.new(nil) }
  let(:add_four) {  -> (x) { x + 4 } }
  let(:maybe_double) { double Maybe }
  subject(:maybe) { Maybe.new(4, maybe_double) }

  describe 'Functor Interface' do
    describe 'map' do
      before do
        allow(maybe_double).to receive(:new)
      end

      context 'when maybe value is a value' do
        it 'applies the given function to the wrapped value' do
          expect(maybe_double).to receive(:new).with(8).once
          maybe.map(add_four)
        end
      end

      context 'mapping a wrapped function over a function' do
        it 'creates a new wrapped function that does both of the functions combined' do
          maybe = Maybe.new(add_four, maybe_double)
          composed_lambda = -> (*args) { maybe.value.call(add_four.call(*args)) }
          expect(maybe_double).to receive(:new).with(
            -> (composed_lambda) do
              expect(composed_lambda.(4)).to eq 12
            end
          )
          maybe.map(add_four)
        end
      end

      context 'when value is a nothing' do
        it 'returns the wrapped nothing value' do
          expect(nothing.map(add_four)).to have_attributes(value: nil)
          expect(nothing.map(add_four).class).to eq Maybe
          expect(nothing.map(add_four)).to eq nothing
        end
      end

      context 'id' do
        it 'mapping id function just returns the original functor' do
          id_function = -> (x) { x }
          # we should also really test that it receives _all_ attributes that the
          # original has, and none that it didn't have
          # i.e. that theydiffer only in object id, not anything else.
          expect(maybe_double).to receive(:new).with(4).once
          maybe.map(id_function)
        end
      end

      context 'associativity' do
        it 'grouping doesnt matter' do
          maybe = Maybe.new(4)
          add_two = -> (x) { x + 2 }
          add_two_and_four = -> (x){ x + 2 + 4 }
          expect(maybe.map(add_two).map(add_four).value).to eq maybe.map(add_two_and_four).value
        end
      end

      context 'mapping a function that takes two args' do
        it 'partially applies the function' do
          times = -> (x, y) { x * y }
          expect(maybe.map(times).value.call(1)).to eq 4
        end
      end
    end
  end
end
