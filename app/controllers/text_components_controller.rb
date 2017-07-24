class TextComponentsController < ApplicationController
  before_action :set_text_component, only: [:show, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_form_data, only: [:show, :index]

  # GET /text_components
  # GET /text_components.json
  def index
    set_index_data
    @text_component = @new_text_component
  end

  # GET /text_components/1
  # GET /text_components/1.json
  def show
  end

  # POST /text_components
  # POST /text_components.json
  def create
    set_form_data

    @text_component = TextComponent.new(text_component_params)

    @text_component.triggers.each do |trigger|
      if trigger.report.nil?
        trigger.report = @text_component.report
      end
      trigger.conditions.each {|c| c.trigger = trigger } # both trigger and condition are new and need to be connected
    end

    respond_to do |format|
      if @text_component.save
        format.html { redirect_to report_text_component_path(@report, @text_component), notice: 'Text component was successfully created.' }
        format.json { render :show, status: :created, location: @text_component }
      else
        format.html do
          set_index_data
          render :index
        end
        format.json { render json: @text_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /text_components/1
  # PATCH/PUT /text_components/1.json
  def update
    set_form_data

    respond_to do |format|
      if @text_component.update(text_component_params)
        format.html { redirect_to report_text_component_path(@report, @text_component), notice: 'Text component was successfully updated.' }
        format.json { render :show, status: :ok, location: @text_component }
      else
        format.html do
          set_index_data
          render :index
        end
        format.json { render json: @text_component.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /text_components/1
  # DELETE /text_components/1.json
  def destroy
    @text_component.destroy
    respond_to do |format|
      format.html { redirect_to report_text_components_path(@report), notice: 'Text component was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_text_component
      @text_component = TextComponent.find(params[:id])
    end

    def set_form_data
      @sensors = Sensor.where(report: @report).order('name')
      @events = Event.order('name')
    end

    def set_index_data
      @new_text_component = TextComponent.new
      @new_text_component.triggers.build
      @new_text_component.report = Report.current
      @text_components = TextComponent.includes(:triggers, :question_answers, :channels)

      filter_text_components

      @trigger_groups = @text_components.order('from_day').group_by(&:trigger_ids)

      @trigger_groups = @trigger_groups.map do |trigger_ids, components|
        [Trigger.find(trigger_ids), components]
      end

      @trigger_groups = @trigger_groups.sort do |a, b|
        group1, group2 = a.first, b.first
        if group1.present? && group2.present?
          group1.map(&:name).sort.first <=> group2.map(&:name).sort.first
        else
          group2.count <=> group1.count # groups with no trigger will be sorted to the end
        end
      end

      @trigger_groups = @trigger_groups.to_h

      set_form_data
    end

    def filter_text_components
      @text_components = @text_components.where(report: @report)
      @filter = params[:filter] || {}
      if @filter[:assignee_id].present?
        @text_components = @text_components.where(assignee_id: @filter[:assignee_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def text_component_params
      params.require(:text_component)
        .permit(:heading, :introduction, :main_part, :closing, :from_day,
                :to_day, :report_id, :topic_id, :assignee_id, :publication_status, :notes,
                trigger_ids: [], channel_ids: [],
                question_answers_attributes: [:id, :question, :answer, :_destroy],
                triggers_attributes: [:name, :from_hour, :to_hour,
                                      :priority, :report_id,
                                      :validity_period,
                                      :event_ids => [],
                                      conditions_attributes: [:id, :sensor_id, :from, :to, :_destroy]] )
    end
end
