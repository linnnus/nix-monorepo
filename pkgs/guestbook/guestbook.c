#include <errno.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>

int main(void) {
	sqlite3 *db;
	if (sqlite3_open_v2("guestbook.db", &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, NULL) != SQLITE_OK) {
		fprintf(stderr, "Failed to connect to database: %s\n", sqlite3_errmsg(db));
		exit(EXIT_FAILURE);
	}

	// Create the table if necessary.
	{
		char *errmsg;
		const char *query = "CREATE TABLE IF NOT EXISTS messages ("
		                    	"content TEXT NOT NULL,"
		                    	"created INTEGER NOT NULL," // Time as unix time.
		                    	"id INTEGER PRIMARY KEY"
		                    ")";
		if (sqlite3_exec(db, query, NULL, NULL, &errmsg) != SQLITE_OK) {
			fprintf(stderr, "Failed to create table: %s\n", errmsg);
			sqlite3_close_v2(db);
			exit(EXIT_FAILURE);
		}
	}

	// Read user's message.
	static char message[512];
	{
		printf("Enter your message (max %zu): ", sizeof(message) - 1);
		fflush(stdout);

		if (fgets(message, sizeof(message), stdin) == NULL) {
			fprintf(stderr, "Failed to read message: %s\n", feof(stdin) ? "EOF was reached" : strerror(errno));
			sqlite3_close_v2(db);
			exit(EXIT_FAILURE);
		}

		char *p;
		if ((p = strrchr(message, '\n')) != NULL) {
			*p = '\0';
		}
	}

	// Insert a new note.
	{
		sqlite3_stmt *stmt;
		if (sqlite3_prepare_v2(db, "INSERT INTO messages VALUES (?, unixepoch('now'), NULL);", -1, &stmt, NULL) != SQLITE_OK) {
			fprintf(stderr, "Failed to prepare query statement: %s\n", sqlite3_errmsg(db));
			sqlite3_close_v2(db);
			exit(EXIT_FAILURE);
		}

		if (sqlite3_bind_text(stmt, 1, message, -1, NULL) != SQLITE_OK) {
			fprintf(stderr, "Failed to bind parameters to query statement: %s\n", sqlite3_errmsg(db));
			sqlite3_finalize(stmt);
			sqlite3_close_v2(db);
			exit(EXIT_FAILURE);
		}

		if (sqlite3_step(stmt) == SQLITE_DONE) {
			printf("Your message was added to the guest book!\n");
		} else {
			fprintf(stderr, "Failed to execute query statement: %s\n", sqlite3_errmsg(db));
			sqlite3_finalize(stmt);
			sqlite3_close_v2(db);
			exit(EXIT_FAILURE);
		}

		sqlite3_finalize(stmt);
	}

	sqlite3_close_v2(db);
	return EXIT_SUCCESS;
}
