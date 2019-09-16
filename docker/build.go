package docker

import (
	"fmt"
	"os/exec"
	"strings"
)

// BuildImage builds a docker image from given config.
func (b *DefaultDocker) BuildImage(name string, context string, tags []string, buildArgs map[string]string, target string, cacheFrom string, file string, output bool) error {
	args := []string{"build"}

	if len(target) > 0 {
		args = append(args, fmt.Sprintf("--target=%s", target))
	}

	for _, tag := range tags {
		args = append(args, fmt.Sprintf("--tag=%s", tag))
	}

	for arg, value := range buildArgs {
		args = append(args, fmt.Sprintf("--build-arg=\"%s=%s\"", arg, value))
	}

	if len(cacheFrom) > 0 {
		args = append(args, fmt.Sprintf("--cache-from=%s", cacheFrom))
	}

	if len(file) > 0 {
		args = append(args, fmt.Sprintf("--file=%s", file))
	}

	if len(context) == 0 {
		args = append(args, ".")
	} else {
		args = append(args, context)
	}

	if output {
		fmt.Println(fmt.Sprintf("===> [%s]    Docker Args: %s", name, args))
	}

	cmd := exec.Command("docker", args...)

	out, err := cmd.CombinedOutput()

	if output {
		lines := strings.Split(string(out), "\n")

		for _, line := range lines {
			fmt.Println(fmt.Sprintf("===> [%s]    ", name) + line)
		}
	}

	return err
}
