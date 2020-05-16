namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Contract\Http;
use namespace Nuxed\Http\{Message, Router};

/**
 * Handle implicit OPTIONS requests.
 *
 * Place this middleware after the routing middleware so that it can handle
 * implicit OPTIONS requests: requests where OPTIONS is used, but the route
 * does not explicitly handle that request method.
 *
 * When invoked, it will create a response with status code 200 and an Allow
 * header that defines all accepted request methods.
 *
 * You may optionally pass a response prototype to the constructor; when
 * present, that prototype will be used to create a new response with the
 * Allow header.
 *
 * The middleware is only invoked in these specific conditions:
 *
 * - an OPTIONS request
 * - with a `RouteResult` present
 * - where the `RouteResult` contains a `Route` instance
 * - and the `Route` instance defines implicit OPTIONS.
 *
 * In all other circumstances, it will return the result of the delegate.
 */
final class ImplicitOptionsMiddleware implements Http\Server\IMiddleware {
  public function __construct(
    private ?Http\Message\IResponse $response = null,
  ) {}

  /**
   * Handle an implicit OPTIONS request.
   */
  public async function process(
    Http\Message\IServerRequest $request,
    Http\Server\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\MethodNotAllowedException $e) {
      if ($request->getMethod() !== Http\Message\RequestMethod::Options) {
        throw $e;
      }

      return Message\response()
        ->withHeader('Allow', $e->getAllowedMethods());
    }
  }
}
