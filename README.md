# Pre-work - *TipsApp*

**TipsApp** is a tip calculator application for iOS.

Submitted by: **Akrm Almsaodi**

Time spent: **+30** hours spent in total

## User Stories

The following **Required** functionality is complete:

* [x] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [x] Settings page to change the default tip percentage.

The following **Optional** features are implemented:

* [x] UI animations
* [x] Remembering the bill amount across app restarts (if <10mins)
* [x] Using locale-specific currency and currency thousands separators.
* [x] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing.

The following **Additional** features are implemented:

* [x] Smart Tip Advisor: Using CoreML to detect product through vision detection using Inceptionv3 Model
* [x] Shake the phone to erase current calculations and to enter new bill.
* [x] The app looks right in all screen sizes in Portrait orientation.
* [x] Dark and Light themes
* [x] Using SVProgressHUD and ASValueTrackingSlider Pods for better user experinece
* [x] The ability to dynamically split the bill between multiple payers
* [x] Rounding up/down the share to easily pay the bill
* [x] The option to include/exclude the sales tax in calculating the tip
* [x] The ability to change the 3 default tip percentages in settings
* [x] The ability to change the maximum default number of payers
* [x] Link to external resource to learn more about the appropriate tip percentages

**Notes and thoughts:**
1. I purposely tried to practice in this project as many new concepts as possible such as class extentions, protocols, segues, Cocoapods, closures, CoreML, Vision, OOP, and MVC Model and more! For this reason, the project might look more complicated than it should be :)
2. The style of the keyboard on the GIF is not normal because the app was running on the beta version of iOS 11.
3. The very big size of the app directory is due to the big Machine Learing file (Inceptionv3)
4. Please make sure to run this app on iOS 11 to get full functionality.
5. I started already another app that is more complicated and usefull involving tableviews, contacts, notification prodcasting, and local notifications, and much more. I feel very confident that I will overcome all of the challenges that you can come up with, and will be of assistance to my other colleagues.

## Video Walkthrough 

<img src='https://media.giphy.com/media/3o6vXIWnl1rScxMN8Y/giphy.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />
Higher resolution GIF: https://media.giphy.com/media/l1J3OU3vElH8Na3ks/giphy.gif

GIF created with GIF Brewery 3 (http://gifbrewery.com).

## Project Analysis  
As part of your pre-work submission, please reflect on the app and answer the following questions below:  

**Question 1**: "What are your reactions to the iOS app development platform so far? How would you describe outlets and actions to another developer? Bonus: any idea how they are being implemented under the hood? (It might give you some ideas if you right-click on the Storyboard and click Open As->Source Code")  

**Answer:** 
As a firmware developer, I found working in the iOS app development platform is very intuitive and fun. Also, a lot of the hard work is already implemented by Apple’s folks in form of Frameworks that allow us to utilize the device hardware resources. Xcode makes development very fast and less buggy by suggesting name of functions and properties and always suggest corrections during the development stage. Also the simulator is very handy during the first stage of development. Also being able to run and debug the app on the device directly without a need for an external debugger is very impressive and makes the work simpler. Regarding Swift, I can’t compliment this language enough; it is very powerful and offers everything I need with flexibility and beautiful syntax. 

In terms of describing outlets and actions, I would simply say that they are referencing objects and methods that allow us to programmatically interact with the components implanted in the linked nib or storyboard files. The keywords @IBOutlet and @IBAction indicate to the interface builder that these variables and methods are accessible; and thus it will allow for links between them and its views. In other words, IBOutlet variable is an UI output, and IBAction is an UI input’s handler. So for example if a user creates an action by clicking a button, the interface builder will execute the linked IBAction method. 


**Question 2**: "Swift uses [Automatic Reference Counting](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID49) (ARC), which is not a garbage collector, to manage memory. Can you explain how you can get a strong reference cycle for closures? (There's a section explaining this concept in the link, how would you summarize as simply as possible?)"  

**Answer:**
A strong reference cycle occurs when two objects have strong retained reference to each other.  Now since closures in swift are objects, Automatic Reference Counting apply to them. With this being said, we can get a strong reference cycle if we have a property of a class that has a closure (calculated property), which captures self to access one of the other class prosperities.  In this case, the closure and the instance of the class will have a strong reference to each other, and the ARC will never be able to get rid of them; in another word, we will have a memory leak!

We can avoid this condition by making a weak or unowned reference to self. However, using weak reference will capture self as an optional type, and it will need 
