type key   = string
type value = string

type op =
  | Get    of key
  | Set    of key * value
  | Append of key * value
  | Strlen of key
