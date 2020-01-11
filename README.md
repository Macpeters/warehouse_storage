# Getting Started
This is a basic rails app, and doesn't require anything special to get it running.

### Install the app
```
bundle install
bundle exec rake db:migrate

```

### Run the app
``` bundle exec rails s  ```

### Run the tests
```  bundle exec rspec ```



# Problem

We would like to provide our sales team a way to customize warehouse storage pricing for our customers.
Requirements

### Flat Rate
The flat fee for storing a single item is $20, applicable to all customers.

### Customer Specific Fees and discounts
* Customer A will receive a 10% discount.
* Customer B stores large items, and will be charged at $1 per unit of volume.
* Customer C is to be charged 5% of the value of the item being stored.
* Client D will have a 5% discount for the first 100 items stored, 10% discount for the next 100, and then 15% on each additional item, and be charged at $2 per unit of volume for all items.

### Open to Customization
We want our sales team to be able to express any new pricing criteria with as few code changes as possible. For example, another customer could receive a flat $200 discount when the price exceeds $400.
Task

## Task
Write an endpoint to create pricing for each of the customers given the conditions above.
Write an endpoint which will quote any customer with the expected price given n storage items. Items can be added or subtracted. The input is as follows:

```
[
  {
    'name' => 'Fridge',
    'length' => '3',
    'height' => '6',
    'width' => '300',
    'value' => '1000'
  },
  {
    'name' => 'sofa',
    'length' => '6',
    'height' => '4',
    'width' => '3',
    'weight' => '100',
    'value' => '300'
  }
]
```

## Before Completion
Add documentation on how to make the API calls
Please package the project into a single zip file. Please upload this zip to your own google docs or dropbox etc and provide a link in your follow up email.


# TODO
* add a rate_adjustment model, customer has_many rate_adjustments.  Calc for each adjustment_type is stored in the RateAdjustment Model.

* validate method calls
* validate adjustment_types are in the list



# Solution

## JSON Format
```

{
  'customer_id' => '1234',
  'adjustments' => [

  ]
  'items' => [
    {
      'id' => '242',
      'name' => 'Fridge',
      'length' => '3',
      'height' => '6',
      'width' => '300',
      'value' => '1000',
      'adjustments' => [

      ]
    },
    {
      'name' => 'sofa',
      'length' => '6',
      'height' => '4',
      'width' => '3',
      'weight' => '100',
      'value' => '300',
      'adjustments' => []
    }
  ]
}

```

## Flat Rate Fee
All customers will be charged a flat rate of $20 per item stored

## Special Adjustments
These are adjustments that can be added/removed in order to customize storage pricing for the customer.
The value is the amount that will be discounted or added onto the fee.
There are a number of adjustments available which will have different effects on the pricing.
Multiple adjustments can be added to the customer and/or individual item

### Adjustments that can apply to all Items belonging to a Customer
These are fees/disounts that can apply to all items, or to the overall rate being charged.
Some Adjustments require a threshold.

#### bulk_item_discount
  * min and max threshold are required
  * all items numbering between the min/max will be discounted the adustment value

#### bulk_items_discount
  * min and max threshold are required
  * to add a discount to the first 100 items stored, use min=1, max=100
  * to add a discount to the second 100 items stored, use min=101, max=200

#### flat_discount
  * the value will be applied as a percentage discount to the entire rate.  Use this to give the customer 5% off their rate for a month.  Set the expiry date

#### heavy_items_fee # max threshold required
  * all items with a weight exceeeding the max threshold will add an extra fee equal to the adjustment value

#### large_items_fee # max threshold required
  * all items with a volume exceeding the max threshold will add an extra fee equal to the adjustment value


### Adjustments that apply to specific items only
#### heavy_item_fee
  * add this to a specific item known to be heavy, without having to add a specific weight.
  * this item will add a charge of the adjustment value

#### large_item_fee
  * add this to any item known to be large, without having to add a specific weight, length, or height.
  * this item will add a charge of the adjustment value

#### item_value_fee
  * add this to items requiring special handling.
  * this item will add a charge of the adjustment value

