# frozen_string_literal: true

module DomniqApp
  class PushReceipt < ActiveRecord::Base
    # Uses the pre-existing domniq_app_push_notification_receipts table.
    # The table has columns: push_notification_id (ignored), token, receipt_id,
    # timestamps. We only use token and receipt_id.
    self.table_name = "domniq_app_push_notification_receipts"

    validates :receipt_id, presence: true, uniqueness: true
    validates :token, presence: true
  end
end
