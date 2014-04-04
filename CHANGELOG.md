TraceView Cookbook CHANGELOG
============================

0.3.0
-----
- Renamed the cookbook to `traceview` from `tracelytics`.

0.2.0
-----
- Renamed `tracelytics::apache` to `tracelytics::apache2`
- Set up a [Drone](https://drone.io/github.com/sprintly/tracelytics-chef) project
- Set up a `Berksfile`, `Gemfile`, and basic `Rakefile`
- Cleaned up [foodcritic](http://acrmp.github.io/foodcritic/#FC043) warnings
- Added some basic [chefspec](https://github.com/sethvargo/chefspec) coverage for `tracelytics::apache2`, `tracelytics::apt`, and `tracelytics::default`
- Added a `name` attribute to `metadata.rb`

0.1.0
-----
- Initial release.
