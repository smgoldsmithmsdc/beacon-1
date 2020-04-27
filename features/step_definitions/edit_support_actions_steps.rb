Given('a resident with a support action exists') do
  @contact = Contact.create!(first_name: 'Test')
  @need = Need.create!(contact_id: @contact.id, name: 'Dog walking', category: 'Dog walking')
end

When('I (assign)/(have assigned) the support action to me') do
  visit "/needs/#{@need.id}"
  page.select 'test@test.com', from: 'need_user_id'
  @expected_assignee = 'test@test.com'
  page.find('.notice', text: 'Need was successfully updated.')
end

When('I assign the support action to another user') do
  @another_user = User.create!(email: 'other_user@email.com', invited: Date.today)
  visit "/needs/#{@need.id}"
  page.select 'other_user@email.com', from: 'need_user_id'
  @expected_assignee = 'other_user@email.com'
  page.find('.notice', text: 'Need was successfully updated.')
end

When("I change the support action status to 'complete'") do
  visit "/needs/#{@need.id}"
  page.select 'Complete', from: 'need_status'
  page.find('.notice', text: 'Need was successfully updated.')
end

And("the support action has status 'to do'") do
  # need is incomplete by default
end

Then("I see the support action in the 'assigned to me' page") do
  visit "/?user_id=#{@user.id}"
  table_row = find('tbody tr')
  assignee_column = table_row.find('td:nth-child(8)')
  expect(assignee_column).to have_content 'test@test.com'
end

Then("I no longer see the support action in the 'assigned to me' page") do
  visit "/?user_id=#{@user.id}"
  content_panel = find('p.no-results')
  expect(content_panel).to have_content 'No matches'
end

And("I see the updated support action details in the contact's {string} list") do |area|
  visit "/contacts/#{@contact.id}"
  need_row = get_area_panel(area).find('tbody tr')
  assignee_column = need_row.find('td:nth-child(3)')
  expect(assignee_column).to have_content @expected_assignee
end

When("I change someone else's support action status to 'complete'") do
  visit "/needs/#{@need.id}"

  Capybara.using_session('Second_users_session') do
    visit "/needs/#{@need.id}"
    page.select 'admin@test.com', from: 'need_user_id'
    @expected_assignee = 'admin@test.com'
    page.find('.notice', text: 'Need was successfully updated.')
  end
  page.select 'Complete', from: 'need_status'
end

Then('I see my support action change was unsuccessful') do
  page.find('.alert', text: 'Error. Somebody else has changed this record, please refresh.')
  visit "/needs/#{@need.id}"

  # should be in 'To do'
  status = page.find('#status-actions__field select').value
  expect(status).to have_content 'to_do'
end

def get_area_panel(area)
  case area
  when 'support actions'
    panel_selector = '.with-left-sidebar__right .panel.panel--unpadded:nth-of-type(2)'
  when 'completed'
    panel_selector = '.with-left-sidebar__right .panel.panel--unpadded:nth-of-type(3)'
  else
    raise "Cannot look for non-existent panel #{area}"
  end
  page.find(panel_selector)
end
