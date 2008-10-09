require File.dirname(__FILE__) + '/spec_helper'

describe 'resource_table' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    @view = ActionView::Base.new
  end
  
  it "should render a table with CLASS 'resource_table'" do
    _erbout = ''
    @view.user_table do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('table.user_table', 'some-content')
  end
  
  it "should allow passing in additional classnames" do
    _erbout = ''
    @view.user_table(:class => 'online') do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('table.user_table.online.online_user_table', 'some-content')
  end
  
  it "should allow giving the table an id via the :id option" do
    _erbout = ''
    @view.user_table(:id => 'online_users') do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('table#online_users', 'some-content')
  end
  
end


describe 'resource_row' do
  
  before do
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    @view = ActionView::Base.new
  end
  
  it "should a list item with resource class" do
    _erbout = ''
    @view.user_row do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('tr.user', 'some-content')
  end
  
  it "should allow passing in additional classes" do
    _erbout = ''
    @view.user_row(:class => 'online') do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('tr.user.online.online_user', 'some-content')
  end
  
  it "should allow passing in a model, the id of which will be used for the id" do
    _erbout = ''
    user = mock('user', :id => 1)
    @view.user_row(user) do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('tr.user#user_1', 'some-content')
  end
  
end    




