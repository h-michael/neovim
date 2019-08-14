-- Protocol for the Microsoft Language Server Protocol (mslsp)

local protocol = {}

local Enum = require('nvim.meta').Enum

protocol.DiagnosticSeverity = Enum:new({
  Error = 1,
  Warning = 2,
  Information = 3,
  Hint = 4
})

protocol.MessageType = Enum:new({
  Error = 1,
  Warning = 2,
  Info = 3,
  Log = 4
})

protocol.FileChangeType = Enum:new({
    Created = 1,
    Changed = 2,
    Deleted = 3
})

protocol.CompletionItemKind = {
    'Text',
    'Method',
    'Function',
    'Constructor',
    'Field',
    'Variable',
    'Class',
    'Interface',
    'Module',
    'Property',
    'Unit',
    'Value',
    'Enum',
    'Keyword',
    'Snippet',
    'Color',
    'File',
    'Reference',
    'Folder',
    'EnumMember',
    'Constant',
    'Struct',
    'Event',
    'Operator',
    'TypeParameter',
}

protocol.CompletionTriggerKind = Enum:new({
  Invoked = 1,
  TriggerCharacter = 2,
})

protocol.DocumentHighlightKind = Enum:new({
    Text = 1,
    Read = 2,
    Write = 3
})

protocol.SymbolKind = Enum:new({
    File = 1,
    Module = 2,
    Namespace = 3,
    Package = 4,
    Class = 5,
    Method = 6,
    Property = 7,
    Field = 8,
    Constructor = 9,
    Enum = 10,
    Interface = 11,
    Function = 12,
    Variable = 13,
    Constant = 14,
    String = 15,
    Number = 16,
    Boolean = 17,
    Array = 18,
})

protocol.errorCodes = {
  [-32700] = 'Parse error',
  [-32600] = 'Invalid Request',
  [-32601] = 'Method not found',
  [-32602] = 'Invalid params',
  [-32603] = 'Internal error',
  [-32099] = 'Server Error Start',
  [-32000] = 'Server Error End',
  [-32002] = 'Server Not Initialized',
  [-32001] = 'Unknown Error Code',
  -- Defined by the protocol
  [-32800] = 'Request Cancelled',
}


protocol.TextDocumentSaveReason = Enum:new({
  Manual = 1,
  AfterDelay = 2,
  FocusOut = 3,
})

return protocol
