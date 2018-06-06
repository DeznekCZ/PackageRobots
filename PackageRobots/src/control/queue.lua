Queue = {
  lower_first = 0,
  higher_first = 1
}
Queue.__index = Queue

setmetatable(Queue, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Queue.new(data, priority, priority_order)
  local self = setmetatable({}, Queue)
  self.first = nil
  self.priority_order = priority_order or Queue.lower_first
  if data then
    self:push(data, priority)
  end
  return self
end

function Queue.restore(data)
  local newQueue = Queue.new()
  newQueue.first = data.first
  if data.priority_order then 
  	newQueue.priority_order = data.priority_order
  end
  return newQueue
end

-- DO NOT USE FOR ADDING
function Queue:add_priorited(data, priority)
  if self.priority_order == Queue.lower_first then
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
  elseif self.priority_order == Queue.higher_first then
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
    self:add_priorited(data, priority)
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
end

function Queue:pop()
  local data
  if self.first then
    data = self.first.data
    self.first = self.first.next
  end
  return data
end

function Queue:is_empty()
  if self.first then
    return false
  else
    return true
  end
end

--[[ 
FE_FUNCTION 
  attrinutes: DATA - data of current pointer
  return: any value if may break

returns any value of break
]]
function Queue:for_each(fe_function)
  local ptr = self.first
  local broken
  while ptr and not broken do
    broken = fe_function(ptr.data)
    ptr = ptr.next
  end
  return broken
end