/*
URI correction query:
changes URIs from
	http://hdl.handle.net/1774.2/...
TO
	http://jhir.library.jhu.edu/handle/1774.2/...
*/
UPDATE metadatavalue
SET text_value = replace(text_value, :old_handle, :new_handle)
WHERE metadata_field_id = 25 	-- URI
AND resource_type_id = 2	-- item
AND text_value LIKE :pattern
-- AND resource_id = 37524		-- item id


/*
URI query
pre-update: 32026 ROWS
*/
/*
SELECT *
FROM metadatavalue
WHERE resource_type_id = 2	-- URI
AND metadata_field_id = 25	-- item
AND text_value LIKE 'http://hdl.handle.net/1774%'
-- AND resource_id = 2		-- item id
*/

/*
outliers query 1:
post-update: 6 ROWS
mostly erroneous or empty URIs.
one valid URI to a journal that presumably originally published the item
*/
/*
SELECT *
FROM metadatavalue
WHERE resource_id IN
(
	SELECT resource_id
	FROM metadatavalue
	WHERE resource_type_id = 2	-- URI
	AND metadata_field_id = 25	-- item
	AND text_value NOT LIKE 'http://jhir.library.jhu.edu/handle/1774%'
)
*/

/*
outliers query 2:
all metadata on items with handles pointing elsewhere
(all resource_id=18 citations)
*/
/*
SELECT *
FROM metadatavalue
WHERE resource_id IN
(
	SELECT resource_id
	FROM metadatavalue
	WHERE text_value LIKE 'http://hdl%'
	AND text_value NOT LIKE 'http://hdl.handle.net/1774%'
)
*/
