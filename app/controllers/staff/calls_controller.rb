module Staff
  class CallsController < BaseController
    def index
      # 最新200件の呼び出し履歴を取得
      @calls = Call.includes(:table).order(created_at: :desc).limit(200)
    end

    def update
      # 呼び出しのステータスを更新
      call = Call.find(params[:id])
      call.update!(call_params)
      redirect_to staff_calls_path, notice: "更新しました"
    rescue StandardError => e
      redirect_to staff_calls_path, alert: e.message
    end

    private

    def call_params
      # 強く許可するパラメータを指定
      params.require(:call).permit(:status)
    end
  end
end
