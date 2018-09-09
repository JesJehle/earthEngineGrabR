from ee.oauth import get_credentials_path


path = get_credentials_path()

path_new = path.replace('credentials', 'refresh_token.json')

print(path)
print(path_new)