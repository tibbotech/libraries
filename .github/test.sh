docker run -v ${PWD}/:/TIDEProjects/ --rm tibbotech/tidewine /bin/sh -c \
"wine /home/tibbo/.wine/drive_c/Program\ Files/Tibbo/TIDE/Bin/tmake.exe \"C:\\users\\tibbo\\TIDEProjects\\.tests\\librariestest\\librariestest.tpr\" \
-p \"C:\\users\\tibbo\\TIDEProjects\\.tests\\librariestest\\Platforms\" -r"