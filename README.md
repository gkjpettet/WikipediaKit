# WikipediaKit

A Xojo module that allows you to query the free, public, Wikipedia API to retrieve descriptions, excerpts and full HTML content of articles.

## Usage

The bulk of the work is done by the `WikipediaKit.Search` class. It performs synchronous queries to the Wikipedia API. This is a free API that doesn't require an API token. You should supply your own user agent string with each request (the API requires this).

The class can either run a search query and return the HTML contents of the page that is the best match to the query string (determined by the API) or it can return an array of search results ordered by closest match (lowest array index is the best match).

```xojo
Var engine As New WikipediaKit.Search("MySearcher")

// Let's search for "Jupiter".
Var query As String = "Jupiter"

// Get the full page HTML contents for the best match.
// If html is empty then the search failed.
Var html As String = engine.SearchAndGetPageHTMLContent(query)

// We could also request a bunch of matches from the API:
Var allMatches() As WikipediaKit.SearchResult
allMatches = engine.Search(query, 10) // Limit to 10 results.

// Or we can try to get just the best match (uses our own internal heuristics):
Var bestMatch As WikipediaKit.SearchResult
bestMatch = engine.FindBestMatch(query)

// Valid WikipediaKit.SearchResults will have a `Key` property set by the API.
// You can use this to retrieve a specific page from the API.
Var contents As String = engine.GetPageHTML(bestMatch.Key)
```

Be aware that the `Search` class make synchronous requests so this is a blocking activity.
