require File.expand_path('../../test_helper', __FILE__)

class EvmCalculatorTest < ActiveSupport::TestCase
    fixtures :projects,:issues,:time_entries

    # def test_get_issues
    #     @issues = EvmCalculator.new()
    #     Rails::logger.debug @issues.inspect
    # end
    setup do 
        @sample_issues = Issue.find(1)
        @evmSampleIssue = EvmCalculator.new(@sample_issues)

        no_duedate_issues = Issue.find(16)
        @evmNoDueDateIssue = EvmCalculator.new(no_duedate_issues)

    end

    def test_working_day
        working_days = @evmSampleIssue.working_days(@sample_issues.start_date, @sample_issues.due_date)

        sample_woking_day = @evmSampleIssue.working_days(DateTime.parse("Mon, 22 Jan 2018"), DateTime.parse("Fri, 26 Jan 2018"))
        sample_woking_day2 = @evmSampleIssue.working_days(DateTime.parse("Mon, 22 Jan 2018"), DateTime.parse("31 Jan 2018"))
        sample_woking_day3 = @evmSampleIssue.working_days(DateTime.parse("6 Jan 2018"), DateTime.parse("31 Jan 2018"))

        # Issue is not start
        sample_woking_day4 = @evmSampleIssue.working_days(DateTime.parse("6 Jan 2018"), DateTime.parse("5 Jan 2018"))

        # pv = evmIssue.calculate_planed_value(issues)
        assert_equal sample_woking_day.length, 5
        assert_equal sample_woking_day2.length, 8
        assert_equal sample_woking_day3.length, 18
        assert_equal sample_woking_day4.length, 0

        assert(working_days.length <= 10 && working_days.length >=1)

        #no due date and estimated hours    
        
        assert_equal @evmNoDueDateIssue.pv, "N/a"

        # Rails::logger.debug @evmNoDueDateIssue.pv.inspect
    end

    def test_calculate_planed_value
        # 5 days working time
        evm1 = @evmSampleIssue.calculate_planed_value(
            DateTime.parse("Mon, 22 Jan 2018"), 
            DateTime.parse("Fri, 26 Jan 2018"), 
            DateTime.parse("27 Jan 2018"), 
            25.0)
        
        # 3 days working time    
        evm2 = @evmSampleIssue.calculate_planed_value(
            DateTime.parse("5 Jan 2018"), 
            DateTime.parse("9 Jan 2018"), 
            DateTime.parse("7 Jan 2018"), 
            15.0)

        # 0 days working time    
        evm3 = @evmSampleIssue.calculate_planed_value(
            DateTime.parse("5 Jan 2018"), 
            DateTime.parse("19 Jan 2018"), 
            DateTime.parse("3 Jan 2018"), 
            15.0)

        # 0 working time    
        evm4 = @evmSampleIssue.calculate_planed_value(
            DateTime.parse("5 Jan 2018"), 
            DateTime.parse("19 Jan 2018"), 
            DateTime.parse("3 Jan 2018"), 
            0.0)
        
        assert_equal evm1, 25.0*5/5
        assert_equal evm2, 15.0*1/3
        assert_equal evm3, 0.0
        assert_equal evm4, 0.0
        assert_equal @evmNoDueDateIssue.ev, "N/a"

        # Rails::logger.debug @evmSampleIssue.av.inspect
    end

    def test_actual_value
        issue = Issue.find(15)
        evm1 = EvmCalculator.new(issue)

        assert_equal evm1.av, 12.5
        # Rails::logger.debug evm1.bac.inspect
    end
end