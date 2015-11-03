function download {
  param($from, $to)
  (curl $from).Content > $to
}

function c { cmd /c @args }
