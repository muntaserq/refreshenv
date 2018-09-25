# refreshenv
A Chef ruby resource to refresh environment variables on Windows OS

# refreshenv

A useful resource to refresh the ENV variable in Ruby during a chef client run.
You can use this in any recipe within a cookbook that depends on refreshenv.
This resource handles both SYSTEM and USER environment variables.

This resource was created to handle scenarios in a chef client run when the workflow needs environment variables that are added to the system or user environment variables during a chef client run and are needed soon thereafter within the same chef client run. For example, you are installing a piece of software using chef and it adds a value to the PATH environment variable. You need to invoke the exe or what have you soon in the next recipe. You can simply refresh your environment variables in place and not have to wait for another chef client run. See recommendations for more info.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

You will need the Chef Development Kit setup on your development machine before running this locally.

You can download and setup the Chef DK at this following page:
```
https://downloads.chef.io/chefdk
```

## Running the tests

Explain how to run the automated tests for this system

You can execute the tests on this cookbook by running:

```
chef exec rspec
```

## Deployment

You can use this in any recipe within a cookbook that depends on refreshenv.

Simply call the resoure anywhere in a recipe or another resource like this:

```
refresh_env 'Refreshing Environment Variables' do
  action :create
end
```

## Recommendations
It probably doesn't make sense to be refreshing the environment variables every chef client run. Chef client does that for you already. The purpose of this resource is to refresh the environment when there is a need to do so, for example you've installed software that inserts values to the PATH environment variable and you need access to those paths soon thereafter. This is why I recommend you use an action of :nothing and call the resouce stub when needed using a notify.

```
refresh_env 'Refreshing Environment Variables' do
  action :nothing
end
```

## Built With

* [Chef](https://docs.chef.io/chef_overview.html) - an automation platform that transforms infrastructure into code

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. 

## Authors

* **Muntaser Qutub** - *Initial work* - [muntaserq](https://github.com/muntaserq)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
