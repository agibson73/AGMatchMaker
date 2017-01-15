# AGMatchMaker
AGMatchMaker is a UIViewControllerAnimatedTransition that Matches Views by identifier and animates the view between UIViewControllers to the correct location. 


An easy to use UIViewControllAnimatedTransition to match your views to
the next view controller with only a string id that can be set in
storyboard or in code.  Example of each are included in the project.

Todo list is to fix any existing bugs and use a different snapshot
method with a container that will allow layer animations beyond border
color and corner radius.

Works with Show and Present Modally

Example project is included:
Set the transitionID(Interface Builder or Code) on the two linked view controllers and add and set the AGMatchMaker in the controller and let it go.

ex of ID in code
view.transitionID = "avatarView"



![Alt Text](http://oakmonttech.com/wp-content/uploads/2017/01/AGMatchMaker.gif)
