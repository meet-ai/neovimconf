-- LSP 客户端工厂:angularls
-- 返回 server 表;ngserver 不可用或未安装时返回 nil(调用方据此跳过)
local utils = require("lsp.utils")

local function make_angularls_server()
  local global_node_modules = utils.get_global_node_modules()
  local ngserver_cmd = { "ngserver", "--stdio" }
  if not utils.check_server_availability(ngserver_cmd) then
    return nil
  end

  local global_probe_locations = {}
  if global_node_modules then
    table.insert(global_probe_locations, global_node_modules)
  end

  return {
    name = "angularls",
    config = {
      capabilities = utils.capabilities,
      cmd = ngserver_cmd,
      filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
      root_markers = { "angular.json", "project.json", "nx.json" },
      on_new_config = function(new_config, root_dir)
        local ts_probe_locations = {}
        local ng_probe_locations = {}
        local project_node_modules = root_dir and (root_dir .. "/node_modules") or nil

        if utils.path_exists(project_node_modules) then
          table.insert(ts_probe_locations, project_node_modules)
          local project_angular_node_modules = project_node_modules .. "/@angular/language-server/node_modules"
          if utils.path_exists(project_angular_node_modules) then
            table.insert(ng_probe_locations, project_angular_node_modules)
          end
        end

        for _, p in ipairs(global_probe_locations) do
          table.insert(ts_probe_locations, p)
          local global_angular_node_modules = p .. "/@angular/language-server/node_modules"
          if utils.path_exists(global_angular_node_modules) then
            table.insert(ng_probe_locations, global_angular_node_modules)
          end
        end

        local cmd = { ngserver_cmd[1], ngserver_cmd[2] }
        if #ts_probe_locations > 0 then
          vim.list_extend(cmd, { "--tsProbeLocations", table.concat(ts_probe_locations, ",") })
        end
        if #ng_probe_locations > 0 then
          vim.list_extend(cmd, { "--ngProbeLocations", table.concat(ng_probe_locations, ",") })
        end
        vim.list_extend(cmd, { "--angularCoreVersion", "" })
        new_config.cmd = cmd
      end,
    },
  }
end

return make_angularls_server
