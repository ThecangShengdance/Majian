# Third-Party Notices

## QR Code generator library (Swift)

Majian vendors a Swift port of Project Nayuki's QR Code generator library:

- Upstream: https://github.com/fwcd/swift-qrcode-generator
- Original library: https://www.nayuki.io/page/qr-code-generator-library
- Copyright (c) Project Nayuki
- Copyright (c) 2020 fwcd
- License: MIT

The vendored files live in `Sources/Core/Vendor/`. Each file retains its
original copyright and permission notice. 码笺（Majian）仅将上游的 `QRCodeError`
重命名为 `QRGeneratorError`（避免与渲染层同名类型冲突），算法实现未改动。

```
MIT License

Copyright (c) Project Nayuki
Copyright (c) 2020 fwcd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
