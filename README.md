# FIXED

This is undocumented, but adding `"public": true` to `now.json` is what made it work for me.

Using `now` and answering `y` when it asks if the deployment should be public **is not enough**.

Keeping repro instructions below for historic purposes.

---

# Dockerfile Builds for Static Deployments
## With User-Defined Build-Time Environment Variables

This repository is a repro of a bug I'm experiencing as reported in [zeit/now-cloud#52](https://github.com/zeit/now-cloud/issues/52).

The **build-time** environment variable passed either via `now.json` or the now-cli option `--build-env` is absent during the Dockerfile build process.

The code is a minimal example, taken from the [zeit blog post announcement](https://zeit.co/blog/dockerfile-static)'s "hello world" and changed to print a user-defined environment variable.

This is the `Dockerfile`:

```dockerfile
FROM busybox
ARG DATE_ENV_VARIABLE
RUN mkdir /public && echo "<h1>The time is $DATE_ENV_VARIABLE</h1>" > /public/index.html
RUN cat /public/index.html
```

This is `now.json`:

```javascript
{
  "type": "static",
  "build": {
    "env": {
      "DATE_ENV_VARIABLE": "now"
    }
  }
}
```

### Running locally

On the command line, running the command

```bash
docker build --no-cache -t hello-now --build-arg DATE_ENV_VARIABLE=now .
```

works as expected and prints out

```
Step 4/4 : RUN cat /public/index.html
[...]
<h1>The time is now</h1>
```

in the log, so the problem seems to be isolated to how `now` runs it.

### Running with `now`

Calling `now` using the [latest version](https://github.com/zeit/now-cli/tree/12.0.0-canary.60)

```bash
npm install --global now@12.0.0-canary.60
now
```

prints this in the log:

```
> Step 4/4 : RUN cat /public/index.html
[...]
> <h1>The time is </h1>
```

## With Built-In Build-Time Environment Variables

If you change the `Dockerfile` to use, for example, `$NOW_URL`, which is not defined by the user, but present on every deployment:

```dockerfile
FROM busybox
ARG NOW_URL
RUN mkdir /public && echo "<h1>The url is $NOW_URL</h1>" > /public/index.html
RUN cat /public/index.html
```

it works as expected, printing a different URL every time. So the problem seems to be isolated to user-defined variables.

# Can you help?

I would really appreciate it if you could try to run this example yourself and report on how it behaves by opening an issue. Also, if you have any ideas on how I could debug this further or help the zeit team, please let me know.

I'm [@hsribei](https://twitter.com/hsribei) on Twitter.
