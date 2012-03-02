
# pull in external modules
_ ?= require './third_party/underscore-min.js'

# things assigned to root will be available outside this module
root = exports ? this.util = {}

root.sum = (list) -> _.reduce(list, ((a,b) -> a+b), 0)

root.padleft = (str,len,fillchar) ->
  throw "fillchar can only be length 1" unless fillchar.length == 1
  # I hate this.
  until str.length >= len
    str = fillchar + str
  return str

root.cmp = (a,b) ->
  return 0  if a == b
  return -1 if a < b
  return 1

# implments x<<n without the braindead javascript << operator
# (see http://stackoverflow.com/questions/337355/javascript-bitwise-shift-of-long-long-number)
root.lshift = (x,n) -> x*Math.pow(2,n)

root.bitwise_not = (x,nbits) ->
  s = root.padleft(x.toString(2),nbits,'0')
  # may the computer gods have mercy on our souls...
  not_s = s.replace(/1/g,'x').replace(/0/g,'1').replace(/x/g,'0')
  return parseInt(not_s,2)

root.read_uint = (bytes) -> 
  n = bytes.length-1
  # sum up the byte values shifted left to the right alignment.
  root.sum(root.lshift(bytes[i],8*(n-i)) for i in [0..n])

root.parse_flags = (flag_byte) ->
  {
    public:       flag_byte & 0x1
    private:      flag_byte & 0x2
    protected:    flag_byte & 0x4
    static:       flag_byte & 0x8
    final:        flag_byte & 0x10
    synchronized: flag_byte & 0x20
    super:        flag_byte & 0x20
    volatile:     flag_byte & 0x40
    transient:    flag_byte & 0x80
    native:       flag_byte & 0x100
    interface:    flag_byte & 0x200
    abstract:     flag_byte & 0x400
    strict:       flag_byte & 0x800
  }

class root.BytesArray
  constructor: (@raw_array) ->
    @index = 0

  has_bytes: -> @index < @raw_array.length

  get_uint: (bytes_count) ->
    rv = root.read_uint @raw_array.slice(@index, @index+bytes_count)
    @index += bytes_count
    return rv

  get_int: (bytes_count) ->
    uint = @get_uint(bytes_count)
    if uint > Math.pow 2, 8 * bytes_count - 1
      uint - Math.pow 2, 8 * bytes_count
    else
      uint

root.is_string = (obj) -> typeof obj == 'string' or obj instanceof String
