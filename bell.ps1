param([string]$Code)

# Code 是一串 '0'/'1'，映射成零宽字符的本实例唯一标记。
# 窗口标题含标记 => opencode 标签页在前台 => 不响；否则响应。

$marker = -join ($Code.ToCharArray() | ForEach-Object { if ($_ -eq '0') { [char]0x200B } else { [char]0x200C } })

Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class Win {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] public static extern uint GetConsoleTitle(StringBuilder lpConsoleTitle, uint nSize);
}
"@

$h = [Win]::GetForegroundWindow()
$cb = New-Object System.Text.StringBuilder 256
[void][Win]::GetClassName($h, $cb, 256)
$cls = $cb.ToString()
$tb = New-Object System.Text.StringBuilder 512
[void][Win]::GetWindowText($h, $tb, 512)
$fg = $tb.ToString()
$isTerminal = $cls -eq 'ConsoleWindowClass' -or $cls -eq 'CASCADIA_HOSTING_WINDOW_CLASS'
$skip = $isTerminal -and $fg.Contains($marker)

if (-not $skip) {
    [System.Media.SystemSounds]::Asterisk.Play()
    Start-Sleep -Seconds 1
}
