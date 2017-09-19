# Trains
## Trains problem solution

### Input data
1. Replace *data.txt* file in root directory with your own test data before run
2. Or add new data file to main directory and update trains.rb:2 line

### Example of use
```
require_relative 'lib/graph'

graph = Graph.new('data.txt')
# Длина маршрута 'A'->'B'->'C'
graph.distance('A-B-C')

# The shortest route from 'A' to 'C'
graph.shortest_route_distance_for('A', 'C')

# Routes with the travel distance less then 30
graph.routes_with_less_distance('C', 'C', 30)

# Routes from 'C' to 'C'
graph.routes_for('C', 'C', stops: 3)
```

### Run tests
Run specs in project directory

```rspec spec/```

### Run benchmark test

```ruby benchmark.measure```

### Restrictions

1. MAX_NODES_REPEAT = 4. This restriction is made to avoid too many duplicate nodes in routes.

### Ruby version
2.4.1

### TODOs

1. Implement this as a gem package
2. Calculation of map should be impelemented with C or Rust for better perfomance.
3. Allow to pass a data file from command line
