require File.dirname(__FILE__) + '/spec_helper'


describe 'search_resource with plural resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:tables_path).and_return('/tables')
  end
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_tables
    markup.should have_tag('form[action=/tables][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_tables
    markup.should have_tag('form.search.tables.search_tables')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_tables
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_tables(:label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_tables
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    @view.instance_variable_set(:@query, 'dining')
    markup = @view.search_tables
    markup.should have_tag('input[type=text][name=query][value=dining]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.search_tables(:button => {:title => 'Click to search'})
    markup.should have_tag('button[title=Click to search]')
  end
  
  it "should allow for submitting additional parameters via the :sending option" do
    markup = @view.search_tables(:sending => {:order_by => 'name'})
    markup.should have_tag('input[type=hidden][name=order_by][value=name]')
  end
  
  it "should allow for submitting additional parameters via the :parameters option" do
    markup = @view.search_tables(:parameters => {:order_by => 'name'})
    markup.should have_tag('input[type=hidden][name=order_by][value=name]')
  end
  
  it "should issue a deprecation warning when submitting additional parameters via the :parameters option" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.search_tables(:parameters => {:order_by => 'name'})
  end
  
end
              

describe 'search_resource with plural resource and block' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:tables_path).and_return('/tables')
  end
  
  it "should render a form GETTing to the resource path" do
    _erbout = ''
    @view.search_tables do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form[action=/tables][method=get]')
  end

  it "should render a search_resources form" do
    _erbout = ''
    @view.search_tables do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.search_tables', 'some-content')
  end  
  
  it "should not render a text field for the query" do
    _erbout = ''
    @view.search_tables do
       _erbout << 'some-content'
    end
    _erbout.should_not have_tag('input[type=text][name=query]')
  end
  
  it "should allow for submitting additional parameters via the :sending option" do
    _erbout = ''
    @view.search_tables(:sending => {:order_by => 'name'}) do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('input[type=hidden][name=order_by][value=name]')
  end
  
  it "should allow for submitting additional parameters via the :parameters option (legacy)" do
    _erbout = ''
    @view.search_tables(:parameters => {:order_by => 'name'}) do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('input[type=hidden][name=order_by][value=name]')
  end
  
  it "should issue a deprecation_warning when submitting additional parameters via the :parameters option" do
    _erbout = ''
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.search_tables(:parameters => {:order_by => 'name'}) do
       # somthing
    end
  end

end


describe 'search_resource with plural nested resource' do
  
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
  
  it "should render a form GETTing to the resource path" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('form[action=/tables/1/legs][method=get]')
  end
  
  it "should render a search_resource form" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('form.search.legs.search_legs')
  end
  
  it "should render a 'Search' submit button by default" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('button[type=submit]', 'Search')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.search_table_legs(@table, :label => 'Find')
    markup.should have_tag('button[type=submit]', 'Find')
  end
  
  it "should render a text field for the query" do
    markup = @view.search_table_legs(@table)
    markup.should have_tag('input[type=text][name=query]')
  end
  
  it "should fill in the instance variable @query as the query value" do
    @view.instance_variable_set(:@query, 'dining')
    markup = @view.search_table_legs(@table)
    markup.should have_tag('input[type=text][name=query][value=dining]')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.search_table_legs(@table, :button => {:title => 'Click to search'})
    markup.should have_tag('button[title=Click to search]')
  end
  
  it "should allow for submitting additional parameters via the :parameters option" do
    markup = @view.search_table_legs(@table, :parameters => {:order_by => 'name'})
    markup.should have_tag('input[type=hidden][name=order_by][value=name]')
  end
  
end


describe 'search_resource with form_helpers_suffix set' do
  
  before do
    ResourcefulViews.form_helpers_suffix = '_form'
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
  end
  
  it "should define helpers with suffix" do
    @view.should respond_to(:search_tables_form)
    @view.should respond_to(:search_table_legs_form)
  end
  
end

