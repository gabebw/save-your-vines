# Save Your Liked Vines

This script will:

* Download all of your favorite Vines (_not_ Vines you've uploaded)
* Make a Jekyll blog
* Create a Jekyll post for each Vine, with its date set to the Vine's upload
  date

Then you can publish it to GitHub Pages!

## Let's do it

First, fork this repo. Then clone it locally and run:

    ./did-it-for-the-vine.sh

It will prompt you for your Vine username and password then download your vines
and make a blog post for each one. If you need to stop it or anything goes
wrong, you can safely run the script again. It will pick up where it left off.

## After the script finishes

1. You'll probably want to edit `docs/_config.yml` to change your Twitter
   name, etc. I recommend changing `title`, `email`, `description`,
   `twitter_username`, and `github_username`. You can totally skip this step
   though!
1. If you renamed the repo to something other than `save-your-vines`, then
   change `baseurl` in `docs/_config.yml` to your new repo name, otherwise the
   links won't work on GitHub.
1. Commit your changes to Git.
1. Push to GitHub, which will take at least 10 minutes.
1. Visit this repo's settings page and scroll down to the "GitHub Pages"
   section. Select "master branch /docs folder" as the source and save.
1. Wait a minute or two then reload the page. In the "GitHub Pages" section
   you'll see a green message with a link to your new blog.
1. You're done!
