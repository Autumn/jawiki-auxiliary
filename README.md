# jawiki auxiliary programs and resources

* **mw_text_extract.rb** - A MediaWiki markup parser, outputting a JSON representation of the article. Very incomplete. Very hacky. Some bugs in the link parser. Does not handle formatting strings ideally.

* **2** - sample article for initial testing purposes.

## Motivations and Consequences
* The end goal of this code is to extract the significant article text from each article, for chunking and graph analysis
    * A lot of data such as image metadata (positioning, type, size), external links, etc is unnecesary for initial applications so maintaining it is low priority.
* The code should be able to parse any Wikipedia page. It will mostly be used for articles, but it should be able to return a successful parse from notes, categories, and various other namespaces. Planning to use the parser with Wikipedia, Wikiquotes, Wiktionary, Wikibooks.

Markup spec - [http://www.mediawiki.org/wiki/Markup_spec](http://www.mediawiki.org/wiki/Markup_spec)

Wikipedia database dumps - [http://dumps.wikimedia.org/backup-index.html](http://dumps.wikimedia.org/backup-index.html)

Japanese Wikipedia database dumps - [http://dumps.wikimedia.org/jawiki/20130328/](http://dumps.wikimedia.org/jawiki/20130328/)
