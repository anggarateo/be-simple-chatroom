class Message < ApplicationRecord
    validates :content, :user, presence: true
end
