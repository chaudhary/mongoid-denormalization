require "mongoid/denormalization/version"

module Mongoid
  module Denormalization
    extend ActiveSupport::Concern



    included do
      def force_denormalize!
        force_denormalize
        self.save
      end

      def force_denormalize
      end
    end

    module Helpers
      def self.update_from_klass_changes(to_klass_infos, from_doc_id, field_value)
        puts "hello"
        to_klass_infos.each do |to_klass_info|
          selector = to_klass_info[:selector_proc].call(from_doc_id, field_value)
          to_klass_info[:klasses].each do |klass|
            query = klass.where(selector)
            while query.present?
              klass.collection.find(selector).update_many({"$set" => {to_klass_info[:updator].to_sym => field_value}}, multi: true, safe: true)
            end
          end
        end
      end

      def self.field_value(from_doc, field_terms)
        value = from_doc
        field_terms.each do |field_term|
          value = value.send(field_term)
        end
        return value
      end
    end


    module ClassMethods
      def denormalize_from(relation, field_name, denormalized_field_name: nil, to_klass_infos: [])
        to_klass = self
        field_terms = field_name.to_s.split(".")
        denormalized_field_name ||= [relation, field_terms.last].flatten.join("_")

        if to_klass_infos.blank? && !(to_klass.embedded?)
          to_klass_infos = [{
            klasses: [to_klass],
            selector_proc: Proc.new do |id, value|
              {"#{relation}_id".to_sym => id, denormalized_field_name.to_sym => {"$ne" => value}}
            end,
            updator: denormalized_field_name,
            index_key: "#{relation}_id"
          }]
        end

        # to_klass_infos.each do |to_klass_info|
        #   index_key = to_klass_info[:index_key]
        #   raise "Index key is blank" if index_key.blank?
        #   to_klass_info[:klasses].each do |klass|
        #     if klass.collection.indexes.to_a.select{|index_info| index_info["key"].keys.index(index_key) == 0}.blank?
        #       raise "Index missing exception for #{index_key} on #{klass.to_s} class"
        #     end
        #   end
        # end

        to_klass_roots = to_klass_infos.map{|to_klass_info| to_klass_info[:klasses].map(&:to_s)}.flatten.uniq
        from_klass = self.relations[relation.to_s].class_name.constantize

        field_type = from_klass.fields[field_name.to_s].options[:type] if field_terms.size == 1 && field_name.to_s != "_type"
        field_type ||= String

        to_klass_infos.each do |to_klass_info|
          next unless to_klass_info[:index_key].include?(".")
          field_path = to_klass_info[:index_key].split(".").first

          to_klass_info[:klasses].each do |klass|
            unless klass.method_defined?(:force_denormalize)
              klass.send(:define_method, :force_denormalize) do
              end
            end

            unless klass.method_defined?(:force_denormalize!)
              klass.send(:define_method, :force_denormalize!) do
                force_denormalize
                self.save
              end
            end

            unless klass.method_defined?("force_denormalize_#{field_path}".to_sym)
              klass.send(:define_method, "force_denormalize_#{field_path}".to_sym) do
                docs = self.send(field_path.to_sym)
                if docs.respond_to?(:each)
                  docs.each{|doc| doc.force_denormalize}
                else
                  docs.force_denormalize
                end
              end

              force_denormalize_module = Module.new do
                define_method "force_denormalize" do |*args|
                  super(*args)
                  self.send("force_denormalize_#{field_path}")
                end
              end
              klass.prepend(force_denormalize_module)
            end
          end
        end




        from_klass.instance_eval do
          after_save do |from_doc|
            changed_fn = "#{field_terms[0]}_changed?"
            changed_fn = "asset_filename_changed?" if field_terms[0].to_s == "asset"
            if from_doc.send(changed_fn)
              field_value = ::Mongoid::Denormalization::Helpers.field_value(from_doc, field_terms)
              ::Mongoid::Denormalization::Helpers.update_from_klass_changes(to_klass_infos, from_doc.id, field_value)
            end
          end

          after_destroy do |from_doc|
            field_value = nil
            ::Mongoid::Denormalization::Helpers.update_from_klass_changes(to_klass_infos, from_doc.id, field_value)
          end
        end



        to_klass.class_eval do

          get_func_module = Module.new do
            define_method denormalized_field_name.to_s do |*args|
              use_denormalized = to_klass_roots.find{|to_klass_root| self._root.is_a?(to_klass_root.constantize)}.present?
              field_value = super(*args) if use_denormalized
              return field_value if field_value.present?

              from_doc = self.send(relation)
              return nil if from_doc.blank?

              field_value = ::Mongoid::Denormalization::Helpers.field_value(from_doc, field_terms)

              if use_denormalized
                self.send("#{denormalized_field_name}=", field_value)
                self.set("#{denormalized_field_name}" => field_value) if self.persisted?
              end
              return field_value
            end
          end
          self.prepend(get_func_module)

          define_method "denormalize_#{denormalized_field_name}" do
            use_denormalized = to_klass_roots.find{|to_klass_root| self._root.is_a?(to_klass_root.constantize)}.present?
            return unless use_denormalized
            from_doc = self.send(relation)
            return nil if from_doc.blank?

            field_value = ::Mongoid::Denormalization::Helpers.field_value(from_doc, field_terms)
            self.send("#{denormalized_field_name}=", field_value)
            return true
          end

          define_method "denormalize_#{denormalized_field_name}!" do
            use_denormalized = to_klass_roots.find{|to_klass_root| self._root.is_a?(to_klass_root.constantize)}.present?
            return unless use_denormalized
            from_doc = self.send(relation)
            return nil if from_doc.blank?

            field_value = ::Mongoid::Denormalization::Helpers.field_value(from_doc, field_terms)
            self.set(denormalized_field_name.to_sym => field_value)
          end

          force_denormalize_module = Module.new do
            define_method "force_denormalize" do |*args|
              super(*args)
              self.send("denormalize_#{denormalized_field_name}")
            end
          end
          self.prepend(force_denormalize_module)
        end

        to_klass.instance_eval do
          self.field(denormalized_field_name, type: field_type)

          before_save do |doc|
            if doc.send("#{relation}_id_changed?")
              doc.send("denormalize_#{denormalized_field_name}")
            end
          end
        end

      end
    end

  end
end
