module Cacheable
  extend ActiveSupport::Concern

private

  def cached_method(name)
    @cached_methods ||= {}
    @cached_methods[name] = yield unless @cached_methods.has_key?(name)
    @cached_methods[name]
  end
end
