class SitesController < ApplicationController

  layout :sites_layout

  def home
    if @site
      site_home
    else
      general_home
    end
  end

  def general_home
    @main_page = MainPage.order('id asc').first
    @sites = Site.published.paginate :per_page => 20, :page => params[:page], :order => 'id DESC'
    render :general_home
  end

  def site_home
    @projects = Project.custom_find @site, :per_page => 10,
                                           :page => params[:page],
                                           :order => 'created_at DESC'

    @footer_sites = @site.sites_for_footer

    respond_to do |format|
      format.html do
        # Get the data for the map depending on the region definition of the site (country or region)
        if @site.geographic_context_country_id
          sql="select r.id,count(ps.project_id) as count,r.name,r.center_lon as lon,
                    r.center_lat as lat,r.name,

                    CASE WHEN count(distinct ps.project_id) > 1 THEN
                        '/location/'||r.path
                    ELSE
                        '/projects/'||(array_to_string(array_agg(ps.project_id),''))
                    END as url,

                    r.code
                    from ((projects_regions as pr inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{@site.id})
                    inner join projects as p on pr.project_id=p.id and (p.end_date is null OR p.end_date > now())
                    inner join regions as r on pr.region_id=r.id and r.level=#{@site.level_for_region})
                    group by r.id,r.name,lon,lat,r.name,r.path,r.code"
        else
          sql="select c.id,count(ps.project_id) as count,c.name,c.center_lon as lon,
                    c.center_lat as lat,

                    CASE WHEN count(distinct ps.project_id) > 1 THEN
                        '/location/'||c.id
                    ELSE
                        '/projects/'||(array_to_string(array_agg(ps.project_id),''))
                    END as url,

                    iso2_code as code
                    from countries_projects as cp
                    inner join projects_sites as ps on cp.project_id=ps.project_id and site_id=#{@site.id}
                    inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
                    inner join countries as c on cp.country_id=c.id
                    group by c.id,c.name,lon,lat,iso2_code"
        end

        result = ActiveRecord::Base.connection.execute(sql)
        @map_data = result.map do |r|
          r['url'] = r['url'] + "?force_site_id=#{@site.id}" unless @site.published?
          r
        end.to_json
        @overview_map_chco = @site.theme.data[:overview_map_chco]
        @overview_map_chf = @site.theme.data[:overview_map_chf]
        @overview_map_marker_source = @site.theme.data[:overview_map_marker_source]
        areas= []
        data = []
        @map_data_max_count=0
        result.each do |c|
          areas << c["code"]
          data  << c["count"]
          if(@map_data_max_count < c["count"].to_i)
            @map_data_max_count=c["count"].to_i
          end
        end
        @chld = areas.join("|")
        @chd  = "t:"+data.join(",")
        render 'site_home_map', :layout => false and return if params[:embed].present?
        render request.fullpath.match('home2') ? :site_home2 : :site_home
      end
      format.js do
        render :update do |page|
          page << "$('#projects_view_more').remove();"
          page << "$('#projects').html('#{escape_javascript(render(:partial => 'projects/projects'))}');"
          page << "IOM.ajax_pagination();"
          page << "resizeColumn();"
        end
      end
      format.csv do
        send_data Project.to_csv(@site),
          :type => 'text/plain; charset=utf-8; application/download',
          :disposition => "attachment; filename=#{@site.name}_projects.csv"
      end
      format.xls do
        send_data Project.to_excel(@site),
          :type        => 'application/vnd.ms-excel',
          :disposition => "attachment; filename=#{@site.name}_projects.xls"
      end
      format.kml do
        @projects_for_kml = Project.to_kml(@site)

        render :site_home
      end
      format.xml do
        @rss_items = Project.custom_find @site, :start_in_page => 0, :random => false, :per_page => 1000

        render :site_home
      end
    end
  end

  def about
  end

  def about_interaction
  end

  def contact
  end

end
