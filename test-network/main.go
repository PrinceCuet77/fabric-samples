// You can edit this code!
// Click here and start typing.
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

func main() {
	data, err := ioutil.ReadFile("getHeight.txt")
	if err != nil {
		fmt.Println("File reading error", err)
		return
	}
	val := string(data)
	fmt.Println(val[161:162])

	f, err := os.Create("data.txt")

	if err != nil {
		log.Fatal(err)
	}

	defer f.Close()

	_, err2 := f.WriteString(val[161:162])

	if err2 != nil {
		log.Fatal(err2)
	}

	fmt.Println("done")
}
