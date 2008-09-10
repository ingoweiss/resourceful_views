require File.dirname(__FILE__) + '/spec_helper'

describe ResourcefulViews, 'resourceful_classnames' do
  
  it "should assemble a space-separated list of standardized CSS classnames" do
    classnames = ResourcefulViews.resourceful_classnames('user', 'create')
    classnames.should eql('user create create_user')
  end
  
  it "should accept additional custom classnames" do
    # 'search' is the custom classname
    classnames = ResourcefulViews.resourceful_classnames('users', 'index', 'search')
    classnames.should eql('users index index_users search search_users')
  end
  
  it "should accept symbolized arguments" do
    classnames = ResourcefulViews.resourceful_classnames(:users, :index, :search)
    classnames.should eql('users index index_users search search_users')
  end
  
end
