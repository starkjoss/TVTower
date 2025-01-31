SuperStrict
Import "base.gfx.gui.textarea.bmx"




Type TGuiTextAreaSelect Extends TGUITextArea
	Field selectedLine:int
	Field hoveredLine:int

    Method Create:TGUITextAreaSelect(position:TVec2D = null, dimension:TVec2D = null, limitState:String = "")
		Super.Create(position, dimension, limitState)

		SetFont( GetBitmapFont("default", 12) )
		SetFixedLineHeight( GetFont().getMaxCharHeight()+2 )

		_horizontalScrollerAllowed = False

		return self
	End Method


	Method onMouseOver:int(triggerEvent:TEventBase)
		local coordX:Int = triggerEvent.GetData().GetInt("x")
		local coordY:Int = triggerEvent.GetData().GetInt("y")

		'make local
		coordX = coordX - GetContentScreenRect().GetX()
		coordY = coordY - GetContentScreenRect().GetY()
		hoveredLine = 1 + int((coordX + Abs(guiTextPanel.scrollPosition.GetY())) / GetLineHeight())
		hoveredLine = MathHelper.Clamp(hoveredLine, 0, GetLineCount() -1)
	End Method


	Method onClick:int(triggerEvent:TEventBase) override
		local coord:TVec2D = TVec2D(triggerEvent.GetData().Get("coord"))
		if not coord then return False

		local localCoord:TVec2D = new TVec2D.Init( coord.x - GetContentScreenRect().GetX(), coord.y - GetContentScreenRect().GetY())
		selectedLine = 1 + int((localCoord.y + Abs(guiTextPanel.scrollPosition.GetY())) / GetLineHeight())
		selectedLine = MathHelper.Clamp(selectedLine, 0, GetLineCount() -1)

		return True
	End Method


	Method SetValue(value:string) override
		Super.SetValue(value)
		hoveredLine = -1
		selectedLine = -1
	End Method
	
	
	Method GetLineCount:Int()
		If not _textParseInfo or not _textParseInfo.data.calculated
			GenerateTextCache()
		EndIf

		Return _textParseInfo.data.totalLineCount
	End Method
	

	Method Update:Int()
		'gets refreshed automatically
		hoveredLine = -1

		Super.Update()
	End Method


	Method DrawContent()
		Super.DrawContent()

		if selectedLine > 0 or hoveredLine > 0
			RestrictContentViewport()
			Local oldCol:SColor8; GetColor(oldCol)
			Local oldColA:Float = GetAlpha()

			if selectedLine > 0
				SetBlend(LightBlend)
				SetAlpha(oldColA * 0.25)
				SetColor(200,200,200)
				local lineY:int = GetLineHeight() * (selectedLine-1) + guiTextPanel.scrollPosition.GetY()
				DrawRect(GetContentScreenRect().GetX(), GetContentScreenRect().GetY() + lineY -1, GetContentScreenRect().GetW(), GetLineHeight())
				SetBlend(AlphaBlend)
			endif

			if hoveredLine > 0 and hoveredLine <> selectedLine
				SetBlend(LightBlend)
				SetAlpha(oldColA * 0.10)
				SetColor(200,200,230)
				local lineY:int = GetLineHeight() * (hoveredLine-1) + guiTextPanel.scrollPosition.GetY()
				DrawRect(GetContentScreenRect().GetX(), GetContentScreenRect().GetY() + lineY -1, GetContentScreenRect().GetW(), GetLineHeight())
				SetBlend(AlphaBlend)
			endif
			
			SetColor(oldCol)
			SetAlpha(oldColA)
			ResetViewport()
		endif
	End Method
End Type