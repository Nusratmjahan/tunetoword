const { customAlphabet } = require('nanoid');

// Generate unique code for song letter links
// Using alphanumeric characters (no confusing ones like 0/O, 1/l)
const generateCode = customAlphabet('23456789ABCDEFGHJKLMNPQRSTUVWXYZ', 8);

module.exports = { generateCode };
