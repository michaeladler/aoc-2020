package main

import "testing"

func TestPart1(t *testing.T) {
	actual := Part1()
	expected := 129
	if actual != expected {
		t.Errorf("Expected %d, got %d", expected, actual)
	}
}
