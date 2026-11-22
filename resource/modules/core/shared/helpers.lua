MAX_FIELD_PLANTS = 256

function IsValidId(value)
    return type(value) == 'string' and value ~= '' and #value <= 64
end
