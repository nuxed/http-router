namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Contract\{Container, Http};
use namespace Nuxed\Http\Router;

/**
 * Default dispatch middleware.
 *
 * Checks for a composed route result in the request. If none is provided,
 * delegates request processing to the handler.
 *
 * Otherwise, it delegates processing to the route result.
 */
final class DispatchMiddleware implements Http\Server\IMiddleware {
  public function __construct(private Container\IContainer $container) {}

  public async function process(
    Http\Message\IServerRequest $request,
    Http\Server\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    $route = $request->getAttribute(Router\Route::class);
    if ($route is Router\Route) {
      $handler = $this->container
        ->get<Http\Server\IHandler>($route->getHandler());

      return await $handler->handle($request);
    }

    return await $handler->handle($request);
  }
}
