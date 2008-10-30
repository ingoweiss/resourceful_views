require File.dirname(__FILE__) + '/spec_helper'


describe 'create_resource with plural resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:tables_path).and_return('/tables')
  end
  
  it "should render a create resource form" do
    markup = @view.create_table
    markup.should have_tag('form.create.table.create_table')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_table(:class => 'dining')
    markup.should have_tag('form.create.table.dining.create_table.dining_table')
  end
  
  it "should allow for giving the form an id with the :id option" do
    markup = @view.create_table(:id => 'table_form')
    markup.should have_tag('form#table_form')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:tables_path).and_return('/tables')
    markup = @view.create_table
    markup.should have_tag('form[action=/tables]')
  end
  
  it "should render hidden fields for passed-in attributes (via :attributes)" do
    markup = @view.create_table(:attributes => {:category => 'dining', :material => 'linoleum'})
    markup.should have_tag('form.create_table') do
      with_tag("input[type=hidden][name='table[category]'][value=dining]")
      with_tag("input[type=hidden][name='table[material]'][value=linoleum]")
    end
  end
  
  it "should should issue a deprecation warning when passing in attributes via :attributes (instead of :with)" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.create_table(:attributes => {:category => 'dining', :material => 'linoleum'})
  end
  
  it "should render hidden fields for passed-in attributes (via :with)" do
    markup = @view.create_table(:with => {:category => 'dining', :material => 'linoleum'})
    markup.should have_tag('form.create_table') do
      with_tag("input[type=hidden][name='table[category]'][value=dining]")
      with_tag("input[type=hidden][name='table[material]'][value=linoleum]")
    end
  end
  
  it "should render hidden fields for passed-in parameters" do
    markup = @view.create_table(:parameters => {:context => 'special'}) 
    markup.should have_tag('form.create_table') do
      with_tag("input[type=hidden][name='context'][value=special]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_table
    markup.should have_tag('form.create_table') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_table(:label => 'Create')
    markup.should have_tag('form.create_table') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.create_table(:button => {:title => 'Click to create table'})
    markup.should have_tag('form.create_table') do
      with_tag('button[type=submit][title=Click to create table]')
    end
  end
    
end


describe 'create_resource with plural resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:tables_path).and_return('/tables')
    @view.stub!(:protect_against_forgery?).and_return(false)
  end
  
  it "should render a 'create_table' form" do
    _erbout = ''
    @view.create_table do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.table.create_table', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_table(:class => 'dining') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.table.create_table.dining.dining_table', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_table do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("form.create.table input[type=text][name='table[category]']")
  end
  
  it "should allow using a custom form builder"
  
  it "should be able to pick up the resource's attributes from the model passed as last argument" do
    table = mock('table', :category => 'dining')
    _erbout = ''
    @view.create_table(table) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("input[type=text][name='table[category]'][value=dining]")
  end
  
  it "should render hidden fields for passed-in parameters" do
    _erbout = ''
    @view.create_table(:sending => {:mode => 'wizard'}) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag('input[type=hidden][name=mode][value=wizard]')
  end
  
  it "should allow passing in parameters via :parameters option (legacy)" do
    _erbout = ''
    @view.create_table(:parameters => {:mode => 'wizard'}) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag('input[type=hidden][name=mode][value=wizard]')
  end
  
  it "should issue a deprecation warning when passing in parameters via :parameters" do
    _erbout = ''
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.create_table(:attributes => {:material => 'wood'}) do |form|
       # something
    end
  end
  
  it "should render hidden fields for passed-in attributes (via :attributes)" do
    _erbout = ''
    @view.create_table(:attributes => {:material => 'wood'}) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("input[type=hidden][name='table[material]'][value=wood]")
  end
  
  it "should should issue a deprecation warning when passing in attributes via :attributes (instead of :with)" do
    ResourcefulViews.should_receive(:deprecation_warning)
    _erbout = ''
    @view.create_table(:attributes => {:material => 'wood'}) do |form|
       # something
    end
  end
  
  it "should render hidden fields for passed-in attributes (via :with)" do
    _erbout = ''
    @view.create_table :with => {:material => 'wood'} do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("input[type=hidden][name='table[material]'][value=wood]")
  end
  
  
end



describe 'create_resource with plural nested resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_legs_path).and_return('/tables/1/legs')
    @table = mock('table')
  end
  
  it "should render a create resource form" do
    markup = @view.create_table_leg(@table)
    markup.should have_tag('form.create.leg.create_leg')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_table_leg(@table, :class => 'metal')
    markup.should have_tag('form.create.leg.metal.create_leg.metal_leg')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:table_legs_path).and_return('/tables/1/legs')
    markup = @view.create_table_leg(@table)
    markup.should have_tag('form[action=/tables/1/legs]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.create_table_leg(@table, :with => {:material => 'metal'})
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='leg[material]'][value=metal]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_table_leg(@table)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_table_leg(@table, :label => 'Create')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.create_table_leg(@table, :button => {:title => 'Click to add leg'})
    markup.should have_tag('form.create_leg') do
      with_tag('button[type=submit][title=Click to add leg]')
    end
  end
  
