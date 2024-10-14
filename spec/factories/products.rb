FactoryBot.define do
  factory :product do
    oz_id { Faker::Number.unique.number(digits: 5) }
    price { Faker::Commerce.price(range: 10.0..100.0) }
    link { Faker::Internet.url }
  end
end
