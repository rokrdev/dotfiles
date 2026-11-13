---
name: slack-post
description: 'Use when the user wants to post a friendly message to Slack, starting with a merge request review request. The message opens with a greeting in a different language each time. Triggers: "post to slack", "share this MR for review", "ask for a review on slack", "/slack-post".'
---

# slack-post Skill

Posts a short, friendly Slack message: a greeting in a new language, then a body. The only body type so far is a merge request review request.

## How greeting selection works

- Get the greeting with `~/.agents/skills/slack-post/pick-greeting.sh pick`. It prints one greeting at random from `greetings.txt`, skipping any already used.
- `pick` records nothing. A draft the user rejects does not use up a greeting.
- After a successful post, run `pick-greeting.sh record "<Greeting>"`.
- When every greeting is used, `pick` empties the used list and starts over. It never returns the last used greeting right away.
- Never reuse a greeting until all are used. Never choose one by hand.
- `greetings.txt` is one `Greeting|Language` per line. The user can edit it.
- State is `~/.local/state/slack-post/used-greetings.txt`, outside the skill dir. `SLACK_POST_STATE_DIR` overrides the directory.

## MR review request template

The opening line is `<Greeting>, team!`. Use another audience if the user names one. Fill the rest from the MR title, description and the work done. Keep it short.

```
<Greeting>, team!

Could I get a few eyes on a merge request? <one or two sentences: what it does and why a reviewer should care, plain English>

<TICKET-KEY> · <N> commits · <N> unit tests passing · <one fact about dependencies or scope, if relevant>

<One "thing to watch" paragraph only if there is a real risk or behaviour change reviewers or other teams must know. Omit it otherwise.>

MR: <URL>

Thanks
```

The closing is just "Thanks".

## Posting flow

1. Get the channel from the user. If they did not give one, ask.
   - If they give a name, load the deferred Slack tools with ToolSearch, then look it up with `slack_search_channels`. Require an exact name match.
   - Read the channel topic and description. If they say this kind of message belongs elsewhere, tell the user and do not post.
2. Show the user the draft and the target channel. Post only after they confirm, unless they already said to post it as written.
3. Post with `slack_send_message` as a new top-level message. No `@channel`, `@here`, mentions or reactions unless the user asked.
4. After a successful post, run `pick-greeting.sh record "<Greeting>"` and give the user the message link. If the post fails, do not record.

## Rules

- Plain, friendly English, one engineer talking to another.
- No emoji, no em dashes, no hype words. Straight quotes.
- Do not paste secrets, tokens or internal credentials.
- Never post to a channel the user did not name.
- Do not invent facts about tests, commits or risks. Take them from the MR or ask.