end


describe 'create_resource with plural nested resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:table_legs_path).and_return('/tables/1/legs')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @table = mock('table')
  end
  
  it "should render a 'create_table' form" do
    _erbout = ''
    @view.create_table_leg(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.leg.create_leg', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_table_leg(@table, :class => 'wood') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.leg.create_leg.wood.wood_leg', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_table_leg(@table) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("form.create_leg input[type=text][name='leg[material]']")
  end
  
  it "should be able to pick up the resource's attributes from the model passed as last argument" do
    leg = mock('leg', :material => 'Metal')
    _erbout = ''
    @view.create_table_leg(@table, leg) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("form.create_leg input[type=text][name='leg[material]'][value=Metal]")
  end

end 



describe 'create_resource for singular nested resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_top_path).and_return('/tables/1/top')
    @table = mock('table')
  end
  
  it "should render a create resource form" do
    markup = @view.create_table_top(@table)
    markup.should have_tag('form.create.top.create_top')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.create_table_top(@table, :class => 'wood')
    markup.should have_tag('form.create.top.wood.create_top.wood_top')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:table_top_path).and_return('/tables/1/top')
    markup = @view.create_table_top(@table)
    markup.should have_tag('form[action=/tables/1/top]')
  end
  
  it "should render hidden fields for passed-in attributes" do
    markup = @view.create_table_top(@table, :with => {:material => 'wood'})
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='top[material]'][value=wood]")
    end
  end
  
  it "should render a submit button with default label 'Add'" do
    markup = @view.create_table_top(@table)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Add')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.create_table_top(@table, :label => 'Create')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Create')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.create_table_top(@table, :button => {:title => 'Click to add top'})
    markup.should have_tag('form.create_top') do
      with_tag('button[type=submit][title=Click to add top]')
    end
  end
  
end



describe 'create_resource with singular nested resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:table_top_path).and_return('/tables/1/top')
    @view.stub!(:protect_against_forgery?).and_return(false)
    @table = mock('table')
  end
  
  it "should render a 'create_table' form" do
    _erbout = ''
    @view.create_table_top(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.top.create_top', 'some-content')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.create_table_top(@table, :class => 'wood') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.create.top.create_top.wood.wood_top', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.create_table_top(@table) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("form.create_top input[type=text][name='top[material]']")
  end

end 

describe 'create_resource with form_helpers_suffix set' do
  
  before do
    ResourcefulViews.form_helpers_suffix = '_form'
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
        table.resource :top
      end
    end
    @view = ActionView::Base.new
  end
  
  it "should define helpers with suffix" do
    @view.should respond_to(:create_table_form)
    @view.should respond_to(:create_table_leg_form)
    @view.should respond_to(:create_table_top_form)
  end                        
  
end