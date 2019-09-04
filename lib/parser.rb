require_relative 'job_posting'
require_relative 'alert'

# responsible for pulling data from page to return job postings
class Parser
  attr_reader :browser, :driver

  def initialize(driver, browser)
    @driver = driver
    @browser = browser
  end

  def parse_jobs
    jobs = []

    job_cards.each_with_index do |job_card, i|
      go_to_card(job_card, i)
      begin
        job = parse_job_posting(job_card)
        Alert.of_pass_of_fail_for(job)
        jobs << job
      rescue Selenium::WebDriver::Error::NoSuchElementError
        next # prime, skip
      end
    end

    jobs
  end

  private

  def go_to_card(job_card, i)
    browser.scroll_to_card(i)
    job_card.click
    sleep(1)
  end

  def job_cards
    driver.find_elements(class: 'jobsearch-SerpJobCard')
  end

  def parse_job_posting(job_card)
    position = driver.find_element(id: 'vjs-jobtitle').text
    company = driver.find_element(id: 'vjs-cn').text
    location = driver.find_element(id: 'vjs-loc').text
    description = driver.find_element(id: 'vjs-content').text
    id = job_card.attribute('id')
    JobPosting.new(position: position, company: company, location: location,
                   description: description, id: id)
  end
end