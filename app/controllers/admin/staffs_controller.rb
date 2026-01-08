module Admin
  class StaffsController < BaseController
    before_action :set_staff, only: [ :destroy ]

    def index
      @staffs = User.staff.order(:id)
    end

    def new
      @staff = User.new(role: :staff)
    end

    def create
      @staff = User.new(staff_params)
      @staff.role = :staff

      raw_password = staff_params[:password].presence || generate_password(14)
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
      @staff.destroy!
      redirect_to admin_staffs_path, notice: "削除しました"
    rescue StandardError => e
      redirect_to admin_staffs_path, alert: e.message
    end

    private

    def set_staff
      @staff = User.staff.find(params[:id])
    end

    def staff_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def generate_password(len = 14)
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
