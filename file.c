/*
 * file.c - I/O implementation
 *
 * Copyright 2010 Rui Ueyama <rui314@gmail.com>.  All rights reserved.
 * This code is available under the simplified BSD license.  See LICENSE for details.
 */

#include "8cc.h"

/*
 * A wrapper object for stdio's FILE.
 */

File *make_file(FILE *stream, char *filename) {
    File *r = malloc(sizeof(File));
    r->stream = stream;
    r->line = 1;
    r->column = 1;
    r->last_column = 0;
    r->filename = make_string();
    ostr(r->filename, filename);
    r->ungotten = EOF;
    r->eof_flag = false;
    return r;
}

File *open_file(char *path) {
    if (!strcmp(path, "-")) {
        return make_file(stdin, "-");
    }
    FILE *stream = fopen(path, "r");
    if (stream == NULL) {
        perror("fopen failed: ");
        exit(-1);
    }
    return make_file(stream, path);
}

void close_file(File *file) {
    fclose(file->stream);
}

void unreadc(int c, File *file) {
    if (c == EOF)
        return;
    if (c == '\n') {
        file->line--;
        file->column = file->last_column;
    } else {
        file->column--;
    }
    if (file->ungotten != EOF)
        ungetc(file->ungotten, file->stream);
    file->ungotten = c;
    file->eof_flag = false;
}

/*
 * Returns the next character without consuming it.
 */
int peekc(File *file) {
    int c = readc(file);
    unreadc(c, file);
    return c;
}

/*
 * Consume next character iff the same as a given charcter.
 */
bool next_char_is(File *file, int c) {
    int c1 = readc(file);
    if (c == c1)
        return true;
    unreadc(c1, file);
    return false;
}

static void next_line(File *file, int c) {
    file->line++;
    file->last_column = file->column;
    file->column = 1;
    if (c == '\r') {
        int c1 = getc(file->stream);
        if (c1 != EOF && c1 != '\n') {
            ungetc(c1, file->stream);
        }
    }
}

/*
 * Abstracts C source file.  This does two things:
 *
 *   - Converts "\r\n" or "\r" to "\n".
 **
 *   - Removes backslash and following end-of-line marker.  This needs
 *     to happen before preprocessing and before the lexical analysis
 *     of the C program.  (C:ARM p.13 2.1.2 Whitespace and Line
 *     Termination)
 */
int readc(File *file) {
    int c;
    if (file->ungotten == EOF) {
        c = getc(file->stream);
    } else {
        c = file->ungotten;
        file->ungotten = EOF;
    }
    if (file->eof_flag || c == EOF || c == '\0') {
        file->eof_flag = true;
        return EOF;
    }
    if (c == '\\') {
        int c1 = getc(file->stream);
        if (c1 == '\r' || c1 == '\n') {
            next_line(file, c1);
            return readc(file);
        }
        unreadc(c1, file);
        return c;
    }
    if (c == '\r' || c == '\n') {
        next_line(file, c);
        return '\n';
    }
    file->column++;
    return c;
}
