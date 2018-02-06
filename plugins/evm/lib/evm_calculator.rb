class EvmCalculator
    # def get_issues(project_id)
    #     @current_project = Project.find(project_id)
    #     @root_project = Issue.select(:parent_id).distinct.where('parent_id IS NOT NULL AND project_id=?', @current_project.id)
    #     if(@root_project.blank?)
    #         @issues = Issue.where.not(parent_id: @root_project.to_a)
    #     end
    # end


    attr_accessor :issue_id, :pv, :ev, :av, :cpi, :spi, :sv, :cv, :bac, :cal_date

    NOT_AVAILABLE = "N/A"

    #initial
    def initialize(issue, options = {})
        #Calculated base on today

        @bac = issue.estimated_hours
        @cal_date = !options[:cal_date] ? Date.yesterday : options[:cal_date]

        if ((!issue.due_date.blank? && !issue.estimated_hours.blank?))
            if (@cal_date < issue.due_date )
              @pv = calculate_planed_value(issue.start_date, issue.due_date, @cal_date, issue.estimated_hours)
            else
              @pv = @bac
            end
        else
            @pv = NOT_AVAILABLE
        end

        if(!issue.estimated_hours.blank? && !issue.done_ratio.blank?)
            @ev = calculate_earned_value(issue.done_ratio, issue.estimated_hours)
        else
            @ev = NOT_AVAILABLE
        end

        @pv = metric_round(@pv, 1)
        @ev = metric_round(@ev, 1)

        @av = issue.spent_hours

        @cpi = calculate_cpi(@ev,@av)
        @cpi = metric_round(@cpi, 1)

        @spi = calculate_spi(@ev,@pv)
        @spi = metric_round(@spi, 1)

        @sv = calculate_sv(@ev,@pv)
        @sv = metric_round(@sv, 1)

        @cv = calculate_cv(@ev,@av)
        @cv = metric_round(@cv, 1)

        @issue_id = issue.id
    end

    # working_day
    # @param [date] start_date
    # @param [date] due_date
    # @return [array] working_days
    def working_days(start_date, end_date)
        issue_days = (start_date..end_date).to_a
        working_days = issue_days.reject{|e| e.wday == 0 || e.wday == 6}
        working_days.length == 0 ? issue_days : working_days
    end

    # PV
    # @param [date] start_date
    # @param [date] due_date
    # @param [date] calculated_date The date is computed
    # @param [float] estimated hours
    # @return [float] PV
    def calculate_planed_value(start_date, end_date, calculate_date, estimated_hours)
        working_days_length = working_days(start_date, end_date).length
        calculate_date_length = working_days(start_date, calculate_date).length
        pv = calculate_date_length.to_f/working_days_length * estimated_hours

        return pv
    end

    # EV
    # @param [integer] done_ratio (0-100)
    # @param [float] estimated hours
    # @return [float] PV
    def calculate_earned_value(done_ratio, estimated_hours)
        ev = done_ratio.to_f/100 * estimated_hours
        return ev
    end

    # CPI
    def calculate_cpi(ev,av)
        cpi = (ev == NOT_AVAILABLE || av <= 0.0) ? NOT_AVAILABLE : ev/av
        return cpi
    end

    # SPI
    def calculate_spi(ev,pv)
        spi = (ev == NOT_AVAILABLE || pv == NOT_AVAILABLE) ? NOT_AVAILABLE : ev/pv
        return spi
    end

    # SV
    def calculate_sv(ev,pv)
        sv = (ev == NOT_AVAILABLE || pv == NOT_AVAILABLE) ? NOT_AVAILABLE : ev - pv
        return sv
    end

    # CV
    def calculate_cv(ev,av)
        cv = (ev == NOT_AVAILABLE) ? NOT_AVAILABLE : ev - av
        return cv
    end

    # Total EVM
    # @param [Arr of EvmCalculator] evmList
    # @param [date] calDate key of the hash
    # @return [hash] evmHash {caldate=> {'bac'=>bac, 'pv'=>pv, 'ev'=>ev, 'cv'=>cv} }
    def self.calculate_total(evmHash, calDate)
        bac = pv = ev = av = 0.0
        evmHash.each do |key, evm|
            bac = (evm.bac != nil) ? (bac + evm.bac) : bac
            pv = (evm.pv != NOT_AVAILABLE) ? (pv + evm.pv) : pv
            ev = (evm.ev != NOT_AVAILABLE) ? (ev + evm.ev) : ev
            av = (evm.av != NOT_AVAILABLE) ? (av + evm.av) : av
        end

        cpi = (ev == NOT_AVAILABLE || av <= 0.0) ? NOT_AVAILABLE : ev/av
        spi = (ev == NOT_AVAILABLE || pv == NOT_AVAILABLE) ? NOT_AVAILABLE : ev/pv
        sv = (ev == NOT_AVAILABLE || pv == NOT_AVAILABLE) ? NOT_AVAILABLE : ev - pv
        cv = ev == NOT_AVAILABLE ? NOT_AVAILABLE : ev - av

        bac = metric_round(bac, 1)
        pv = metric_round(pv, 1)
        ev = metric_round(ev, 1)
        av = metric_round(av, 1)
        cpi = metric_round(cpi, 1)
        spi = metric_round(spi, 1)
        sv = metric_round(sv, 1)
        cv = metric_round(cv, 1)

        evmTotalHash = {}
        evmTotalHash[calDate] = {'bac'=>bac, 'pv'=>pv, 'ev'=>ev, 'av'=>av, 'cpi' => cpi, 'spi'=>spi, 'sv'=>sv, 'cv'=>cv}

        return evmTotalHash
    end

    #Round digit for class
    def self.metric_round(metric, numberDigit)
        metric = (metric != NOT_AVAILABLE) ? metric.round(numberDigit) : metric
        return metric
    end

    #Round digit
    def metric_round(metric, numberDigit)
        metric = (metric != NOT_AVAILABLE) ? metric.round(numberDigit) : metric
        return metric
    end
end
