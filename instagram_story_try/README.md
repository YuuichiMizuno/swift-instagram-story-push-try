#  Posting photos to instagram using URL scheme

sample


### setting info.plist

#### 1. Enable photo library access
(Not required if you do not use a photo library)

`Privacy - Photo Library Usage Description` : "写真を選択するためにアクセスします。"


#### 2. Register Instagram URL Scheme

`LSApplicationQueriesSchemes` : ["instagram-stories", "instagram"]
