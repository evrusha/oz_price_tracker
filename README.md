# OZ Price Tracker

This is a web application which shows prices changes of selected goods from the OZ.BY shop.

## Installation

### Prerequisites

You need to have installed in your system:

- RVM
- Ruby 3.2.5
- PostgreSQL 15

#### RVM Installation

Install [RVM](https://rvm.io/).

#### Ruby Installation

```
rvm install 3.2.5
```

```
rvm use 3.2.5
```

#### PostgreSQL Installation

Visit https://www.postgresql.org/download/.


## Project Setup

Clone project from GitHub:

```
git clone https://github.com/evrusha/oz_price_tracker.git
```

Navigate the project folder and run:

```
bundle
```

### Initialize project database settings

```
rails db:setup
```

### Run web server

```
rails s
```

### Run sidekiq server

```
bundle exec sidekiq
```

## Profit!!!
