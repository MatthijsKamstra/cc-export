# TODO

how the correct render works
```
ffmpeg -y -r 30 -i ${dir}/${data.name}-%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ${dir}/${data.name}_output_30fps.mp4
```


how to use it with 'rendercan' browser extension
```
ffmpeg -y -r 30 -i creative_code_mck-%09d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  cc052a_output_30fps.mp4
```