rsync -ave ssh --include="*/" --include="*.stat" --include="*.traj.00.txt" --exclude="*" tarkil:~/proteins/test-fs-multiple/output .
