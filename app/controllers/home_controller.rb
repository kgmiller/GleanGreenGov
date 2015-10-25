class HomeController < ApplicationController
  def index
  	
  	@data = SmarterCSV.process('GreenBuildings.csv')
  	
  	@data_sort_by_water_change_percentage = @data.sort_by { |v| v[:percentage_change_water_use_between_2010_2014].gsub!('%','').to_i }

  	@columns = Array.new
  	@columns.push(Array.new(['x','2003','2010', '2011', '2012', '2013', '2014']))

  	@data.each do |department|
  		
  		if (department[:total_2003_kbtu] != nil && department[:total_2010_kbtu] != nil && department[:total_2011_kbtu] != nil && department[:total_2012_kbtu] != nil && department[:total_2013_kbtu] != nil && department[:total_2014_kbtu] != nil)
  			
  			department[:total_2003_kbtu].gsub!(',','') if department[:total_2003_kbtu].is_a?(String)
  			department[:total_2010_kbtu].gsub!(',','') if department[:total_2010_kbtu].is_a?(String)
  			department[:total_2011_kbtu].gsub!(',','') if department[:total_2011_kbtu].is_a?(String)
  			department[:total_2012_kbtu].gsub!(',','') if department[:total_2012_kbtu].is_a?(String)
  			department[:total_2013_kbtu].gsub!(',','') if department[:total_2013_kbtu].is_a?(String)
  			department[:total_2014_kbtu].gsub!(',','') if department[:total_2014_kbtu].is_a?(String)
  			department[:thousand_square_feet].gsub!(',','') if department[:thousand_square_feet].is_a?(String)

  			sqft = department[:thousand_square_feet].to_d

  			@columns.push(Array.new([department[:department_name], department[:total_2003_kbtu].to_d / sqft, department[:total_2010_kbtu].to_d / sqft, department[:total_2011_kbtu].to_d / sqft, department[:total_2012_kbtu].to_d / sqft, department[:total_2013_kbtu].to_d / sqft, department[:total_2014_kbtu].to_d / sqft]))
  		end
  	end

  	#@data.each do |department|
  	#	@columns.push(Array.new([department[:department_name], department[:total_2010_kbtu].gsub!(',','').to_d, department[:total_2011_kbtu].gsub!(',','').to_d, department[:total_2012_kbtu].gsub!(',','').to_d, department[:total_2013_kbtu].gsub!(',','').to_d, department[:total_2014_kbtu].gsub!(',','').to_d]))
  	#end
  	
  end

  def buildings
    @data2013 = SmarterCSV.process('buildings_2013.csv')
    @data2014 = SmarterCSV.process('buildings_2014.csv')

    @department_buildings_2013 = Hash.new
    @merged_data = Hash.new
    @columns = Array.new
    @property_types = Hash.new
    @property_types['All Property Types'] = ''

    #puts params[:department_name]

    @data2013.each do |building|

      if params[:property_type] == nil || params[:property_type] == '' || building[:"primary_property_type___self_selected"] == params[:property_type]
        if building[:property_id] != nil && building[:"site_energy_use_(kbtu)"] != nil
          @department_buildings_2013[building[:property_id]] = {:usage => building[:"site_energy_use_(kbtu)"]}
        end
      end

      unless @property_types.include?(building[:"primary_property_type___self_selected"])

        @property_types[building[:"primary_property_type___self_selected"]] = building[:"primary_property_type___self_selected"]

      end
    
    end

    @data2014.each do |building|

      if params[:property_type] == nil || params[:property_type] == '' || building[:"primary_property_type___self_selected"] == params[:property_type]
        if building[:property_id] != nil && building[:"site_energy_use_(kbtu)"] != nil && @department_buildings_2013[building[:property_id]] != nil

          @merged_data[building[:property_id]]= {:usage_2014 => building[:"site_energy_use_(kbtu)"].to_d,
            :usage_2013 => @department_buildings_2013[building[:property_id]][:usage].to_d,
            :property_name => building[:property_name],
            :department_name => building[:department_name],
            :sqft => building[:"property_gfa___epa_calculated_(buildings)_(ft²)"],
            :location => building[:location]
          }

        end     
      end
    
    end

    @columns.push(Array.new(['x','2013', '2014']))

    @merged_data.each do |key, building|

        if building[:sqft] != nil && building[:usage_2013] != nil && building[:usage_2014] != nil
          sqft = building[:sqft].to_d

          if (building[:usage_2013].to_d / sqft) < 500 && (building[:usage_2014].to_d / sqft) < 500
            @columns.push(Array.new([building[:department_name] + " <br/> " + building[:property_name], building[:usage_2013].to_d / sqft, building[:usage_2014].to_d / sqft]))
          end
        
        end

    end


  end

  def building
		
		@data2013 = SmarterCSV.process('buildings_2013.csv')
		@data2014 = SmarterCSV.process('buildings_2014.csv')

		@department_buildings_2013 = Hash.new
		@merged_data = Hash.new
		@columns = Array.new

		puts params[:department_name]

		@data2013.each do |building|

			if building[:department_name] == params[:department_name]
				if building[:property_id] != nil && building[:"site_energy_use_(kbtu)"] != nil
					@department_buildings_2013[building[:property_id]] = {:usage => building[:"site_energy_use_(kbtu)"]}
				end
			end
		
		end

		@data2014.each do |building|

			if building[:department_name] == params[:department_name]
				if building[:property_id] != nil && building[:"site_energy_use_(kbtu)"] != nil && @department_buildings_2013[building[:property_id]] != nil

					@merged_data[building[:property_id]]= {:usage_2014 => building[:"site_energy_use_(kbtu)"].to_d,
						:usage_2013 => @department_buildings_2013[building[:property_id]][:usage].to_d,
						:property_name => building[:property_name],
						:sqft => building[:"property_gfa___epa_calculated_(buildings)_(ft²)"],
						:location => building[:location]
					}

				end			
			end
		
		end

		@columns.push(Array.new(['x','2013', '2014']))

		@merged_data.each do |key, building|

  			if building[:sqft] != nil && building[:usage_2013] != nil && building[:usage_2014] != nil && @columns.count <= 70
  				sqft = building[:sqft].to_d

  				if (building[:usage_2013].to_d / sqft) < 500 && (building[:usage_2014].to_d / sqft) < 350 
  					@columns.push(Array.new([building[:property_name], building[:usage_2013].to_d / sqft, building[:usage_2014].to_d / sqft]))
  				end
  			
  			end

		end

  end
end
