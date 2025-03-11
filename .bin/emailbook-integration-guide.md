# Configuring Emailbook with Terminal Email Clients

This guide shows how to integrate your Google Directory contacts (via emailbook) with various terminal email clients.

## Prerequisites

1. You have successfully set up the Google Directory to Emailbook converter
2. Your contacts are available at `~/.local/share/emailbook/emails`
3. You have emailbook installed (if not, see: https://sr.ht/~maxgyver83/emailbook/)

## Setting Up Emailbook

Emailbook itself is a simple tool that provides a fuzzy-search interface to your email contacts. The `emails` file should now be automatically populated by our script.

If you haven't installed emailbook yet:

```bash
# Install dependencies
sudo apt install fzf # or equivalent for your distro

# Clone emailbook
git clone https://git.sr.ht/~maxgyver83/emailbook
cd emailbook

# Install
make install # or `make DESTDIR=~/.local install` for a local installation
```

## Integration with Neomutt

Add these lines to your `~/.muttrc` or `~/.config/neomutt/neomuttrc`:

```
# Emailbook integration
set query_command = "emailbook %s"
bind editor <Tab> complete-query
bind editor ^T complete
```

Now you can:
1. Start composing an email (press `m`)
2. Start typing a recipient name/email
3. Press `Tab` to search through your Google Directory contacts

## Integration with Aerc

Add these lines to your `~/.config/aerc/aerc.conf`:

```
[compose]
address-book-cmd=emailbook
```

Now you can:
1. Start composing an email (press `c`)
2. Press `Tab` when your cursor is in the To/Cc/Bcc field
3. Type part of a name/email to search your Google Directory contacts

## Integration with NMH/MMHX

Add these lines to your `.mh_profile`:

```
draft-folder: drafts
Editor: emailbook-mmh
```

## Testing Your Setup

To test if the integration is working properly:

1. Run the converter script manually to ensure contacts are being fetched:
   ```
   ~/.local/bin/google-directory-to-emailbook.py
   ```

2. Check that the contacts file is populated:
   ```
   wc -l ~/.local/share/emailbook/emails
   ```

3. Test emailbook directly:
   ```
   emailbook smith
   ```
   This should show a fuzzy search interface listing contacts matching "smith"

## Troubleshooting

### No contacts being fetched

- Ensure your OAuth credentials are correct
- Check that you have the necessary permissions in your university Google Workspace
- Look at the logs: `cat ~/.local/share/emailbook/update.log`

### Authentication issues

If you see authentication errors:
1. Delete the token file: `rm ~/.config/google-directory-token.pickle`
2. Run the script again to re-authenticate

### Email client not using emailbook

- Make sure the path to emailbook is in your PATH
- Check that your email client configuration is correct
- Try running the query command manually to confirm it works

## Updating Contacts Manually

Although you've set up a cron job, you can always update contacts manually:

```bash
~/.local/bin/google-directory-to-emailbook.py
```

This will fetch the latest contacts from your university's Google Directory and update your emailbook contacts.
