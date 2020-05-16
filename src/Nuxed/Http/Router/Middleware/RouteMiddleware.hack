namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Contract\Http\{Message, Server};
use namespace Nuxed\Http\Router;
use namespace Nuxed\Http\Router\Exception;
use namespace Nuxed\Http\Message\Response;

/**
 * Default routing middleware.
 */
final class RouteMiddleware implements Server\IMiddleware {
  public function __construct(
    protected Router\Matcher\IRequestMatcher $matcher,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Server\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      $route = await $this->matcher->match($request);
      foreach ($route->getParameters() as $key => $value) {
        $request = $request->withAttribute($key, $value);
      }

      $request = $request->withAttribute(Router\Route::class, $route);
    } catch (Exception\MethodNotAllowedException $e) {

    } catch (Exception\NotFoundException $e) {
      return Response\empty()
        ->withStatus(Message\StatusCode::NotFound);
    }

    return await $handler->handle($request);
  }
}
