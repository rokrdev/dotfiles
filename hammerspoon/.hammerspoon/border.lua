local w = {}

w.border = nil

function w.drawBorder()
  win = hs.window.focusedWindow()
  if win ~= nil then
    top_left = win:topLeft()
    size = win:size()
    if w.border ~= nil then
      w.border:delete()
      w.border = nil
    end

    w.border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
    w.border:setStrokeColor({["hex"]="#42f5c2",["alpha"]=0.6})
    w.border:setFill(false)
    w.border:setStrokeWidth(6)
    w.border:setRoundedRectRadii(4, 4)
    w.border:show()
  end
end

function w.deleteBorder()
  if w.border ~= nil then
    w.border:delete()
    w.border = nil
  end
end

function w.manageBorder()
  w.drawBorder()
  hs.timer.doAfter(0.3, w.deleteBorder)
end


allwindows = hs.window.filter.new(nil)
allwindows:subscribe(hs.window.filter.windowCreated, function () w.manageBorder() end)
allwindows:subscribe(hs.window.filter.windowFocused, function () w.manageBorder() end)
allwindows:subscribe(hs.window.filter.windowMoved, function () w.manageBorder() end)
allwindows:subscribe(hs.window.filter.windowUnfocused, function () w.manageBorder() end)


