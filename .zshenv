# Re-located Snowflake CLI Config and other exports
export SNOWFLAKE_HOME="$HOME/.config/snowflake"
export DBT_DEV_SCHEMA="fliv"
export EDITOR=nvim

# Next Energy Exports
export SNOWFLAKE_USER="filip.livancic@vivanti.com"
export SNOWFLAKE_ROLE="DATA_ENGINEER"
export SNOWFLAKE_PRIVATE_KEY_PATH="$HOME/.ssh/keys/dbt_next_energy_filip_livancic.pem"

# Adding to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Users/filiplivancic/.local/bin"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$HOME/.local/bin/scripts:$PATH"
. "$HOME/.cargo/env"


#For compilers to find libpq you may need to set:
#  export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
#  export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
#[filip.livancic@Mac ~/Documents/client/next_energy/sandb
