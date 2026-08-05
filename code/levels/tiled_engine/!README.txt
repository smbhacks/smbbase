This folder and its content is only useful for you if you use Tiled as your level editor.
To enable Tiled support, edit the settings.asm file in the 'code' folder of this project.

Please close Tiled and reopen !PROJECT.tiled-project whenever you want to edit a level.
When you first open the project, you will have a warning message on the top-right corner:
"The current project contains scripted extensions."
Make sure you click Enable Extensions!

The "generated" folder contains the files that are put into your ROM. The content of this folder is fully automatized,
so don't edit anything in here directly.

In Tiled, get to Edit->Preferences, and there set Interface->Fine grid divisions to 8, and Major grid to 16 tiles by 16 tiles.
Also set View->Snapping to Snap to Fine Grid.

Error manual:
- First of all, make sure you have Python installed.
- Make sure that you allow scripts to run when you open the Tiled project.
- If you get "No module named PIL", run "pip install pillow".