#tag Class
Protected Class SearchResult
	#tag Method, Flags = &h0, Description = 437265617465732061206E657720696E7374616E6365206F6620612073656172636820726573756C742066726F6D20616E204150492073656172636820726573756C742064696374696F6E617279207468617420776173206372656174656420696E207468652057696B6970656469615365617263682E5365617263682829206D6574686F642E
		Shared Function FromDictionary(pageDictionary As Dictionary, index As Integer = -1) As WikipediaKit.SearchResult
		  /// Creates a new instance of a search result from an API search result dictionary
		  /// that was created in the WikipediaSearch.Search() method.
		  
		  Var result As New WikipediaKit.SearchResult
		  
		  result.Description = pageDictionary.Lookup("description", "")
		  result.Excerpt = pageDictionary.Lookup("excerpt", "")
		  result.ID = pageDictionary.Lookup("id", 0)
		  result.Key = pageDictionary.Lookup("key", "")
		  result.Title = pageDictionary.Lookup("title", "")
		  
		  result.Index = index
		  
		  // Remove the search match spans from the excerpt.
		  If result.Excerpt.Contains("<span class=""searchmatch"">") Then
		    result.Excerpt = result.Excerpt.ReplaceAll("<span class=""searchmatch"">", "")
		    result.Excerpt = result.Excerpt.ReplaceAll("</span>", "")
		  End If
		  
		  // Sometimes the description and excerpts contain HTML entities so we'll remove them.
		  If result.Description.Contains("&") Then
		    result.Description = ReplaceHTMLEntities(result.Description)
		  End If
		  If result.Excerpt.Contains("&") Then
		    result.Excerpt = ReplaceHTMLEntities(result.Excerpt)
		  End If
		  
		  Return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, Description = 46696E647320616E64207265706C6163657320616C6C2048544D4C20656E74697469657320696E206068746D6C602E
		Private Shared Function ReplaceHTMLEntities(html As String) As String
		  /// Finds and replaces all HTML entities in `html`.
		  
		  // Create RegEx to find entities like &name;
		  Var rx As New RegEx
		  rx.SearchPattern = "&([^;]+);"  // Captures the part between & and ;
		  
		  // Find all matches.
		  Var match As RegExMatch = rx.Search(html)
		  Var replacements As New Dictionary  // Store replacements to apply later.
		  
		  While match <> Nil And match.SubExpressionCount >= 2
		    // Get the full match (&entity;) and the entity name (without & and ;)
		    Var fullEntity As String = match.SubExpressionString(0)  // e.g., "&Acirc;"
		    Var entityName As String = match.SubExpressionString(1)  // e.g., "Acirc"
		    
		    // Check if this entity exists in our dictionary.
		    If WikipediaKit.HTMLEntities.HasKey(entityName) Then
		      // Store the replacement.
		      Var replacement As String = Chr(WikipediaKit.HTMLEntities.Value(entityName))
		      replacements.Value(fullEntity) = replacement
		    End If
		    
		    // Get next match.
		    match = rx.Search(html, match.SubExpressionStartB(0) + match.SubExpressionString(0).Length)
		  Wend
		  
		  // Apply all replacements
		  For Each key As String In replacements.Keys
		    html = html.ReplaceAll(key, replacements.Value(key).StringValue)
		  Next
		  
		  Return html
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320612073696D706C6520737472696E6720726570726573656E746174696F6E206F6620746869732073656172636820726573756C742E
		Function ToString() As String
		  /// Returns a simple string representation of this search result.
		  
		  Var s() As String
		  
		  // Omit the title if not present.
		  If Title <> "" Then s.Add("Title: " + Title)
		  
		  // Omit the key if not present.
		  If Key <> "" Then s.Add("Key: " + Key)
		  
		  s.Add("Description: " + If(Description = "", "No description provided.", Description))
		  s.Add("Excerpt: " + If(Excerpt = "No excerpt provided.", "", Excerpt))
		  s.Add("ID: " + ID.ToString)
		  s.Add("Index: " + Index.ToString)
		  
		  Return String.FromArray(s, EndOfLine)
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0, Description = 4F7074696F6E616C206F662074686520706167652E2048544D4C20656E7469746965732068617665206265656E20636F6E76657274656420746F20746865697220556E69636F6465206571756976616C656E742E
		Description As String
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 412073686F727420657863657270742066726F6D2074686520706167652E2048544D4C20656E7469746965732068617665206265656E20636F6E76657274656420746F20746865697220556E69636F6465206571756976616C656E742E
		Excerpt As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 54686520696E646578206F66207468697320726573756C7420696E207468652061727261792072657475726E65642062792074686520736561726368204150492E
		Index As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4120756E697175652055524C2D73616665206B657920746861742063616E206265207573656420746F206665746368207468652070616765277320636F6E74656E742076696120746865204150492E
		Key As String
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 5468652070616765207469746C652E
		Title As String
	#tag EndProperty


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
			Name="ID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
