%{
  title: "Fixing broken images on Mastodon",
  author: "Daniel King",
  tags: ~w(software mastodon debugging rails),
  description: "How to fix missing avatars and other media on a Mastodon server"
}
---

If you manage your own [Mastodon](https://docs.joinmastodon.org/user/run-your-own/) instance you have to consider all the storage required for image and video assets, particularly if you're running on a cheap VPS. Providers like Hetzner and DigitalOcean will only give you around 25GB of storage on their smallest servers.

After filling the storage on my server a few weeks ago I scrambled to fix the issue, and in the process deleted a few assets manually, this left me with a lot of broken images.

![Mastodon account with a broken avatar image](/images/missing-avatar.png)

This issue comes down to how Mastodon tracks cached assets, it uses the Ruby gem [Paperclip](https://github.com/thoughtbot/paperclip) to download and store images like avatars and any posted by accounts you follow. This caching is required since hotlinking is generally considered bad behavior and would be blocked in most cases.

When the image is cached Paperclip stores the path to where it was stored, when the image is used later a URL is passed to the view, there is no checking that the image is still there. Mastodon only considers the image missing (and attempts to redownload) if the related fields are missing.

Because of this behavior you can easily end up with broken images that Mastodon will not automatically re-download.

## Fixing the images

NOTE: These instructions were correct as of Mastodon v4.2.0, but could be out of date in a later version.

You can check if the actual image files are still on disk with Paperclip's `exists?` method. Chaining this with a call to reset the image fields will trigger the image to be re-downloaded.

Start by ssh'ing into your server, then become the Mastodon user and load the Rails console with:

``````
bundle exec rails c
```

You can iterate over all accounts, checking for avatars and resetting as needed with this script:

```ruby
Account.find_each do |account|
  if account.avatar.exists?
    print '.'
  else
    account.reset_avatar!
    account.save!
    print '*'
  end
  
rescue
  print 'e'
end
```

This could be many thousands of accounts, so will likely take some time. Mastodon stores not only the accounts you follow, but also any that have been boosted by the people you follow. You could make the script concurrent to speed it up, but I wanted to avoid hitting any rate limits.

## How does this differ from the `tootctl media refresh` command?

If you have this issue with broken images there's a chance you've already tried the [media refresh](https://docs.joinmastodon.org/admin/tootctl/#media-refresh) command, if your underlying issue is like mine though, it will have not fixed your images.

This command (with the `--force` flag) will just re-download media attachments from posts, not images attached to accounts like avatars.

## A better option for asset storage

Following this issue I moved my server's assets to a third-party [object store](https://docs.joinmastodon.org/admin/optional/object-storage/), this should hopefully prevent future storage issues and make the server easier to manage.

I used Backblaze, they give you the first 10GB free and charge $0.006 per GB/Month after that. If you're thinking of making the move I'd advise you use their [CLI tool](https://www.backblaze.com/docs/cloud-storage-command-line-tools) to quickly sync your existing `public/system` directory:

```
./b2-linux sync public/system b2://your-bucket-name
```

## A quick fix

You might want to avoid your cache filling too quickly by setting the "Media cache retention period" in your [server settings](https://masto.host/mastodon-content-retention-settings/) to something low like 3 days, Mastodon will then attempt to re-download deleted media in posts older than this if you view them later.

For a single user server, that low retention period is fine, but with a few more users I think you should consider caching for much longer. It is fairer to other server hosts to avoid downloading assets from them over and over again.

One more note on the "Content cache retention period" option also found in your server settings: You might want to keep this low too, but that comes with cost of losing valuable favourites, boosts and bookmarks. There is an [open discussion](https://github.com/mastodon/mastodon/discussions/19260) on the Mastodon github around how a single setting for deleting remote content is a problem, in particular for posts you favourite, it seems like this should be retained longer, somehow preferenced over other remote assets.

Finally, if you're looking for some general advice on running a single-user Mastodon server, I'd advise you take a look at [Julia Evans' post](https://jvns.ca/blog/2023/08/11/some-notes-on-mastodon/) on her experience, it goes into detail on the downsides like losing some reply visibility and how you can mitigate them.
