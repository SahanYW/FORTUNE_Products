<p align="center">
    <a href="https://github.com/SahanYW/FORTUNE_Products">
        <img src="https://cdn.discordapp.com/attachments/704013007310815232/862098362786381853/Fortune_Car_Parts_and_Tuning_Sticker_7300x.png?ex=681d30aa&is=681bdf2a&hm=3a5ce1ed97387a4bd889eb95942d721dba3c35c3f8d770ed46088e6042d7ee6e&">
    </a>
</p>

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](http://choosealicense.com/licenses/mit/)
[![Discord](https://img.shields.io/discord/700220790280552518?style=for-the-badge&logo=discord&logoColor=white&label=Discord)](https://discord.gg/KS5Jnwt)
[![Roblox](https://img.shields.io/badge/Roblox_Community_Page-blue.svg?style=for-the-badge)](https://www.roblox.com/communities/6769995/FORTUNE-Car-Parts-Tuning#!/about)

# FORTUNE Product Repository
FORTUNE is a community that provides free models and scripts to the developers of the Roblox car community.

> [!TIP]
> Check out our latest releases [here](https://github.com/SahanYW/FORTUNE_Products/releases)


## Finding Products
Most products can be found on the [releases page](https://github.com/SahanYW/FORTUNE_Products/releases)

Legacy products are currently in the process of being added to the repository. If you do not see a release for a product on the releases page, please [create an issue](https://github.com/SahanYW/FORTUNE_Products/issues).

__All releases__ can be found in [the discord](https://discord.gg/KS5Jnwt).

## Contributing
Contributions are always welcome. Currently, FORTUNE is only looking for updates/improvements to exisitng products. If you would like to see a new product, send a message in [the discord](https://discord.gg/KS5Jnwt)!

> [!NOTE]
> Both Rojo and non-Rojo workflows are acceptable, but for the sake of consistency pull requests must include a `/src` folder containing `.luau` files in their corresponding directories.

### File structure
To accomodate for the large amount of products, each sub-directory under the root repository will represent a product in the following format:
```
root/
├── product1/
│   ├── latest_release.rbxm
│   ├── previous_releases/
│   │   ├── v1.0.rbxm
│   │   ├── v1.1.rbxm
│   │   ...
│   └── src/
│       ├── service1/
│       │   └── *.luau files
│       └── service2/
│           └── *.luau files
├── product2/
│── product3/
...
```

Subject to change if a better file structure is found.

---

### Getting started
#### Using Rojo + Visual Studio Code

Rojo allows developers to integrate industry tools like **git** and **Visual Studio Code** into their Roblox Studio workflow. It essentially allows you to edit Roblox experiences with an external IDE. In the context of this project, its main purpose is to allow for the use of version control (git).

- [Rojo Setup](https://devforum.roblox.com/t/how-to-setup-and-use-rojo-may-2023/2322815) (Detailed explanation on configuring Rojo)
- [Download Visual Studio Code](https://code.visualstudio.com/download)
- [Rojo VSCode Extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
- [Rojo Roblox Studio Plugin](https://create.roblox.com/store/asset/6415005344/Rojo-7)

Open the product directory in VSCode and open the command palette using `Ctrl+Shift+P`

Search and run `Rojo: Open Menu`

Install Rojo in the directory if it has not been installed already

> [!WARNING]
> If a new instance of Rojo has been installed, you must configure the `default.project.json` file which requires too much explanation for this note. Use other products such as `VehicleSpawner` as reference on how to configure the file.
>
> An alternative solution exists [here](https://github.com/rojo-rbx/rbxlx-to-rojo)
> 
> If you run into problems or cannot figure it out, send a message in [the discord](https://discord.gg/KS5Jnwt).

Run Rojo (green arrow)

Open Roblox Studio and open the Rojo plugin

Click "connect"

Rojo is now synced and any edits made to the scripts in VSCode will apply to the scripts in studio!

---

#### Using Roblox Studio

Open/Create the product `.rbxl` file

Add any changes to the `/src` files

> [!NOTE]
> All `.luau` files must exist in a folder named after its corresponding parent service (i.e. ReplicatedStorage, ServerScriptService, etc.)

If creating a new script, use the following file extensions
- `.client.luau` for local scripts
- `.server.luau` for server scripts
- `.luau` for module scripts