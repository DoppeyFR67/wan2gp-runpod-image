# Wan2GP RunPod image

This repo builds a RunPod-ready Wan2GP image in GitHub Actions.

Default image tags:

- `ghcr.io/lukasdoppler/wan2gp-runpod:cu130`
- `ghcr.io/lukasdoppler/wan2gp-runpod:latest`

If the repo has `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets, the same workflow also pushes:

- `doppey/wan2gp:cu130`
- `doppey/wan2gp:latest`

RunPod template basics:

- Container image: `ghcr.io/lukasdoppler/wan2gp-runpod:cu130`
- HTTP port: `7860`
- Volume mount path: `/workspace`
