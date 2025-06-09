
```
sqlite3 ../db.sqlite3 -header -csv "SELECT * FROM project;" > project.csv
sqlite3 ../db.sqlite3 -header -csv "SELECT * FROM year;" > year.csv

brew install awscli
aws configure

# Terraform isn't OSI-compliant as of Apr 2025?
# brew install terraform
# We'll use https://opentofu.org/ as a drop-in replacement instead? 
brew install opentofu
tofu init
tofu plan -out tf.out
tofu apply tf.out
```

