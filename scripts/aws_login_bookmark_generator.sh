#!/usr/bin/env python3

# THIS IS HELPFUL BECAUSE THEN YOU CAN GO IN YOUR OMNIBAR AND TYPE
# accountname.role and it'll be right there

import os
import configparser
from string import Template
import click

# Create a template
BOOKMARK_ITEM = Template('<DT><A HREF="https://$login_domain/start/#/console?account_id=$account_id&role_name=$role_name">$profile_title</A></DT>\n')

def process_profile(profile_name, profile_config):
    print(f"Processing profile: {profile_name}")
    return dict(
        profile_title=profile_name,
        role_name=profile_config['sso_role_name'],
        account_id=profile_config['sso_account_id'],
    )

@click.command()
@click.argument('login_domain')
def main(login_domain):
    """
    Generate AWS login links for all profiles in the AWS config file.

    This script will generate an output.html file which you can import into your browser to get
    one click links to your various AWS accounts.

    LOGIN_DOMAIN: Your AWS SSO login domain (e.g., 'd-1234567890.awsapps.com')

    To find your login domain:
    1. Check your ~/.aws/config file for 'sso_start_url' entries
    2. Extract the domain from URLs like 'https://d-1234567890.awsapps.com/start'
    3. Or check your AWS SSO portal URL that your admin provided
    4. Or run 'aws sso login' and note the domain in the browser URL
    """
    aws_config_path = os.path.expanduser('~/.aws/config')
    config = configparser.ConfigParser(interpolation=None)
    config.read(aws_config_path)
    alpha_ordered_profiles = sorted(config.sections())
    with open('output.html', 'w') as f:
        f.write('<DL>\n')
        f.write('\t<DT><H3> AWS Login Links</H3></DT>\n')
        f.write('\t<DL>\n')
        for profile in alpha_ordered_profiles:
            if not profile.startswith('profile '):
                continue
            if 'default' in  profile:
                continue
            profile_name = profile[len('profile '):]
            profile_config = dict(config[profile])
            values = process_profile(profile_name, profile_config)
            values.update(dict(login_domain=login_domain))
            f.write(BOOKMARK_ITEM.substitute(values))
        f.write('\t</DL></DL>\n')

if __name__ == "__main__":
    main()
