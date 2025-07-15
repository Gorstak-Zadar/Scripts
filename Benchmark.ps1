# Load required types
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# CPU Benchmark
function Test-CPU {
    try {
        $start = Get-Date
        $maxIterations = 10000
        for ($i = 0; $i -lt $maxIterations; $i++) {
            $result = $i * 2 + 1 - $i
            Write-Progress -Activity "CPU Benchmark" -Status "Testing Integer Math..." -PercentComplete (($i / $maxIterations) * 100)
        }
        $intTime = (Get-Date) - $start

        $start = Get-Date
        for ($i = 0; $i -lt $maxIterations; $i++) {
            $result = [math]::sqrt($i) * [math]::PI
            Write-Progress -Activity "CPU Benchmark" -Status "Testing Floating Point Math..." -PercentComplete (($i / $maxIterations) * 100)
        }
        $floatTime = (Get-Date) - $start

        $totalTime = $intTime.TotalSeconds + $floatTime.TotalSeconds
        if ($totalTime -le 0) {
            $logPath = "$env:USERPROFILE\Documents\Benchmark_ErrorLog.txt"
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "$timestamp : CPU Benchmark Error: Total time is zero or negative ($totalTime seconds)" | Out-File -FilePath $logPath -Append -Force
            return "Error"
        }
        $cpuScore = 1 / $totalTime
        $cpuScore = [math]::Round($cpuScore * 5000, 2)
        # Log the CPU score for debugging
        $logPath = "$env:USERPROFILE\Documents\Benchmark_ErrorLog.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp : CPU Score Calculated: $cpuScore" | Out-File -FilePath $logPath -Append -Force
        return $cpuScore
    } catch {
        $logPath = "$env:USERPROFILE\Documents\Benchmark_ErrorLog.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$timestamp : CPU Benchmark Error: $_" | Out-File -FilePath $logPath -Append -Force
        return "Error"
    }
}

# Memory Benchmark
function Test-Memory {
    $maxIterations = 10000
    $array = @()
    
    # Memory Write Test
    $start = Get-Date
    for ($i = 0; $i -lt $maxIterations; $i++) {
        $array += Get-Random -Maximum 10000
        Write-Progress -Activity "Memory Benchmark" -Status "Writing to Memory..." -PercentComplete (($i / $maxIterations) * 100)
    }
    $writeTime = (Get-Date) - $start

    # Memory Read Test
    $start = Get-Date
    $sum = 0
    for ($i = 0; $i -lt $maxIterations; $i++) {
        $sum += $array[$i]
        Write-Progress -Activity "Memory Benchmark" -Status "Reading from Memory..." -PercentComplete (($i / $maxIterations) * 100)
    }
    $readTime = (Get-Date) - $start

    $memoryWriteScore = 1 / $writeTime.TotalSeconds
    $memoryReadScore = 1 / $readTime.TotalSeconds
    return [math]::Round($memoryWriteScore * 2500, 2), [math]::Round($memoryReadScore * 2500, 2)
}

# Disk Benchmark
function Test-Disk {
    $directory = "$env:USERPROFILE\Documents"  # Use user-accessible directory
    if (-not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory | Out-Null
    }
    $filePath = "$directory\benchmark_testfile.txt"
    $content = "0" * 1024 * 1024 # 1 MB data

    # Ensure file is created
    $start = Get-Date
    try {
        Set-Content -Path $filePath -Value $content -Force
    } catch {
        return "Disk Write Error"
    }
    Start-Sleep -Milliseconds 100  # Wait to ensure file is written
    $writeTime = (Get-Date) - $start

    # Check if file exists before reading
    if (Test-Path -Path $filePath) {
        $start = Get-Date
        $data = Get-Content -Path $filePath -Raw
        $readTime = (Get-Date) - $start
        Remove-Item -Path $filePath -Force
    } else {
        return "Disk Read Error"
    }

    $diskScore = 1 / ($writeTime.TotalSeconds + $readTime.TotalSeconds)
    return [math]::Round($diskScore * 10, 2)
}

# Graphics Benchmark
function Test-Graphics {
    $start = Get-Date
    $maxFrames = 1000
    for ($i = 0; $i -lt $maxFrames; $i++) {
        Start-Sleep -Milliseconds 1
        Write-Progress -Activity "Graphics Benchmark" -Status "Rendering Frames..." -PercentComplete (($i / $maxFrames) * 100)
    }
    $renderTime = (Get-Date) - $start

    $graphicsScore = 1 / $renderTime.TotalSeconds
    return [math]::Round($graphicsScore * 1000, 2)
}

# Screenshot function
function Take-Screenie {
    param ($form)
    $screenLocation = $form.PointToScreen([System.Drawing.Point]::Empty)
    $bounds = $form.Bounds
    $bmp = New-Object Drawing.Bitmap $bounds.Width, $bounds.Height
    $gfx = [Drawing.Graphics]::FromImage($bmp)
    $gfx.CopyFromScreen($screenLocation, [Drawing.Point]::Empty, $bounds.Size)

    $path = "$env:USERPROFILE\Pictures\BenchmarkResult_$((Get-Date).ToString('yyyyMMdd_HHmmss')).png"
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    [System.Windows.Forms.Clipboard]::SetImage($bmp)

    [System.Windows.Forms.MessageBox]::Show("Screenie saved to:`n$path`nand copied to clipboard.")
}

# GUI Window
function Show-ResultsWindow {
    param ($text)

    $form = New-Object Windows.Forms.Form
    $form.Text = "Benchmark Results"
    $form.Size = '640,480'
    $form.StartPosition = 'CenterScreen'
    $form.TopMost = $true

    $panel = New-Object Windows.Forms.Panel
    $panel.Dock = 'Top'
    $panel.Height = 45
    $form.Controls.Add($panel)

    $button = New-Object Windows.Forms.Button
    $button.Text = "📷 Screenie"
    $button.Size = '120,30'
    $button.Location = New-Object Drawing.Point 500, 7
    $button.Anchor = 'Top,Right'
    $button.Add_Click({ Take-Screenie $form })
    $panel.Controls.Add($button)

    $box = New-Object Windows.Forms.TextBox
    $box.Multiline = $true
    $box.ReadOnly = $true
    $box.Dock = 'Fill'
    $box.ScrollBars = 'Vertical'
    $box.Font = New-Object Drawing.Font "Consolas", 24
    $box.Text = $text
    $form.Controls.Add($box)

    $form.Add_Shown({
        $box.SelectionLength = 0
        $form.Activate()
    })

    $form.ShowDialog()
}

# Run All Tests
function Run-Benchmark {
    $cpu = Test-CPU
    $memWrite, $memRead = Test-Memory
    $disk = Test-Disk
    $gpu = Test-Graphics
    $total = [math]::Round(($cpu * 0.3 + $memWrite * 0.2 + $memRead * 0.2 + $disk * 0.2 + $gpu * 0.1), 2)

    $result = @"

CPU Score:           $cpu
Memory Write Score:  $memWrite
Memory Read Score:   $memRead
Disk Score:          $disk
Graphics Score:      $gpu
------------------------------
Total Score:         $total
"@

    if ($host.Name -notmatch "ISE") {
        Start-Job { Start-Sleep -Milliseconds 600; [System.Windows.Forms.Application]::Exit() } | Out-Null
    }

    Show-ResultsWindow $result
}

# Entry point
Run-Benchmark