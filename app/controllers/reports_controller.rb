# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!, except: %i[current present preview]

  def current
    if @report
      if params[:preview]
        redirect_to preview_report_path(@report)
      else
        redirect_to present_report_path(@report)
      end
    else
      render :no_reports
    end
  end

  def present
    @live_entry = DiaryEntry.new(report: @report, release: :final, moment: query_params[:point_in_time])
    @diary_entries = diary_entries.final
  end

  def preview
    @live_entry = DiaryEntry.new(report: @report, release: :debug, moment: query_params[:point_in_time])
    @diary_entries = diary_entries.debug
    render 'present'
  end

  def update
    if @report.update(report_params)
      redirect_to @report
    else
      render 'new'
    end
  end

  private

  def query_params
    result = {}
    result[:point_in_time] = if params[:at]
                               Time.zone.parse(params[:at])
                             else
                               Time.zone.now
                             end
    result
  end

  def diary_entries
    DiaryEntry.where(report: @report).order(:moment).reverse_order.limit(3)
  end

  def report_params
    params.require(:report).permit(:name, :start_date, :duration, :video, variables_attributes: %i[value id])
  end
end
