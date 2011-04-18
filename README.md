# Interative Chef

## Setup

Clone the repository and install some gem dependencies:

    git clone git://github.com/fnichol/iterative_chef.git
    cd iterative_chef
    bundle install
    gem install chef

Yeah, that's right. Install chef outside of the Gemfile. Don't get me started
about this json gem version incompatibility. Anway, no harm, no foul.

Now build all the vagrant boxes. **Warning** this could take up to 20 minutes
to complete (there are 5 boxes to populate):

    rake bootstrap
