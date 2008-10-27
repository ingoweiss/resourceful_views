require File.dirname(__FILE__) + '/spec_helper'


describe 'update_resource with plural resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_path).and_return('/tables/1')
    @table = mock('table')
  end
  
  it "should render an update_resource form" do
    markup = @view.update_table(@table)
    markup.should have_tag('form.update.table.update_table')
  end
  
  it "should allow for passing in additions custom classes" do
    markup = @view.update_table(@table, :class => 'dining')
    markup.should have_tag('form.update.table.dining.update_table.dining_table')
  end
  
  it "should allow for giving the form an id via the :id option" do
    markup = @view.update_table(@table, :id => 'update_table_form')
    markup.should have_tag('form#update_table_form')
  end
  
  it "should submit to resource path" do
    @view.should_receive(:table_path).with(@table).and_return('/tables/1')
    markup = @view.update_table(@table)
    markup.should have_tag('form[action=/tables/1]')
  end
  
  it "should use PUT method" do
    markup = @view.update_table(@table)
    markup.should have_tag('form input[type=hidden][name=_method][value=put]')
  end
  
  it "should render hidden fields for passed-in attributes (via :with)" do
    markup = @view.update_table(@table, :with => {:category => 'dining', :material => 'wood'})
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='table[category]'][value=dining]")
      with_tag("input[type=hidden][name='table[material]'][value=wood]")
    end
  end
  
  it "should render hidden fields for passed-in attributes (via :attributes)" do
    markup = @view.update_table(@table, :attributes => {:category => 'dining', :material => 'wood'})
    markup.should have_tag('form') do
      with_tag("input[type=hidden][name='table[category]'][value=dining]")
      with_tag("input[type=hidden][name='table[material]'][value=wood]")
    end
  end
  
  it "should issue a deprecation warning if passing in attributes via :attributes" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.update_table(@table, :attributes => {:category => 'dining', :material => 'wood'})
  end
  
  it "should render a submit button with default label 'Save'" do
    markup = @view.update_table(@table)
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Save')
    end
  end
  
  it "should allow passing in a custom label for the submit button" do
    markup = @view.update_table(@table, :label => 'Update')
    markup.should have_tag('form') do
      with_tag('button[type=submit]', 'Update')
    end
  end
  
  it "should allow for setting the title attribute of the submit button via the :button option" do
    markup = @view.update_table(@table, :button => {:title => 'Click to update'})
    markup.should have_tag('form') do
      with_tag('button[title=Click to update]')
    end
  end
  
end


describe 'update_resource with plural resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_path).and_return('/tables/1')
    @table = mock('table', :category => 'dining')
  end
  
  it "should render a 'update_table' form" do
    _erbout = ''
    @view.update_table(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.table.update_table', 'some-content')
  end
  
  it "should submit to the resource path" do
    @view.should_receive(:table_path).with(@table).and_return('/tables/1')
    _erbout = ''
    @view.update_table(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form[action=/tables/1]')
  end
  
  it "should use PUT" do
    _erbout = ''
    @view.update_table(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form[action=/tables/1]') do
      with_tag('input[type=hidden][name=_method][value=put]')
    end
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_table(@table, :class => 'dining') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.table.update_table.dining.dining_table', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_table(@table) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("form.update.table input[type=text][name='table[category]']")
  end
  
  it "should be able to pick up the resource's attributes from the model passed as last argument" do
    @table = mock('table', :category => 'dining')
    _erbout = ''
    @view.update_table(@table) do |form|
       _erbout << form.text_field(:category)
    end
    _erbout.should have_tag("input[type=text][name='table[category]'][value=dining]")
  end

end


describe 'update_resource with plural nested resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_leg_path).and_return('/tables/1/legs/1')
    @table = mock('table')
    @leg = mock('leg', :material => 'metal')
  end
  
  it "should render a 'update_table' form" do
    _erbout = ''
    @view.update_table_leg(@table, @leg) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.leg.update_leg', 'some-content')
  end
  
  it "the 'update_table' form should submit to the table_leg path" do
    @view.should_receive(:table_leg_path).and_return('/tables/1/legs/1')
    _erbout = ''
    @view.update_table_leg(@table, @leg) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update_leg[action=/tables/1/legs/1]')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_table_leg(@table, @leg, :class => 'metal') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.leg.update_leg.metal.metal_leg', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_table_leg(@table, @leg) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("form.update_leg input[type=text][name='leg[material]']")
  end

end


describe 'update_resource with singular nested resource and block' do
  
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
    @top = mock('top')
  end
  
  it "should render a 'update_top' form" do
    _erbout = ''
    @view.update_table_top(@table, @top) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.top.update_top', 'some-content')
  end
  
  it "the 'update_top' form should submit to the table_top path" do
    @view.should_receive(:table_top_path).and_return('/tables/1/top')
    _erbout = ''
    @view.update_table_top(@table, @top) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update_top[action=/tables/1/top]')
  end
  
  it "should allow passing in custom classnames" do
    _erbout = ''
    @view.update_table_top(@table, @top, :class => 'glass') do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.update.top.update_top.glass.glass_top', 'some-content')
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.update_table_top(@table) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("form.update_top input[type=text][name='top[material]']")
  end
  
  it "should pick up resource attributes from a model passed as the last argument" do
    @top = mock('top', :material => 'linoleum')
    @table = mock('table', :top => @top)
    _erbout = ''
    @view.update_table_top(@table, @table.top) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("input[type=text][name='top[material]'][value=linoleum]")
  end
  
  it "should pick up resource attributes from an instance variable with the resource's name" do     
    @top = mock('top', :material => 'linoleum')
    @view.instance_variable_set(:@top, @top) 
    _erbout = ''
    @view.update_table_top(@table) do |form|
       _erbout << form.text_field(:material)
    end
    _erbout.should have_tag("input[type=text][name='top[material]'][value=linoleum]")
  end

end 


describe 'update_resource with form_helpers_suffix set' do
  
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
    @view.should respond_to(:update_table_form)
    @view.should respond_to(:update_table_leg_form)
    @view.should respond_to(:update_table_top_form)
  end                        
  
end