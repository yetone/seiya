module Settings
  PIPELINES = {
      'aa/pipelines/t|Pipelines::A' => 1,
      'aa/pipelines/t|Pipelines::B' => 2,
  }
  REQUEST_MIDDLEWARES = {
      'aa/middlewares|RequestMiddlewares::MyMiddleware' => 2,
      'aa/middlewares|RequestMiddlewares::MySubMiddleware' => 1,
  }
  COMMANDS = 'aa/commands|Commands'
end