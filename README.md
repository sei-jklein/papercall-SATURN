# PaperCall Tools for SATURN 2019

## Prerequisites:

- Docker
- That's all.

## Preliminaries

Everything runs off the script saturn.sh

First, make the script executable.

```
chmod +x saturn.sh
```

Build the container (just once).

```
./saturn.sh build
```

## The main use case
Get data to paste into a spreadsheet to assign reviewers. This creates a tab-separated file named (datestamp).tsv. Open the file in a text editor, copy the new submissions, and paste into the spreadsheet.

```
./saturn.sh do get
```


## Other actions:

- do status - get review status
- do analysis - get some statistics on the review progress
- do addresses - get a list of email addresses of the submitters.
- do notifications - get submissions sorted by disposition
- do program - get the accepted submissions to put into the program.
- do abstracts - get elevator pitch for all accepted submissions
