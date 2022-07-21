package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/cristianwebber/go-bank/util"
	_ "github.com/lib/pq"
)

var testQueries *Queries
var testDB *sql.DB

const (
	dbDriver = "postgres"
	dbSource = "postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable"
)

func TestMain(m *testing.M){
	var err error
	config, err := util.LoadConfig("../..")
	if err != nil {
		log.Fatal("cannot load configurations", err)
	}

	fmt.Print(config)

	// testDB, err := sql.Open(config.DBDriver, config.DBSource) // This is not working (panic: runtime error: invalid memory address or nil pointer dereference)

	testDB, err = sql.Open(dbDriver, dbSource)

	if err != nil {
		log.Fatal("cannot connect to database", err)
	}

	testQueries = New(testDB)

	os.Exit(m.Run())
}
