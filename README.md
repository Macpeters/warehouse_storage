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
```  bundle exec rspec spec ```



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
