param([string]$Code, [string]$BusyFile)

# Code 是一串 '0'/'1'，映射成零宽字符做本实例唯一标记；
# BusyFile 存在时标题前面加转圈帧，否则只维持标记。

$marker = -join ($Code.ToCharArray() | ForEach-Object { if ($_ -eq '0') { [char]0x200B } else { [char]0x200C } })
$frames = '|', '/', '-', '\'
$i = 0

while ($true) {
    $t = [Console]::Title
    $base = $t.Replace($marker, '')
    if ($base.Length -ge 2 -and ($frames -contains $base.Substring(0, 1)) -and $base.Substring(1, 1) -eq ' ') {
        $base = $base.Substring(2)
    }
    if (Test-Path -LiteralPath $BusyFile) {
        $prefix = "$($frames[$i % 4]) "
        $i++
    } else {
        $prefix = ''
    }
    $new = $prefix + $base + $marker
    if ($new -ne $t) { [Console]::Title = $new }
    Start-Sleep -Milliseconds 150
}
