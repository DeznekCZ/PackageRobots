Queue = {}
Queue.__index = Queue

setmetatable(Queue, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Queue.new(data)
  local self = setmetatable({}, Queue)
  self.first = nil
  if data then
    self:push(data)
  end
  return self
end

function Queue:push(data)
  if self.first then
    local ptr = self.first
    while self.first.next do ptr = ptr.next end
    ptr.next = { data = data }
  else
    self.first = { data = data }
  end
  game.write_file("queue.log", "PUSH: " .. serpent.block(self) .. "\n", true)
end

function Queue:pop()
  local data
  if self.first then
    data = self.first.data
    self.first = self.first.next
  end
  game.write_file("queue.log", "POP: " .. serpent.block(self) .. "\n", true)
  return data
end

function Queue:is_empty()
  if self.first then
    return false
  else
    return true
  end
end