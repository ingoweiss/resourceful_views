class ResourcefulViews
  
  cattr_accessor :form_helpers_suffix, :link_helpers_suffix
  cattr_accessor :helpers
  
  def initialize # :nodoc:    
    @module ||= Module.new
    yield self
  end
  
  # generate a string of space-separated standardized CSS classnames
  def self.resourceful_classnames(primary_classname, *secondary_classnames)
    classnames = []
    classnames << primary_classname
    secondary_classnames.each do |classname|
      classnames << classname
      classnames << [classname, primary_classname].join('_') # a little help for IE
    end
    classnames.join(' ')
  end
  
  # Build resourceful helpers for a plural resource and install them into ActionView::Base
  def build_and_install_helpers_for_resource(resource) # :nodoc:
    build_index_helper(resource)
    build_search_helper(resource)
    build_show_helper(resource)
    build_new_helper(resource)
    build_edit_helper(resource)
    build_destroy_helper(resource)
    build_list_helpers(resource)
    build_table_helpers(resource)
    build_create_helper(resource)
    build_update_helper(resource)
    memorize_helpers(resource)
    install_helpers
  end
  
  # Build resourceful helpers for a singular resource and install them into ActionView::Base
  def build_and_install_helpers_for_singular_resource(resource) # :nodoc:
    build_show_helper(resource)
    build_new_helper(resource)
    build_edit_helper(resource)
    build_destroy_helper(resource)
    build_create_helper(resource)
    build_update_helper(resource)
    memorize_helpers(resource)
    install_helpers
  end
  
  def self.deprecation_warning(msg) # :nodoc:
    RAILS_DEFAULT_LOGGER.warn('ResourcefulViews deprecation warning: ' + msg)
  end
  
  def memorize_helpers(resource) # :nodoc:
    @@helpers ||= {}
    @@helpers["#{resource.name_prefix}#{resource.plural} at #{resource.path}"] = @module.instance_methods
  end
  
  
  protected
  
  # Build the 'index_[resource]' helper
  # 
  # === Examples
  # 
  #   <% index_tables %>
  #
  #   renders:
  # 
  #   <a href="/tables" class="index tables index_tables">Index</a>
  #
  #   <% index_table_legs(@table, :id => 'back_button', :label => 'Back') %>
  #
  #   renders:
  #
  #   <a href="/tables/1/legs" id="back_button" class="index legs index_legs">Back</a>
  # 
  def build_index_helper(resource)
    helper_name = "index_#{resource.name_prefix}#{resource.plural}#{@@link_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Index'
        custom_classes = opts.delete(:class) || ''
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.plural}', 'index', *custom_classes.split)
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        args << opts.delete(:sending) if opts[:sending]
        link_to(label, #{resource.name_prefix}#{resource.plural}_path(*args), opts)
      end
    end_eval
  end
  
  
  
  # Build the 'search_[resource]' helper
  # 
  # === Examples
  # 
  #   <% search_tables %>
  #
  #   renders:
  # 
  #   <form action="/tables" method="get" class="index tables index_tables search search_tables">
  #     <input type="text" name="query" />
  #     <button type="submit">Search</button>
  #   </form>
  #
  #   <%= search_tables(:label => 'Find', :sending => {:order => 'material'}) %>
  # 
  #   renders:
  # 
  #   <form action="/tables" method="get" class="index tables index_tables search search_tables">
  #     <input type="text" name="query" />
  #     <input type="hidden" name="order" value="material" />
  #     <button type="submit">Find</button>
  #   </form>
  #
  #   <% search_table_legs(table, :sending => {:order => 'price'}) do %>
  #     <%= select_tag 'filter', '<option>wood</option><option>metal</option>', :id => false %>
  #     <%= submit_button 'Search' %>
  #   <% end %>
  #
  #   renders:
  # 
  #   <form action="/tables/1/legs" method="get" class="index tables index_tables search search_tables">
  #     <input type="text" name="query" />
  #     <input type="hidden" name="order" value="price" />
  #     <select name="filter"><option>wood</option><option>glass</option></select>
  #     <button type="submit">Search</button>
  #   </form>
  #    
  def build_search_helper(resource)
    helper_name = "search_#{resource.name_prefix}#{resource.plural}#{@@form_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args, &block)
        opts = args.extract_options!
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.plural}', 'search', *(opts.delete(:class) || '').split)
        opts[:method] = :get
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        parameters = opts.delete(:sending) || {}
        if block_given?
          concat(form_tag(#{resource.name_prefix}#{resource.plural}_path(*args), opts), block.binding)
            parameters.collect{ |key, value|
              concat(hidden_field_tag(key.to_s, value, :id => nil), block.binding)
            }
            yield
          concat('</form>', block.binding)
        else
          opts_for_button = opts.delete(:button) || {}
          opts_for_button.merge!(:type => 'submit')
          label = opts.delete(:label) || 'Search'
          opts[:action] = #{resource.name_prefix}#{resource.plural}_path(*args)
           content_tag('form', opts) do
            text_field_tag(:query, @query, :id => nil) +
            parameters.collect{ |key, value|
              hidden_field_tag(key.to_s, value, :id => nil)
            }.join +
            content_tag(:button, label, opts_for_button)
          end
        end
      end
    end_eval
  end
  
  
  
  # Build the 'show_[resource]' helper
  # 
  # === Examples
  # 
  #   <% show_table_top(@table, @top) %>
  #
  #   renders:
  # 
  #   <a href="/tables/1/top" class="show top show_top">Show</a>
  #
  #   <% show_table(@table, :label => @top.material) %>
  # 
  #   renders:
  # 
  #   <a href="/tables/1" class="show table show_table">Linoleum</a>
  #
  def build_show_helper(resource) 
    helper_name = "show_#{resource.name_prefix}#{resource.singular}#{@@link_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || #{resource.kind_of?(ActionController::Resources::SingletonResource) ? "'Show'" : 'args.last.to_s'}
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'show', *(opts.delete(:class) || '').split)
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        args << opts.delete(:sending) if opts[:sending]
        link_to(label, #{resource.name_prefix}#{resource.singular}_path(*args), opts)
      end
    end_eval
  end


  
  # Build the 'new_[resource]' helper
  # 
  # === Examples
  # 
  #   <%= new_table %>
  #
  #   renders:
  # 
  #   <a href="/tables/new" class="new table new_table">New</a>
  #
  #   <%= new_table_top(@table, :label => 'Add a top', :id => 'add_button') %>
  # 
  #   renders:
  # 
  #   <a href="/tables/1/top/new" id="add_button" class="new top new_top">Add a top</a>
  #
  #   <%- new_table :with => {:name => 'Ingo'} do |f| %>
  #     <%= f.text_area :description %>
  #     <%= submit_button 'Save' %>
  #   <%- end %>
  #
  #   renders:
  #
  #   <form action="/tables/new" method="get" class="new table new_table">
  #     <input type="hidden" name="table[name]" value="Ingo" />
  #     <textarea name="table[description]" value="" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  def build_new_helper(resource)
    helper_name = "new_#{resource.name_prefix}#{resource.singular}#{@@link_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args, &block)
        opts = args.extract_options!
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'new', *(opts.delete(:class) || '').split)
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        parameters = opts.delete(:sending) || {}
        opts[:with] = opts.delete(:attributes) and ResourcefulViews.deprecation_warning('Please use :with instead of :attributes') if opts[:attributes]
        resource_attributes = opts.delete(:with) || {}
        parameters.merge!(resource_attributes.inject({}){|attributes, (key, value)| attributes['#{resource.singular}[' + key.to_s + ']'] = value; attributes}) if resource_attributes
        if block_given?
          opts[:method] = :get
          args_for_fields_for = ['#{resource.singular}']
          concat(form_tag(new_#{resource.name_prefix}#{resource.singular}_path(*args), opts), block.binding)
          concat(parameters.collect{|key, value| hidden_field_tag(key.to_s, value, :id => nil)}.join, block.binding) unless parameters.empty?
          fields_for(*args_for_fields_for, &block)
          concat('</form>', block.binding)
        else
          label = opts.delete(:label) || 'New'
          args << parameters unless parameters.empty?
          link_to(label, new_#{resource.name_prefix}#{resource.singular}_path(*args), opts)
        end
      end
    end_eval
  end


  
  # Build the 'edit_[resource]' helper
  # 
  # === Examples
  # 
  #   <% edit_table_top(@table) %>
  #
  #   renders:
  # 
  #   <a href="/tables/1/top/edit" class="edit top edit_top">Edit</a>
  #
  #   <% edit_table_top(@table, :label => 'Change top') %>
  # 
  #   renders:
  # 
  #   <a href="/tables/1/top/edit" class="edit top edit_top">Change top</a>
  #
  def build_edit_helper(resource)
    helper_name = "edit_#{resource.name_prefix}#{resource.singular}#{@@link_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args)
        opts = args.extract_options!
        label = opts.delete(:label) || 'Edit'
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'edit', *(opts.delete(:class) || '').split)
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        args << opts.delete(:sending) if opts[:sending]
        link_to(label, edit_#{resource.name_prefix}#{resource.singular}_path(*args), opts)
      end
    end_eval
  end


  
  # Build the 'destroy_[resource]' helper
  # 
  # === Examples
  # 
  #   <% destroy_table_leg(@table, @leg) %>
  #
  #   renders:
  # 
  #   <form action="/tables/1/legs/1" class="leg destroy destroy_leg" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit">Delete</button>
  #   </form>
  #
  #   <% destroy_table_leg(@table, @leg, :button => {:title => 'Click to remove'}) %>
  # 
  #   renders:
  # 
  #   <form action="/tables/1/legs/1" class="leg destroy destroy_leg" method="post">
  #     <input name="_method" type="hidden" value="delete" />
  #     <button type="submit" title="Click to remove">Delete</button>
  #   </form>
  #
  def build_destroy_helper(resource)
    helper_name = "destroy_#{resource.name_prefix}#{resource.singular}#{@@form_helpers_suffix}"
    return if already_defined?(helper_name)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args)
        opts = args.extract_options!
        opts_for_button = opts.delete(:button) || {}
        opts_for_button.merge!(:type => 'submit')
        label = opts.delete(:label) || 'Delete'
        opts_for_button[:title] = opts.delete(:title) if opts[:title]
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'destroy', *(opts.delete(:class) || '').split)
        opts[:method] = :post
        opts[:action] = #{resource.name_prefix}#{resource.singular}_path(*args)
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        parameters = opts.delete(:sending) || {} 
        content_tag('form', opts) do
          hidden_field_tag(:_method, :delete, :id => nil) +
          parameters.collect{|key, value| 
            hidden_field_tag(key, value, :id => nil)
          }.join +
          token_tag.to_s +
          content_tag(:button, label, opts_for_button)
        end
      end
    end_eval
  end
  


  # Build the list helpers
  #
  # === Examples
  #
  #   <% table_list do %>
  #     ...
  #   <%- end -%>
  # 
  #   renders:
  # 
  #   <ul class="table_list">
  #     ...
  #   </ul>
  # 
  #   <% table_list :ordered => true do %>
  #     ...
  #   <% end %>
  # 
  #   renders:
  # 
  #   <ol class="table_list">
  #     ...
  #   </ol>
  # 
  def build_list_helpers(resource)
    @module.module_eval <<-end_eval
      def #{resource.singular}_list(opts={}, &block)
        content = capture(&block)
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}_list', *(opts.delete(:class) || '').split)
        concat(content_tag((opts[:ordered] ? :ol : :ul), content, opts), block.binding)
      end
      def #{resource.singular}_item(*args, &block)
        opts = args.extract_options!
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', *(opts.delete(:class) || '').split)
        opts[:id] = '#{resource.singular}_' + args.first.id.to_s unless args.empty?
        content = capture(&block)
        concat(content_tag(:li, content, opts), block.binding)
      end
    end_eval
  end
   
  
  
  # Build the table helpers
  #
  # === Examples
  #
  #   <% user_table do %>
  #     ...
  #   <%- end -%>
  # 
  #   renders:
  # 
  #   <table class="user_table">
  #     ...
  #   </table>
  # 
  def build_table_helpers(resource)
    @module.module_eval <<-end_eval
      def #{resource.singular}_table(opts={}, &block)
        content = capture(&block)
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}_table', *(opts.delete(:class) || '').split)
        concat(content_tag(:table, content, opts), block.binding)
      end
      def #{resource.singular}_row(*args, &block)
        opts = args.extract_options!
        opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', *(opts.delete(:class) || '').split)
        opts[:id] = '#{resource.singular}_' + args.first.id.to_s unless args.empty?
        content = capture(&block)
        concat(content_tag(:tr, content, opts), block.binding)
      end
    end_eval
  end
  
  

  # Build the 'create_[resource]' helper
  #
  # === Examples without block
  #
  #   <% create_table_top(@table, :with => {:material => 'Mahogany'}) %>
  #
  #   renders:
  #
  #   <form action="/tables/1/top" class="top create create_top" method="post">
  #     <input type="hidden" type="top[material]" value="Mahogany" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  #   <% create_table(:label => 'Add table') %>
  #   
  #   renders:
  #
  #   <form action="/tables" class="table create create_table" method="post">
  #     <button type="submit">Add table</button>
  #   </form>   
  #
  # === Examples with block
  #
  #   <% create_table do |form| %>
  #     <%= form.text_field :title %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #   
  #   renders:
  #
  #   <form action="/tables" class="table create create_table" method="post">
  #     <input type="text" type="table[title]" value="My title" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  def build_create_helper(resource)
    helper_name = "create_#{resource.name_prefix}#{resource.singular}#{@@form_helpers_suffix}"
    return if already_defined?(helper_name)
    number_of_expected_args = number_of_args_expected_by_named_route_helper([resource.name_prefix, resource.plural].join)
    @module.module_eval <<-end_eval
      def #{helper_name}(*args, &block)
        opts = args.extract_options!
        opts[:with] = opts.delete(:attributes) and ResourcefulViews.deprecation_warning('Please use :with instead of :attributes') if opts[:attributes]
        resource_attributes = opts.delete(:with) || {}
        opts[:sending] = opts.delete(:parameters) and ResourcefulViews.deprecation_warning('Please use :sending instead of :parameters') if opts[:parameters]
        parameters = opts.delete(:sending) || {}
        if block_given?
          args_for_fields_for = ['#{resource.singular}']
          args_for_fields_for.push(args.pop) if args.length > #{number_of_expected_args}
          opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'create', *(opts.delete(:class) || '').split)
          concat(form_tag(#{resource.name_prefix}#{resource.plural}_path(*args), opts), block.binding)
            concat(resource_attributes.collect{|key, value| hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)}.join, block.binding)
            concat(parameters.collect{|key, value| hidden_field_tag(key, value, :id => nil)}.join, block.binding)
            fields_for(*args_for_fields_for, &block)
          concat('</form>', block.binding)
        else
          label = opts.delete(:label) || 'Add'
          opts_for_button = opts.delete(:button) || {}
          opts_for_button.merge!(:type => 'submit')
          opts[:method] = :post
          opts[:action] = #{resource.name_prefix}#{resource.plural}_path(*args)
          opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'create', *(opts.delete(:class) || '').split)
          content_tag('form', opts) do
            token_tag.to_s +
            parameters.collect{|key, value| 
              hidden_field_tag(key, value, :id => nil)
            }.join +
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join +
            content_tag(:button, label, opts_for_button)
          end
        end
      end  
    end_eval
  end
  


  # Build the 'update_[resource](resource)' helper
  #
  # === Examples without block
  #
  #   <% update_table(@table, :with => {:name => 'Ingo'}) %>
  #
  #   renders:
  #
  #   <form action="/tables/1" class="table update update_table" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="hidden" name="table[name]" value="Ingo" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  # === Examples with block
  #
  #   <% update_table(@table) do |form| %>
  #     <%= form.text_field :name %>
  #     <%= submit_button 'Save' %>
  #   <% end %>
  #
  #   <form action="/tables/1" class="table update update_table" method="post">
  #     <input type="hidden" name="_method" value="put" />
  #     <input type="text" name="table[name]" value="Ingo" />
  #     <button type="submit">Save</button>
  #   </form>
  #
  def build_update_helper(resource)
    helper_name = "update_#{resource.name_prefix}#{resource.singular}#{@@form_helpers_suffix}"
    return if already_defined?(helper_name)
    number_of_expected_args = number_of_args_expected_by_named_route_helper([resource.name_prefix, resource.singular].join)
    resource_is_singular = resource.is_a?(ActionController::Resources::SingletonResource)
    resource_is_plural = !resource_is_singular
    @module.module_eval <<-end_eval
      def #{helper_name}(*args, &block)
        if block_given?
          opts = args.extract_options!
          args_for_fields_for = ['#{resource.singular}']
          #{'args_for_fields_for.push(args.pop) if args.length > ' + number_of_expected_args.to_s if resource_is_singular}
          #{'args_for_fields_for.push(args.last)' if resource_is_plural}
          opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'update', *(opts.delete(:class) || '').split)
          opts[:method] = :put
          concat(form_tag(#{resource.name_prefix}#{resource.singular}_path(*args), opts), block.binding)
          fields_for(*args_for_fields_for, &block)
          concat('</form>', block.binding)
        else
          opts = args.extract_options!
          label = opts.delete(:label) || 'Save'
          opts[:with] = opts.delete(:attributes) and ResourcefulViews.deprecation_warning('Please use :with instead of :attributes') if opts[:attributes]
          resource_attributes = opts.delete(:with) || {}
          opts_for_button = opts.delete(:button) || {}
          opts_for_button.merge!(:type => 'submit')
          opts[:class] = ResourcefulViews.resourceful_classnames('#{resource.singular}', 'update', *(opts.delete(:class) || '').split)
          opts[:method] = :post
          opts[:action] = #{resource.name_prefix}#{resource.singular}_path(*args)
          content_tag('form', opts) do
            token_tag.to_s +
            resource_attributes.collect{ |key, value|
              hidden_field_tag('#{resource.singular}[' + key.to_s + ']', value, :id => nil)
            }.join <<
            hidden_field_tag('_method', 'put', :id => nil) <<
            content_tag(:button, label, opts_for_button)
          end
        end
      end
    end_eval
  end
  
    
   # include the module (loaded with helper methods) into ActionView::Base
  def install_helpers # :nodoc:
    ActionView::Base.send! :include, @module
  end
  
  protected
  
  # Check whether method is already defined
  def already_defined?(helper_name)
    ActionView::Base.instance_methods.include?(helper_name) or @module.methods.include?(helper_name)
  end
  
  # determine how many arguments a specific named route helper expects
  def number_of_args_expected_by_named_route_helper(helper_name)
    ActionController::Routing::Routes.named_routes.routes[helper_name.to_sym].segment_keys.size
  end  
  
end


ActionController::Routing::RouteSet::Mapper.class_eval do
  
  def resources_with_resourceful_view_helpers(*entities, &block)
    resources_without_resourceful_view_helpers(*entities, &block)
    options = entities.extract_options!
    ResourcefulViews.new do |resourceful_views|
      entities.each do |entity|
        resource = ActionController::Resources::Resource.new(entity, options)
        resourceful_views.build_and_install_helpers_for_resource(resource)
      end
    end
  end
  
  alias_method_chain :resources, :resourceful_view_helpers
  
  def resource_with_resourceful_view_helpers(*entities, &block)
    resource_without_resourceful_view_helpers(*entities, &block)
    options = entities.extract_options!
    ResourcefulViews.new do |resourceful_views|
      entities.each do |entity|
        resource = ActionController::Resources::SingletonResource.new(entity, options)
        resourceful_views.build_and_install_helpers_for_singular_resource(resource)
      end
    end
  end
    
  alias_method_chain :resource, :resourceful_view_helpers
  
end

