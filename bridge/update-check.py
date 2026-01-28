import sys, os, requests, json

is_pull_request = sys.argv[1] == "true"
if is_pull_request:
    print("This is a pull request, skipping")
    exit(0)

def git(command):
    return os.system(f"git {command}")

def check_version(directory, new_version):
    if not new_version:
        print("Failed to get new version")
        exit(1)

    print(f"Latest release is {new_version}")

    with open(f"{directory}/VERSION", "r") as f:
        old_version = f.read().rstrip()
    
        if old_version == new_version:
            print(f"No change")
            exit(0)

    # commit
    git("config --local user.name 'GitHub Actions'")
    git("config --local user.email 'actions@github.com'")

    git("add -A")

    result = git(f"commit -m 'Bump {directory} version to {new_version}'")
    if result != 0:
        print("Failed to commit")
        exit(1)

    result = git("push")
    if result != 0:
        print("Failed to push")
        exit(1)

    # save new release
    with open(f"{directory}/VERSION", "w") as f:
        f.write(new_version)

    print(f"Recorded release {new_version}")

# get latest release
release = requests.get("https://api.github.com/repos/protonmail/proton-bridge/releases/latest").json()
version = release['tag_name']

check_version("bridge", version)
