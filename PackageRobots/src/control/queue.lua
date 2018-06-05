Queue = {}
Queue.__index = Queue

setmetatable(Queue, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-- DO NOT USE FOR ADDING
function Queue:lower_first(data, priority)
  if self.first then
    if priority < self.first.priority then
      self.first = { data = data, priority = priority, next = self.first }
    else
      local ptr = self.first
      while ptr.next 
      and ptr.next.priority 
      and priority > ptr.next.priority do --condition
        ptr = ptr.next 
      end
      ptr.next = { data = data, priority = priority, next = ptr.next }
    end
  else
    self.first = { data = data, priority = priority }
  end
end

-- DO NOT USE FOR ADDING
function Queue:higher_first(data, priority)
  if self.first then
    if priority > self.first.priority then
      self.first = { data = data, priority = priority, next = self.first }
    else
      local ptr = self.first
      while ptr.next 
      and ptr.next.priority 
      and priority < ptr.next.priority do --condition
        ptr = ptr.next 
      end
      ptr.next = { data = data, priority = priority, next = ptr.next }
    end
  else
    self.first = { data = data, priority = priority }
  end
end

function Queue.new(data, priority, priority_order)
  local self = setmetatable({}, Queue)
  self.first = nil
  self.priority_order = priority_order or Queue.lower_first
  if data then
    self:push(data, priority)
  end
  return self
end

-- DO NOT USE FOR ADDING
function Queue:add_after_priority(data)
  if self.first then
    if self.first.priority then
      local ptr = self.first
      while ptr.next 
      and ptr.next.priority do --condition
        ptr = ptr.next 
      end
      ptr.next = { data = data, next = ptr.next }
    else
      self.first = { data = data, next = self.first }
    end
  else
    self.first = { data = data }
  end
end

function Queue:push(data, priority)
  if priority then
    self:priority_order(data, priority)
  elseif self.first then
    if self.first.priority then
      self:add_after_priority(data, priority)
    else
      local ptr = self.first
      while ptr.next do 
        ptr = ptr.next
      end
      ptr.next = { data = data }
    end
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