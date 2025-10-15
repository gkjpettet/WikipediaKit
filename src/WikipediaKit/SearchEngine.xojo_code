#tag Class
Protected Class SearchEngine
	#tag Method, Flags = &h21, Description = 43616C63756C61746573206120637573746F6D2072656C6576616E63652073636F726520666F7220612073656172636820706167652E204869676865722073636F7265203D20626574746572206D617463682E
		Private Function CalculateRelevanceScore(query As String, result As WikipediaKit.SearchResult) As Double
		  /// Calculates a custom relevance score for a search page.
		  /// Higher score = better match.
		  
		  Var score As Double = 0.0
		  Var queryLower As String = query.Lowercase
		  Var queryTerms() As String = queryLower.Split(" ")
		  
		  Var titleLower As String = result.Title.Lowercase
		  Var excerptLower As String = result.Excerpt.Lowercase
		  
		  // Title matching (weighted heavily).
		  If queryLower = titleLower Then
		    score = score + 100  // Exact match.
		  ElseIf titleLower.Contains(queryLower) Then
		    score = score + 50   // Partial match.
		  Else
		    // Check if all terms are present in the title.
		    Var allTermsInTitle As Boolean = True
		    For Each term As String In queryTerms
		      If titleLower.Contains(term) Then
		        allTermsInTitle = False
		        Exit
		      End If
		    Next term
		    
		    If allTermsInTitle Then score = score + 30
		  End If
		  
		  // Excerpt matching.
		  For Each term As String In queryTerms
		    If excerptLower.Contains(term) Then
		      score = score + 5
		    End If
		  Next term
		  
		  // Penalise certain page types.
		  If titleLower.Contains("list of") Then score = score - 10
		  
		  If titleLower.Contains("index of") Then score = score - 10
		  
		  // Boost if it has a description.
		  If result.Description <> "" Then score = score + 10
		  
		  // Position bonus (the API already ranked them so the "best" is at index 0).
		  If result.Index = 0 Then  // First result.
		    score = score + 20
		  ElseIf result.Index > 0 And result.Index < 3 Then  // Top 3.
		    score = score + 10
		  End If
		  
		  Return score
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 44656C6567617465206D6574686F6420666F7220736F7274696E6720616E206172726179206F662063616E646964617465732E2043616E646964617465207374727563747572653A2073636F72652028446F75626C6529203A20726573756C74202844696374696F6E61727929
		Private Function CompareScores(pair1 As Pair, pair2 As Pair) As Integer
		  /// Delegate method for sorting an array of candidates.
		  /// Candidate structure: score (Double) : result (Dictionary)
		  
		  Var score1 As Double = pair1.Left
		  Var score2 As Double = pair2.Left
		  
		  If score1 > score2 Then
		    
		    Return -1  // Pair1 comes first.
		    
		  ElseIf score1 < score2 Then
		    
		    Return 1   // Pair2 comes first.
		    
		  Else
		    
		    Return 0   // Equal.
		    
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(userAgent As String = DEFAULT_USER_AGENT)
		  mUserAgent = If(userAgent = "", DEFAULT_USER_AGENT, userAgent)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 46696E6473207468652062657374206D61746368696E672057696B6970656469612061727469636C6520666F7220612071756572792E2052657475726E7320612057696B697065646961536561726368526573756C74206F72204E696C2E
		Function FindBestMatch(query As String, preferExactTitle As Boolean = True, skipDisambiguation As Boolean = True) As WikipediaKit.SearchResult
		  /// Finds the best matching Wikipedia article for a query.
		  /// Returns a WikipediaSearchResult or Nil.
		  
		  Var results() As WikipediaKit.SearchResult = Search(query)
		  
		  If results.Count = 0 Then Return Nil
		  
		  Var queryLower As String = query.Lowercase.Trim
		  
		  // First pass: Look for an exact title match.
		  If preferExactTitle Then
		    For Each result As WikipediaKit.SearchResult In results
		      If result.Title.Lowercase = queryLower Then
		        If skipDisambiguation And IsDisambiguation(result) Then Continue
		        System.DebugLog("Found exact title match: " + result.Title)
		        Return result
		      End If
		    Next result
		  End If
		  
		  // Second pass: Look for high-quality partial matches.
		  // Candidate structure: score (Double) : result (WikipediaSearchResult)
		  Var candidates() As Pair
		  
		  For Each result As WikipediaKit.SearchResult In results
		    If skipDisambiguation And IsDisambiguation(result) Then Continue
		    Var score As Double = CalculateRelevanceScore(query, result)
		    candidates.Add(score : result)
		  Next result
		  
		  If candidates.Count = 0 Then
		    // If all results were disambiguation pages, return the first one, otherwise we return nothing.
		    Return If(results.Count > 0, results(0), Nil)
		  End If
		  
		  // Sort by score (highest first i.e: index 0).
		  candidates.Sort(AddressOf CompareScores)
		  
		  Var bestResult As WikipediaKit.SearchResult = WikipediaKit.SearchResult(candidates(0).Right)
		  Var bestScore As Double = candidates(0).Left
		  
		  System.DebugLog("Best match: " + bestResult.Title + " (score: " + Format(bestScore, "0.00") + ")")
		  
		  Return bestResult
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652075736572206167656E7420737472696E6720666F722074686973207365617263682E20457373656E7469616C6C7920617070656E647320222F312E302220746F2074686520656E64206F66207468652075736572206167656E7420737472696E672070617373656420647572696E6720636F6E737472756374696F6E2E
		Private Function GenerateUserAgent() As String
		  /// Returns the user agent string for this search.
		  /// Essentially appends "/1.0" to the end of the user agent string passed during construction.
		  
		  Return UserAgent + "/1.0"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E207468652066756C6C207061676520484D544C20636F6E74656E74206F6620612057696B69706564696120706167652066726F6D20612070616765206B6579202877686963682069732072657475726E656420627920616E2041504920736561726368292E2052657475726E7320616E20656D70747920737472696E6720696620616E206572726F72206F63637572732E
		Function GetPageHTML(pageKey As String) As String
		  /// Return the full page HMTL content of a Wikipedia page from a page key (which is returned by an API search).
		  /// Returns an empty string if an error occurs.
		  
		  Var url As String = BASE_URL + "/page/" + EncodeURLComponent(pageKey) + "/html"
		  
		  // Create a URLConnection.
		  Var connection As New URLConnection
		  connection.RequestHeader("User-Agent") = GenerateUserAgent
		  
		  Try
		    // Send the request.
		    Var response As String = connection.SendSync("GET", url, Timeout)
		    Return response
		    
		  Catch e As RuntimeException
		    System.DebugLog("Error fetching page content: " + e.Message)
		    Return ""
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73205472756520696620746865207061737365642073656172636820726573756C74206973206120646973616D626967756174696F6E20706167652E
		Private Function IsDisambiguation(result As WikipediaKit.SearchResult) As Boolean
		  /// Returns True if the passed search result is a disambiguation page.
		  
		  If result = Nil Then Return False
		  
		  // Check various disambiguation indicators.
		  If result.Title.Contains("disambiguation") Then Return True
		  If result.Excerpt.Contains("may refer to:") Then Return True
		  If result.Description.Contains("disambiguation page") Then Return True
		  If result.Excerpt.Contains("several uses") Then Return True
		  
		  Return False
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 52657475726E73207468652070617373656420737472696E672C207472756E636174656420746F2074686520737065636966696564206E756D626572206F6620776F7264732E
		Private Function Limit(s As String, maxWords As Integer) As String
		  /// Returns the passed string, truncated to the specified number of words.
		  
		  If s = "" Then Return ""
		  
		  If Not s.Contains(" ") Then Return s
		  
		  If maxWords = 0 Then Return ""
		  
		  If maxWords < 0 Then Return s
		  
		  Var words() As String = s.Split(" ")
		  
		  If words.Count <= maxWords Then Return s
		  
		  Var result() As String
		  
		  words.ResizeTo(maxWords - 1)
		  
		  Return String.FromArray(words, " ")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53656172636865732057696B697065646961207573696E6720697427732041504920666F7220746865207061737365642071756572792E2052657475726E7320616E206172726179206F662057696B697065646961536561726368526573756C74732E2054616B657320616E206F7074696F6E616C206C696D697420746F20746865206E756D626572206F6620726573756C747320746F2072657475726E2E
		Function Search(query As String, limit As Integer = 10) As WikipediaKit.SearchResult()
		  /// Searches Wikipedia using it's API for the passed query. Returns an array of WikipediaSearchResults.
		  /// Takes an optional limit to the number of results to return.
		  ///
		  /// Searches Wikipedia page titles and contents.
		  ///     `GET /search/page`
		  /// Parameters:
		  ///   q (required):     The search query
		  ///   limit (optional): The number of results (1-100, default: 50)
		  ///
		  /// Example API response:
		  /// {
		  ///   "pages": [
		  ///     {
		  ///       "id": 15580374,
		  ///       "key": "Jupiter",
		  ///       "title": "Jupiter",
		  ///       "excerpt": "Jupiter is the fifth planet from the Sun...",
		  ///       "thumbnail": {...},
		  ///       "description": "Fifth planet from the Sun"
		  ///     }
		  ///   ]
		  /// }
		  
		  Var results() As WikipediaKit.SearchResult
		  
		  // Ensure we don't go over the request limit.
		  If limit <= 0 Then limit = 1
		  limit = Min(limit, MAX_LIMIT)
		  
		  // Build the URL with the required parameters.
		  Var url As String = BASE_URL + "/search/page"
		  url = url + "?q=" + EncodeURLComponent(query)
		  url = url + "&limit=" + limit.ToString
		  
		  // Create a URLConnection.
		  Var connection As New URLConnection
		  connection.RequestHeader("User-Agent") = GenerateUserAgent
		  
		  Try
		    // Send the request synchronously.
		    Var response As String = connection.SendSync("GET", url, TIMEOUT)
		    
		    If connection.HTTPStatusCode <> 200 Then
		      System.DebugLog("Expected a 200 status code from the Wikipedia API (instead got " + connection.HTTPStatusCode.ToString + ").")
		      Return results
		    End If
		    
		    // Parse the JSON response.
		    Var json As Dictionary = ParseJSON(response)
		    
		    If json.HasKey("pages") Then
		      Var pages() As Variant = json.Value("pages")
		      
		      For i As Integer = 0 To pages.Count - 1
		        If pages(i) IsA Dictionary Then
		          Var pageDict As Dictionary = Dictionary(pages(i))
		          Var pageResult As WikipediaKit.SearchResult = _
		          WikipediaKit.SearchResult.FromDictionary(pageDict, i) // Pass in the index for position scoring
		          results.Add(pageResult)
		        End If
		      Next i
		    End If
		    
		  Catch e As JSONException
		    System.DebugLog("Invalid JSON returned from the Wikipedia API: " + e.Message)
		    
		  Catch e As RuntimeException
		    System.DebugLog("Search error: " + e.Message)
		  End Try
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53656172636820666F722061207061676520616E642072657475726E73206974732066756C6C2048544D4C20636F6E74656E74206F72202222206966207468657265206973206E6F20676F6F64206D617463682E
		Function SearchAndGetPageHTMLContent(query As String) As String
		  /// Search for a page and returns its full HTML content or "" if there is no good match.
		  
		  // Find the best match.
		  Var bestMatch As WikipediaKit.SearchResult = FindBestMatch(query)
		  
		  If bestMatch = Nil Then Return ""
		  
		  // Extract the page key.
		  Var pageKey As String = bestMatch.Key
		  
		  If pageKey = "" Then
		    // Fallback to the title if the key is not available.
		    pageKey = bestMatch.Title
		  End If
		  
		  Return GetPageHTML(pageKey)
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mTimeout As Integer = 10
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUserAgent As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 546865206E756D6E626572206F66207365636F6E647320746F207761697420666F7220616E2041504920726573756C74206265666F72652074696D696E67206F75742E20436C616D70656420746F203E3D2031207365636F6E642E
		#tag Getter
			Get
			  Return mTimeout
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTimeout = Max(1, value)
			  
			End Set
		#tag EndSetter
		Timeout As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 54686520756E697175652075736572206167656E7420666F7220746869732073656172636820636C6173732E
		#tag Getter
			Get
			  Return mUserAgent
			  
			End Get
		#tag EndGetter
		UserAgent As String
	#tag EndComputedProperty


	#tag Constant, Name = BASE_URL, Type = String, Dynamic = False, Default = \"https://en.wikipedia.org/w/rest.php/v1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = DEFAULT_USER_AGENT, Type = String, Dynamic = False, Default = \"XojoWikipediaKit", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MAX_LIMIT, Type = Double, Dynamic = False, Default = \"100", Scope = Public, Description = 546865206D6178696D756D206C696D697420617320646566696E656420627920746865204150492E
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Timeout"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="UserAgent"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
