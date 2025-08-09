export const SoundOnIdlePlugin = async ({ $, client }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`afplay /System/Library/Sounds/Glass.aiff`
        await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
      }
    }
  }
}
