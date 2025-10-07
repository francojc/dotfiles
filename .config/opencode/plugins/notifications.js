export const SoundOnIdlePlugin = async ({ $, client }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Play a sound when the session is idle
        await $`afplay /System/Library/Sounds/Glass.aiff`
        await $`osascript -e 'display notification "Response completed!" with title "Opencode"'`
      }
    }
  }
}

