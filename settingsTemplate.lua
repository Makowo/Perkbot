
local settings={
	token = "YOUR_DISCORD_BOT_TOKEN",
	key = "", --SpreadAPI Password
	write_link = "", --Google App Script URL from SpreadAPI https://spreadapi.com/setup
	link = ("https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}?key={YOUR_API_KEY}") --https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
}

return settings