function download {
  param($from, $to)
  (curl $from).Content > $to
}

function c { cmd /c @args }

function exit { exit }
set-alias  exit
