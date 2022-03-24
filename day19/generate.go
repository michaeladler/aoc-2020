//go:generate ragel -Z -G2 -o machine.go machine.rl
//go:generate ragel -V -o machine.dot machine.rl
//go:generate dot -Tpng -o machine.png machine.dot
package main
