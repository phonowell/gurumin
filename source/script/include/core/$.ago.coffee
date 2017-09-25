$.ago = (arg) ->

  cd = new Date() # current date
  td = new Date arg # target date

  year = td.getFullYear()
  month = td.getMonth()
  day = td.getDate()
  hour = td.getHours()
  minute = td.getMinutes()

  # pad
  pad = (num) ->
    if num > 9 then return num
    "0#{num}"

  resYear = "#{year}年"
  resDay = "#{1 + month}月#{day}日"
  resMinute = "#{hour}时#{pad minute}分"
  resDayBefore = '前天'
  resYesterday = '昨天'
  resToday = '今天'
  resJustNow = '刚刚'

  # not the same year
  if year != cd.getFullYear()
    return "#{resYear}#{resDay} #{resMinute}"

  # not the same month
  if month != cd.getMonth()
    return "#{resDay} #{resMinute}"

  disDay = cd.getDate() - day

  # days ago
  if disDay > 2
    return "#{resDay} #{resMinute}"

  # day before
  if disDay == 2
    return "#{resDayBefore} #{resMinute}"

  # yesterday
  if disDay == 1
    return "#{resYesterday} #{resMinute}"

  # today

  disHour = cd.getHours() - hour

  # many hours ago
  if disHour > 12
    return "#{resToday} #{resMinute}"

  # hours ago
  if disHour > 0
    return "#{disHour}小时前"

  # this hour

  disMinute = cd.getMinutes() - minute

  # minutes ago
  if disMinute > 0
    return "#{disMinute}分钟前"

  # just now
  resJustNow
