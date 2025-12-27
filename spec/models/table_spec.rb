require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:tenant) { create(:tenant) }
  let(:store) { create(:store, tenant: tenant) }
  let(:table) { create(:table, tenant: tenant, store: store) }

  describe 'associations' do
    it 'tenantに属する' do
      expect(table.tenant).to eq(tenant)
    end

    it 'storeに属する' do
      expect(table.store).to eq(store)
    end
  end

  describe 'validations' do
    it 'numberが必須' do
      table = build(:table, number: nil)
      expect(table).not_to be_valid
    end

    it 'numberが店舗内でユニーク' do
      create(:table, store: store, number: 'T1')
      duplicate = build(:table, store: store, number: 'T1')
      expect(duplicate).not_to be_valid
    end
  end

  describe '#generate_qr_code' do
    it 'QRコードが自動生成される' do
      expect(table.qr_code).to be_present
    end

    it 'QRコードがユニークである' do
      table1 = create(:table, tenant: tenant, store: store, number: 'T1')
      table2 = create(:table, tenant: tenant, store: store, number: 'T2')
      expect(table1.qr_code).not_to eq(table2.qr_code)
    end
  end

  describe '#occupy!' do
    it 'ステータスがoccupiedになる' do
      table.occupy!
      expect(table.status).to eq('occupied')
    end
  end

  describe '#make_available!' do
    it 'ステータスがavailableになる' do
      table.update!(status: :occupied)
      table.make_available!
      expect(table.status).to eq('available')
    end
  end
end
