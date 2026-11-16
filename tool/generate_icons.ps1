Add-Type -AssemblyName System.Drawing
$emblem = [System.Drawing.Image]::FromFile('assets/images/nuri_logo_mark.png')
$sizes = @{
    'mipmap-mdpi' = 48
    'mipmap-hdpi' = 72
    'mipmap-xhdpi' = 96
    'mipmap-xxhdpi' = 144
    'mipmap-xxxhdpi' = 192
}

foreach ($k in $sizes.Keys) {
    $s = $sizes[$k]
    $bmp = New-Object System.Drawing.Bitmap($s, $s)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#0D631B'))
    $g.FillEllipse($bgBrush, 0, 0, $s, $s)
    $bgBrush.Dispose()

    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $m = [int]($s * 0.05)
    $g.FillEllipse($whiteBrush, $m, $m, ($s - 2 * $m), ($s - 2 * $m))
    $whiteBrush.Dispose()

    $pad = [int]($s * 0.15)
    $w = $s - 2 * $pad
    $h = $s - 2 * $pad
    $destRect = New-Object System.Drawing.Rectangle($pad, $pad, $w, $h)
    $g.DrawImage($emblem, $destRect)
    $g.Dispose()

    $outPath = "android/app/src/main/res/$k/ic_launcher.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Successfully generated: $outPath ($s x $s)"
}

$emblem.Dispose()
