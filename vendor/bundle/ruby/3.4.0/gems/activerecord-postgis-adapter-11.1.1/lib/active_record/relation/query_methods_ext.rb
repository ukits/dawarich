# frozen_string_literal: true

module ActiveRecord
  class Relation
    module QueryMethodsExt
      def st_contains!(column, inner_geom)
      	where!(self.arel_table[:column].st_contains(inner_geom))
      end

      def st_contains(...)
      	spawn.st_contains!(...)
      end

      RGeo::ActiveRecord::SpatialExpressions.instance_methods.each do |method_name|
      	next if method_name == :st_function
      	met = RGeo::ActiveRecord::SpatialExpressions.instance_method(method_name)
        class_eval(<<-CODE, __FILE__, __LINE__ + 1)
          def #{method_name}(...); #{method_name}!(...); end
          def #{method_name}!(column, *args)
          	rel = self.arel_table[column]
          	where!(rel.#{method_name}(*args))
          end
        CODE
      end
    end

    QueryMethods.prepend(QueryMethodsExt)
  end
  # `ActiveRecord::Base` ancestors do not include `QueryMethods`.
  # But the `#all` method returns a relation, which has `QueryMethods`
  # as ancestor. That is how active_record is doing is as well.
  #
  # @see https://github.com/rails/rails/blob/914130a9f/activerecord/lib/active_record/querying.rb#L23
  Querying.delegate(:st_contains, to: :all)
end
