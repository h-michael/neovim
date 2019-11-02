function! lsp#add_server_config(config) abort
  call luaeval('vim.lsp.add_config(_A)', a:config)
endfunction

function! lsp#text_document_hover() abort
  lua vim.lsp.buf_request(nil, 'textDocument/hover', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_completion() abort
  lua vim.lsp.buf_request(nil, 'textDocument/completion', vim.lsp.protocol.CompletionParams())
  return ''
endfunction

function! lsp#omnifunc(findstart, base) abort
  return luaeval("vim.lsp.omnifunc(_A[1], _A[2])", [a:findstart, a:base])
endfunction

function! lsp#text_document_signature_help() abort
  lua vim.lsp.buf_request(nil, 'textDocument/signatureHelp', vim.lsp.protocol.SignatureHelpParams())
  return ''
endfunction

function! lsp#text_document_declaration() abort
  lua vim.lsp.buf_request(nil, 'textDocument/declaration', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_definition() abort
  lua vim.lsp.buf_request(nil, 'textDocument/definition', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_type_definition() abort
  lua vim.lsp.buf_request(nil, 'textDocument/typeDefinition', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction

function! lsp#text_document_implementation() abort
  lua vim.lsp.buf_request(nil, 'textDocument/implementation', vim.lsp.protocol.TextDocumentPositionParams())
  return ''
endfunction
