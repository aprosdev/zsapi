require 'rails_helper'

RSpec.describe Customer, type: :model do

  describe "Validations" do
    before :each do
  		@customer = FactoryGirl.build(:customer)
  	end

  	it "has a valid factory" do
  		expect( FactoryGirl.build(:customer) ).to be_valid
  	end

  	# Presence
  	%w(first_name last_name email).each do |attr|
	  	it "validates presenve of #{attr}" do
	  		@customer.send("#{attr}=", nil)
	  		expect(@customer).not_to be_valid
		  end
	 	end

	  # Unique
	  it "must have a unique email address" do
	  	customer = FactoryGirl.create(:customer)
	  	expect( FactoryGirl.build(:customer, email: customer.email) ).not_to be_valid
	  end
	end


	describe "Associations" do
		# it { should have_many :redemptions }
		it { should have_many :visits }
		it { should have_many(:locations), through: :visits }
		it { should have_many(:wallets) }
	end


	describe "Methods" do
		before :all do
			@customer = FactoryGirl.build(:customer)
		end

		it "#name" do
			@customer.first_name = "Wes"
			@customer.last_name = "Foster"
			expect( @customer.name ).to eq "Wes Foster"
		end

		it "#name_reversed" do
			@customer.first_name = "Wes"
			@customer.last_name = "Foster"
			expect( @customer.name_reversed ).to eq "Foster, Wes"
		end

		it "#active?" do
			@customer.active = true
			expect(@customer.active?).to be_truthy
			@customer.active = false
			expect(@customer.active?).to be_falsey
		end

		it "#contacted?" do
			@customer.contacted = true
			expect(@customer.contacted?).to be_truthy
			@customer.contacted = false
			expect(@customer.contacted?).to be_falsey
		end

		describe "Points" do
			before :each do
				@business = FactoryGirl.create(:business)
				@customer = FactoryGirl.create(:customer)
				@wallet = FactoryGirl.create(:wallet, business: @business, customer: @customer, points: 500)
			end

			context "when wallet not set" do
				it "#points(@business)" do
					expect(@customer.points(@business)).to eq 500
				end

				it "#set_points(amount, @business)" do
					@customer.set_points(250, @business)
					@customer.save
					@customer.reload
					expect(@customer.points(@business)).to eq 250
				end

				it "#increase_points_by(amount, @business)" do
					@customer.increase_points_by(250, @business)
					@customer.save
					@customer.reload
					expect(@customer.points(@business)).to eq 750
				end
			end

			context "when wallet is set" do
				before :each do
					@customer.wallet = @business
				end

				it "#points" do
					expect(@customer.points).to eq 500
				end

				it "#set_points(amount)" do
					@customer.set_points(250)
					@customer.save
					@customer.reload
					expect(@customer.points).to eq 250
				end

				it "#increase_points_by(amount)" do
					@customer.increase_points_by(250)
					@customer.save
					@customer.reload
					expect(@customer.points).to eq 750
				end
			end
		end

		describe "Visits" do
			it "#visit!" do
				location = FactoryGirl.create(:location_with_business)
				customer = FactoryGirl.create(:customer_with_wallet_without_business, business: location.business)
				expect{customer.visit!(location)}.to change{Visit.count}.by(1)
			end
		end
	end


	describe "Scopes" do
		it ".active" do
			FactoryGirl.create_list(:customer, 3, active: true)
			expect(Customer.active.length).to eq 3
		end

		it ".inactive" do
			FactoryGirl.create_list(:inactive_customer, 3)
			expect(Customer.inactive.length).to eq 3
		end
	end

end