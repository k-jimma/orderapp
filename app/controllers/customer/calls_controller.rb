module Customer
  class CallsController < BaseController
    include TableAccessGuard

    def create
      # テーブルからの呼び出しを登録
      Call.create!(
        table: current_table,
        kind: call_params[:kind],
        message: call_params[:message],
        status: :open
      )
      redirect_back fallback_location: table_order_path(token: current_table.token), notice: "呼び出しを送信しました"
    rescue ActiveRecord::RecordInvalid => e
      redirect_back fallback_location: table_order_path(token: current_table.token), alert: e.record.errors.full_messages.to_sentence
    end

    private

    def call_params
      # Strong Parametersで呼び出しパラメータを許可
      params.require(:call).permit(:kind, :message)
    end
  end
end
