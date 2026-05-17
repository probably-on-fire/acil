Add-Type -AssemblyName System.Drawing

$src = 'E:\anza_civic\site\IMAGES\ACIL-Logo.jpg'
$dst = 'E:\anza_civic\site\images\ACIL-Logo.png'

$srcImg = [System.Drawing.Image]::FromFile($src)
$w = $srcImg.Width
$h = $srcImg.Height

# Create a 32bpp ARGB bitmap for transparency support
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($srcImg, 0, 0, $w, $h)
$g.Dispose()
$srcImg.Dispose()

# Lock bits for fast direct memory access
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$ptr = $data.Scan0
$stride = $data.Stride
$bytes = New-Object 'byte[]' ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($ptr, $bytes, 0, $bytes.Length)

# Format32bppArgb in little-endian memory: B, G, R, A
# Flood-fill from all four corners — only contiguous white-ish regions starting at edges
# become transparent. Interior whites (clouds inside the cameo) are preserved.
$threshold = 235  # treat as "white-ish" if all of R,G,B are >= this

function IsWhitish([int]$idx) {
  return ($bytes[$idx] -ge $threshold) -and ($bytes[$idx+1] -ge $threshold) -and ($bytes[$idx+2] -ge $threshold)
}

$visited = New-Object 'bool[]' ($w * $h)
$stack = New-Object System.Collections.Generic.Stack[int[]]

$stack.Push([int[]]@(0, 0))
$stack.Push([int[]]@(($w-1), 0))
$stack.Push([int[]]@(0, ($h-1)))
$stack.Push([int[]]@(($w-1), ($h-1)))

$filled = 0
while ($stack.Count -gt 0) {
  $p = $stack.Pop()
  $x = $p[0]; $y = $p[1]
  if ($x -lt 0 -or $x -ge $w -or $y -lt 0 -or $y -ge $h) { continue }
  $vIdx = $y * $w + $x
  if ($visited[$vIdx]) { continue }
  $visited[$vIdx] = $true
  $bIdx = $y * $stride + $x * 4
  if (-not (IsWhitish $bIdx)) { continue }
  # Set alpha to 0
  $bytes[$bIdx + 3] = 0
  $filled++
  $stack.Push([int[]]@(($x+1), $y))
  $stack.Push([int[]]@(($x-1), $y))
  $stack.Push([int[]]@($x, ($y+1)))
  $stack.Push([int[]]@($x, ($y-1)))
}

[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $ptr, $bytes.Length)
$bmp.UnlockBits($data)

# Ensure output dir exists
$outDir = Split-Path $dst -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Output "Wrote $dst"
Write-Output "Pixels made transparent: $filled / $($w * $h)"
