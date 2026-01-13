module Staff
  class CallsController < BaseController
    def index
      @calls = Call.includes(:table).order(created_at: :desc).limit(200)
    end

    def update
      call = Call.find(params[:id])
      call.update!(call_params)
      redirect_to staff_calls_path, notice: "更新しました"
    rescue StandardError => e
      redirect_to staff_calls_path, alert: e.message
    end

    private

    def call_params
      params.require(:call).permit(:status)
    end
  end
end
