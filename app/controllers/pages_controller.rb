class PagesController < ApplicationController

	def subscription_canceled		
	end

	def locked_business		
	end
  
  def dashboard
  	@campaigns = current_user.business.campaigns.valid_for(Date.today) rescue nil

  	# Stats
  	unless @campaigns.blank?
			stat_query      = current_user.business.locations
			today_range     = Date.today.beginning_of_day..Date.today.end_of_day
			yesterday_range = Date.yesterday.beginning_of_day..Date.yesterday.end_of_day

	  	@stats = {
				active_campaigns: 	@campaigns.size,

	  		today: {
					checkins: 			Stat.total_checkins(query: stat_query, range: today_range),
					redemptions: 		Stat.total_redemptions(query: stat_query, range: today_range),
					coupons:     		Stat.total_redemptions(type: 'coupons', query: stat_query, range: today_range),
					rewards:     		Stat.total_redemptions(type: 'rewards', query: stat_query, range: today_range),
					specials:   		Stat.total_redemptions(type: 'specials', query: stat_query, range: today_range),
					new_customers: 	Stat.new_customers(query: stat_query, range: today_range)
				},
				yesterday: {
					checkins: 		Stat.total_checkins(query: stat_query, range: yesterday_range),
					redemptions: 	Stat.total_redemptions(query: stat_query, range: yesterday_range)
				}
	  	}

	  	if @stats[:today][:checkins] > 0
	  		@stats[:today][:conversion] = (100 / @stats[:today][:checkins]) * @stats[:today][:redemptions]
	  	else
	  		@stats[:today][:conversion] = 0
	  	end


	  	# Charts
	  	chart_area = GoogleVisualr::Interactive::AreaChart.new(
		  	GoogleVisualr::DataTable.new(
		  		cols: [
		  			{type: 'string', label: 'Date'},
		  			{type: 'number', label: 'Visits'},
		  			{type: 'number', label: 'New Visits'},
		  			{type: 'number', label: 'Redemptions'},
		  		],
		  		rows: [
		  			{c: ['9/21/15', 14, 	0, 	2]},
		  			{c: ['9/22/15', 3, 	1, 	4]},
		  			{c: ['9/23/15', 12, 	6,	7]},
		  			{c: ['9/24/15', 19, 	0, 	15]}
		  		]
		  	),
		  	{
		  		title: 'Visitors (last 7 days)',
		  		height: 400,
		  		animation: {
		  		  startup: 'true',
		  		  easing: 'inAndOut',
		  		  duration: 400,
		  		},
		  		hAxis: {textPosition: 'none'},
		  		vAxis: {minValue: 0},
		  		legend: {
		  		  position: 'bottom',
		  		  maxLines: 3,
		  		},
		  		colors: [
		  		  '#4CD9B9',
		  		  '#FF0141',
		  		  '#4990E2'
		  		],
		  		areaOpacity: 0.9,
		  		backgroundColor: '#f4f4f5'
		  	}
		  )


		  chart_pie = GoogleVisualr::Interactive::PieChart.new(
		  	GoogleVisualr::DataTable.new(
		  		cols: [
		  			{type: 'string', label: 'Type'},
		  			{type: 'number', label: 'Value'},
		  		],
		  		rows: [
		  			{c: ['Coupon', [@stats[:today][:coupons], 3].max]},
		  			{c: ['Reward', [@stats[:today][:rewards], 2].max]},
		  			{c: ['Special', [@stats[:today][:specials], 1].max]}
		  		]
		  	),
		  	{
		  		title: 'Redemptions by Type (today)',
		  		height: 400,
		  		pieHole: 1,
		  		pieSliceTextStyle:{
		  			color: '#FFF',
		  		  fontSize: 15,
		  		},
		  		animation: {
		  		  startup: 'true',
		  		  duration: 400,
		  		},
		  		hAxis: {textPosition: 'none'},
		  		vAxis: {minValue: 0},
		  		legend: {
		  		  position: 'bottom',
		  		  maxLines: 3,
		  		},
		  		slices: [
		  		  {color: '#4CD9B9'},
		  		  {color: '#FF0141'},
		  		  {color: '#4990E2'}
		  		],
		  		areaOpacity: 0.9,
		  		backgroundColor: '#f4f4f5'
		  	}
		  )


		  ## Assign to view
	  	@chart = {
	  		area: chart_area,
	  		pie: chart_pie
	  	}
	  end

  	render 'blank_dashboard' if @campaigns.blank? && current_user.business.unpublished?
  end

end
