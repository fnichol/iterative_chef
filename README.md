# Interative Chef

## Setup

Clone the repository and install some gem dependencies:

    git clone git://github.com/fnichol/iterative_chef.git
    cd iterative_chef
    gem install chef vagrant rocco

Now build all the vagrant boxes. **Warning** this could take up to 20 minutes
to complete (there are 5 boxes to populate):

    rake bootstrap
