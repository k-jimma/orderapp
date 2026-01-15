module Admin
  class StaffsController < BaseController
    before_action :set_staff, only: [ :destroy ]

    def index
      # スタッフ一覧の取得
      @staffs = User.staff.order(:id)
    end

    def new
      # 新規スタッフ作成フォームの表示
      @staff = User.new(role: :staff)
    end

    def create
      # 新規スタッフの作成
      @staff = User.new(staff_params)
      @staff.role = :staff

      raw_password = staff_params[:password].presence || generate_password(14)
      # 初期パスワードは画面で表示するため別途保存
      @staff.password = raw_password
      @staff.password_confirmation = raw_password
      @staff.set_initial_password!(raw_password)

      if @staff.save
        redirect_to admin_staffs_path, notice: "スタッフを作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    rescue StandardError => e
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    def destroy
      # スタッフの削除
      @staff.destroy!
      redirect_to admin_staffs_path, notice: "削除しました"
    rescue StandardError => e
      redirect_to admin_staffs_path, alert: e.message
    end

    private

    def set_staff
      # 対象スタッフの取得
      @staff = User.staff.find(params[:id])
    end

    def staff_params
      # スタッフ作成用パラメータの許可
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def generate_password(len = 14)
      # 文字種が必ず混ざるように生成
      lower = ("a".."z").to_a
      upper = ("A".."Z").to_a
      digits = ("0".."9").to_a
      symbols = %w[! @ # $ % ^ & * _ - +]
      all = lower + upper + digits + symbols

      pw = []
      pw << lower.sample
      pw << upper.sample
      pw << digits.sample
      pw << symbols.sample
      pw << all.sample while pw.length < len
      pw.shuffle.join
    end
  end
end
