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

Next, edit the conf/pc.conf file. Fill in your PaperCall API key and add your PaperCall
event number to the link prefix. (We use the link prefix to build a clickable link
from the submission IDs.)

Finally, create a list of reviewers in conf/reviewers.txt. One name per line, and
make sure that each name exactly matches the reviewer's name in their PaperCall profile. The scripts use UTF-8 encoding, in case you have names with non-ASCII characters.

Then build the container (just once).

```
./saturn.sh build
```

## The main use case
Get data to paste into a spreadsheet to assign reviewers. This command creates a tab-separated file named (datestamp).tsv. Open the file in a text editor, copy the new submissions, and paste into the spreadsheet.

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
