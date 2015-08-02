# v002-Image-Loader
Image Loader that fully supports 32 bit images

While Quartz Composer claims to have 32 bit image loading support, internally texture submission tends to fall back to 8 bits per pixel even for images which report a 32 bit float format. 

Perfection is many little things done right.

Note the texture backing.

![Before](https://raw.githubusercontent.com/v002/v002-Image-Loader/master/Readme%20Before.png)

v002 Image Loader fully supports float for both CPU and GPU submission.

![After](https://raw.githubusercontent.com/v002/v002-Image-Loader/master/Readme%20After.png)
