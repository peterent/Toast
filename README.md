
Toast displays information overlaid on the active UIViewController. The Toast "pops up" from one of the sides
of the UIViewController (the bottom, by default). The Toast can be any UIView and comes ready to use UILabel
when you supply a String. There are a variety of options to control its appearance and whether or not remain
on the screen for a short period of time (the default) or to sit permanently until dismissed (either by the
user with a swipe gesture or programmatically). You can also summon a Toast to block the user's input which is
handy when loading content.

In addition to a UILabel, a you can also supply your own UIView - either directly or from a UIViewController
(such as one loaded from a Storyboard). You might, for example, have a tool palette to display as a result of
a user action or a progress bar to display while content is being downloaded.

For a quick, temporary notice to the user (such as when saving a record), use the Toast.quick() class method
and supply the message you want them to see:

      Toast.quick(self, message: "Record Saved")

This Toast will display for approximately 1/2 second and then disappear (you can change the interval).

      let toast = Toast.blocking(self, message: "Content Loading...", isBlurry: true)
      ... load your content ...
      toast.dismiss()

This Toast will blur the screen and display the message. It remains visible until removed using the
dismiss() function.
