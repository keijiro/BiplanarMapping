BiplanarMapping
===============

![screenshot](https://i.imgur.com/y6k0LcA.jpg)
![screenshot](https://i.imgur.com/fRYNrH1.jpg)

This repository contains a Unity Shader Graph implementation of
[biplanar mapping] that is originally developed by Inigo Quilez.

[biplanar mapping]: https://iquilezles.org/www/articles/biplanar/biplanar.htm

System Requirements
-------------------

- Unity 2019.4
- HDRP or URP

Although the sample project in this repository uses HDRP, the biplanar shader
supports both HDRP and URP.

How To Install
--------------

This package uses the [scoped registry] feature to resolve package
dependencies. Please add the following sections to the manifest file
(Packages/manifest.json).

[scoped registry]: https://docs.unity3d.com/Manual/upm-scoped.html

To the `scopedRegistries` section:

```
{
  "name": "Keijiro",
  "url": "https://registry.npmjs.com",
  "scopes": [ "jp.keijiro" ]
}
```

To the `dependencies` section:

```
"jp.keijiro.biplanar-shader": "1.0.0"
```

After changes, the manifest file should look like below:

```
{
  "scopedRegistries": [
    {
      "name": "Keijiro",
      "url": "https://registry.npmjs.com",
      "scopes": [ "jp.keijiro" ]
    }
  ],
  "dependencies": {
    "jp.keijiro.biplanar-shader": "1.0.0",
    ...
```
