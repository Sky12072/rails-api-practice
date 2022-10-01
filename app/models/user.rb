class User < ApplicationRecord
    has_secure_password # to deal with that password digest

    # add some validations such as username and email
    validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
end
