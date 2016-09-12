select * from item i
join metadatavalue v
on i.item_id = v.resource_id
where i.item_id in (:ids)
