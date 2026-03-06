local Base = require('render-markdown.render.base')

---@class render.md.inline.link.Data
---@field icon render.md.mark.Text
---@field title? render.md.Node
---@field autolink boolean
---@field destination? string
---@field link_text? string
---@field link_label_node? render.md.Node
---@field display_text? string  -- 预览时显示的文字（仅文件名等）

---@class render.md.render.inline.CustomLink: render.md.Render
---@field private config render.md.link.Config
---@field private data render.md.inline.link.Data
local CustomLink = setmetatable({}, Base)
CustomLink.__index = CustomLink

---@protected
---@return boolean
function CustomLink:setup()
    self.config = self.context.config.link
    if not self.config.enabled then
        return false
    end
    if self.node:descendant('shortcut_link') then
        return false
    end
    local icon = { self.config.hyperlink, self.config.highlight } ---@type render.md.mark.Text
    local title = nil ---@type render.md.Node?
    local autolink = false
    local destination = nil
    local link_text = nil
    local link_label_node = nil ---@type render.md.Node?
    local display_text = nil ---@type string?
    
    if self.node.type == 'email_autolink' then
        icon[1] = self.config.email
        autolink = true
    elseif self.node.type == 'image' then
        icon[1] = self.config.image
        local dest_node = self.node:child('link_destination')
        if dest_node and self.config.image_custom then
            self.context.config:set_link_text(dest_node.text, icon)
        end
        title = self.node:child('link_title')
    elseif self.node.type == 'inline_link' then
        local dest_node = self.node:child('link_destination')
        if dest_node then
            destination = dest_node.text
            self.context.config:set_link_text(destination, icon)
        end
        title = self.node:child('link_title')

        -- 获取链接文本节点；预览只显示文件名（从路径/URL 取最后一段），不显示完整路径
        local link_label = self.node:child('link_label') or self.node:child(1)
        if link_label and link_label.type ~= '[' and link_label.type ~= ']' and
           link_label.type ~= '(' and link_label.type ~= ')' and
           link_label.type ~= 'link_destination' then
            link_text = link_label.text
            link_label_node = link_label
        end
        -- 从 destination 取最后一段作为显示名（文件名）
        local display_text = link_text
        if destination and #destination > 0 then
            local filename = destination:match("([^/\\]+)$")
            if filename and #filename > 0 then
                display_text = filename
            end
        end
    elseif self.node.type == 'uri_autolink' then
        destination = self.node.text:sub(2, -2)
        self.context.config:set_link_text(destination, icon)
        autolink = true
    end
    self.data = {
        icon = icon,
        title = title,
        autolink = autolink,
        destination = destination,
        link_text = link_text,
        link_label_node = link_label_node,
        display_text = display_text,
    }
    return true
end

---@protected
function CustomLink:run()
    -- 对于 inline_link，隐藏语法字符
    if self.node.type == 'inline_link' then
        -- 隐藏 [ 和 ]
        local children = {}
        self.node:for_each_child(function(child)
            table.insert(children, child)
        end)
        
        -- 查找各个部分
        for _, child in ipairs(children) do
            if child.type == '[' or child.type == ']' or
               child.type == '(' or child.type == ')' then
                self:hide(child.start_col, child.end_col - child.start_col)
            elseif child.type == 'link_destination' then
                self:hide(child.start_col, child.end_col - child.start_col)
            elseif child.type == 'link_label' or (child == self.data.link_label_node) then
                self:hide(child.start_col, child.end_col - child.start_col)
            end
        end

        -- 在链接起始位置用「图标 + 文件名」整段 virt_text（链接样式），避免 overlay 不生效
        local link_hl = self.data.icon[2]
        local show_text = (self.data.display_text and #self.data.display_text > 0)
            and (self.data.icon[1] .. ' ' .. self.data.display_text)
            or self.data.icon[1]
        self.marks:start(self.config, 'link', self.node, {
            priority = 9000,
            hl_mode = 'combine',
            virt_text = { { show_text, link_hl } },
            virt_text_pos = 'inline',
        })

        -- 处理标题
        self.marks:over(self.config, 'link', self.data.title, {
            priority = 1000,
            hl_group = self.config.highlight_title,
        })

    elseif self.data.autolink then
        -- 原有的 autolink 处理
        self.marks:start(self.config, 'link', self.node, {
            priority = 9000,
            hl_mode = 'combine',
            virt_text = { self.data.icon },
            virt_text_pos = 'inline',
        })
        self.marks:over(self.config, 'link', self.data.title, {
            priority = 1000,
            hl_group = self.config.highlight_title,
        })
        self:hide(self.node.start_col, 1)
        self.marks:over(self.config, 'link', self.node, {
            priority = 1000,
            hl_group = self.data.icon[2],
        })
        self:hide(self.node.end_col - 1, 1)
    else
        -- 其他链接类型
        self.marks:start(self.config, 'link', self.node, {
            priority = 9000,
            hl_mode = 'combine',
            virt_text = { self.data.icon },
            virt_text_pos = 'inline',
        })
        self.marks:over(self.config, 'link', self.data.title, {
            priority = 1000,
            hl_group = self.config.highlight_title,
        })
    end
end

---@private
---@param col integer
---@param length integer
function CustomLink:hide(col, length)
    self.marks:add(self.config, true, self.node.start_row, col, {
        end_col = col + length,
        conceal = '',
    })
end

return CustomLink