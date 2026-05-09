package main

import (
	"fmt"
	"unsafe"
)

type Vertex struct {
	Lat, Long float64
}

type stringString struct {
	str unsafe.Pointer
	len int
}

var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}
func main(){
	s := "Muller"
	fmt.Println("-----Example 1-----")
	fmt.Printf("%T %[1]n\n", s)

}


