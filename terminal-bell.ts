import type { Plugin } from "@opencode-ai/plugin"
import { randomBytes } from "node:crypto"
import { rmSync, writeFileSync } from "node:fs"

// 唯一标记用于判断当前激活的 Windows Terminal 标签是否属于本实例。

const BELL = "C:\\Users\\1\\.config\\opencode\\plugins\\bell.ps1"
const TITLER = "C:\\Users\\1\\.config\\opencode\\plugins\\titler.ps1"

export const TerminalBellPlugin: Plugin = async ({ $ }) => {
  const code = Array.from(randomBytes(8), (byte) => byte.toString(2).padStart(8, "0")).join("")
  const busyFile = `${process.env.TEMP}\\opencode-titler-${code.slice(0, 16)}.busy`

  const titler = Bun.spawn([
    "powershell",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    TITLER,
    "-Code",
    code,
    "-BusyFile",
    busyFile,
  ], {
      stdin: "ignore",
      stdout: "ignore",
      stderr: "ignore",
    })

  const busyOn = () => writeFileSync(busyFile, "")
  const busyOff = () => rmSync(busyFile, { force: true })
  const alert = async () => {
    await $`powershell -NoProfile -ExecutionPolicy Bypass -File ${BELL} -Code ${code}`.quiet().nothrow()
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        const status = (event.properties as { status?: { type?: string } }).status
        if (!status) return
        if (status.type === "busy" || status.type === "retry") busyOn()
        if (status.type === "idle") busyOff()
        return
      }

      if (event.type === "session.idle") {
        busyOff()
        await alert()
        return
      }

      if (event.type === "session.error") {
        busyOff()
        await alert()
      }
    },
    dispose: async () => {
      busyOff()
      titler.kill()
    },
  }
}
