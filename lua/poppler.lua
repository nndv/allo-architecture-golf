
--- Poppler pdf
-- Requires luajit and ffi
-- @module Poppler

--- CDEF ---
local ffi = require 'ffi'
ffi.cdef[[
typedef struct {
  int       domain;
  int         code;
  char       *message;
} GError;
typedef void cairo_t;
typedef char gchar;
typedef void PopplerDocument;
typedef void PopplerPage;

// glib
bool g_path_is_absolute (const gchar *file_name);
gchar *g_build_filename (const gchar *first_element, ...);
gchar *g_filename_to_uri (const gchar *filename, const gchar *hostname, GError **error);
gchar *g_get_current_dir (void);

// poppler
const char *poppler_get_version(void);

// document
PopplerDocument *poppler_document_new_from_file(const char *uri, const char *password, GError **error);
PopplerDocument *poppler_document_new_from_data(const char *data, int length, const char *password, GError **error);
int poppler_document_get_n_pages(PopplerDocument *document);
PopplerPage *poppler_document_get_page(PopplerDocument *document, int index);
gchar *poppler_document_get_title(PopplerDocument *document);

// page
void poppler_page_get_size(PopplerPage *page, double *width, double *height);
void poppler_page_render(PopplerPage *page, cairo_t *cairo);

]]

--- objects ---
local poppler = ffi.load("poppler-glib")

--- Error ---

local Error = {}
function Error:new()
    local t = { err = ffi.new("GError *[1]") }
    setmetatable(t, self)
    self.__index = self
    return t
end

function Error:throw()
    if self.err[0] ~= nil then
        error(ffi.string(self.err[0].message))
    end
end

--- Document ---

Document = {}

--- Open a document
-- @tparam string file The file to open.
-- @raise Throws a string message on error
function Document:open(file)
    local err = Error:new()

    if poppler.g_path_is_absolute(file) == false then
        local current = ffi.string(poppler.g_get_current_dir())
        file = ffi.string(poppler.g_build_filename(current, file))
        file = ffi.string(poppler.g_filename_to_uri(file, nil, err.err))
        err:throw()
    end

    --print(file)

    local doc = poppler.poppler_document_new_from_file(file, nil, err.err)
    err:throw()

    local t = {
        doc = doc
    }
    setmetatable(t, self)
    self.__index = self
    return t
end

--- Load a document from data
function Document:load(data)
    local err = Error:new()

    local doc = poppler.poppler_document_new_from_data(data, #data, nil, err.err)
    err:throw()

    local t = {
        doc = doc
    }
    setmetatable(t, self)
    self.__index = self
    return t
end

--- Get the document title
-- @treturn string The title
function Document:title()
    local title = poppler.poppler_document_get_title(self.doc)
    return ffi.string(title)
end

--- Get the number of pages in the document
-- @treturns int The number of pages
function Document:pageCount()
    local pagecount = poppler.poppler_document_get_n_pages(self.doc)
    return pagecount
end

--- Get a page of the document.
-- @int index The page index. Starts at 1. Must not be larger than `Document:pageCount`.
-- @see Document:pageCount
function Document:getPage(index)
    local page = poppler.poppler_document_get_page(self.doc, index - 1)
    return Page:new(page)
end

--- PAGE ---

--- Object wriapping a Poppler page
-- @classmod Page
Page = {}

--- Get a new Page object with from poppler page
-- @param page A PopplerPage
-- @see Document:getPage
function Page:new(page)
    local t = {
        page = page
    }
    setmetatable(t, self)
    self.__index = self
    return t
end

--- Get the size of the page
-- @treturn {width, height} Table with width and height
function Page:size()
    local width = ffi.new("double[1]")
    local height = ffi.new("double[1]")
    poppler.poppler_page_get_size(self.page, width, height)
    return { width = width[0], height = height[0]}
end

--- Render the page to a Cairo surface
-- @param surcace A cairo surface
function Page:renderToCairoSurface(surface)
    poppler.poppler_page_render(self.page, surface)
end
