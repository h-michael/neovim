function! lsp#add_server_config(config) abort
  if !has_key(a:config, 'filetype')
    echoerr 'config must have filetype key'
    return
  endif

  if !has_key(a:config, 'cmd')
    echoerr 'config must have cmd key'
    return
  endif

  call luaeval('vim.lsp.server_config.add(_A[1])', [a:config])
endfunction

function! lsp#text_document_hover() abort
  " DELETEME @h-michael since we aren't passing an argument, dynamically generating text or using the result, :lua is cleaner here.
  lua vim.lsp.request_async('textDocument/hover', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_completion() abort
  " DELETEME @h-michael since we aren't passing an argument, dynamically generating text or using the result, :lua is cleaner here.
  lua vim.lsp.request_async('textDocument/completion', vim.lsp.protocol.CompletionParams())
  return ''
endfunction

function! lsp#omnifunc(findstart, base) abort
  " DELETEME @h-michael serializing a table is slower for little readability benefit
  return luaeval("vim.lsp.omnifunc(_A[1], _A[2])", [a:findstart, a:base])
endfunction

function! lsp#text_document_signature_help() abort
  lua vim.lsp.request_async('textDocument/signatureHelp', vim.lsp.protocol.SignatureHelpParams())
  return ''
endfunction

function! lsp#text_document_declaration() abort
  lua vim.lsp.request_async('textDocument/declaration', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_definition() abort
  lua vim.lsp.request_async('textDocument/definition', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_type_definition() abort
  lua vim.lsp.request_async('textDocument/typeDefinition', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_implementation() abort
  lua vim.lsp.request_async('textDocument/implementation', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction
