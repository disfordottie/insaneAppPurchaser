# Insane iOS App Purchaser

A script to purchase apps in bulk.

## Why on earth would this be useful?

Apps are frequently removed from the appstore. Hence my thinking was, if I can purchase as many apps as possible, whenever an app is removed I can go download it later from my purchase list.
- There is now a list of EVERY app on the appstore if your serious about making sure you keep access to them all (Press 2 on main menu)

## Star History

<a href="https://star-history.com/#disfordottie/insaneAppPurchaser&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=disfordottie/insaneAppPurchaser&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=disfordottie/insaneAppPurchaser&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=disfordottie/insaneAppPurchaser&type=Date" />
 </picture>
</a>

## To Do

- [x] Automated ipatool installer
- [x] Add settings menu
- [ ] Add Logs/Lists
- - [ ] Do not purchase again: Successful purchases, already owned,
- - [ ] Blocked apps for paid apps to not attempt then again on any account.
- - [ ] Try again: various 1 time errors

## Usage

### Help! I just want it to open!
1. Type ``` chmod -R +x ``` then drag the downloaded script file onto your terminal window and press enter.
- Example: ``` chmod -R +x ~/Desktop/Insane-iOS-App-Purchaser.sh ```
2. Then drag the file onto your terminal window again and press enter.
- Example: ``` ~/Desktop/Insane-iOS-App-Purchaser.sh ```

### Using your own list

Plase a file named "bundleIds.txt" in the same file as the script.
* It should be formatted the same as the following, one Bundle ID per line.
```
com.naturalmotion.clumsyninja
com.mediocre.smashhit
com.klgamesllc.escapechallenge
```

### Using existing lists

1. Press 2 on the main menu
2. Select the list you would like to use

**Help! I'm getting an error loading the lists!**
- First make sure you can access [this link.](https://api.github.com/repos/disfordottie/insaneAppPurchaser/contents/Lists?ref=main)
- If you can't, try manually downloading the list you want from the github, then use option 1 on the main menu.

## Obtaining Bundle ID's
**As of 1.1 you can now use the built in lists!** Some Examples include:
- Every iOS 3 - iOS 6 app
- Internal Apple Apps

Another script I've made hase multiple ways to get Bundle ID's: [Insane App Converter](https://github.com/disfordottie/insaneAppConverter)

## Credits
**majd** for making [ipatool](https://github.com/majd/ipatool) which is what makes this script possible.
