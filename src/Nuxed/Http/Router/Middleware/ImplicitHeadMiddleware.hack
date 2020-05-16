namespace Nuxed\Http\Router\Middleware;

use namespace HH\Lib\C;
use namespace Nuxed\Http\{Message, Router};
use namespace Nuxed\Contract\Http;

/**
 * Handle implicit HEAD requests.
 *
 * Place this middleware after the routing middleware so that it can handle
 * implicit HEAD requests: requests where HEAD is used, but the route does
 * not explicitly handle that request method.
 */
final class ImplicitHeadMiddleware implements Http\Server\IMiddleware {
  const string ForwardedHttpMethodAttribute = 'FORWARDED_HTTP_METHOD';

  /**
   * Handle an implicit HEAD request.
   *
   * If the route allows GET requests, dispatches as a GET request and
   * resets the response body to be empty; otherwise, creates a new empty
   * response.
   */
  public async function process(
    Http\Message\IServerRequest $request,
    Http\Server\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\MethodNotAllowedException $e) {
      if ($request->getMethod() !== Http\Message\RequestMethod::Head) {
        throw $e;
      }

      $allowedMethods = $e->getAllowedMethods();
      if (
        C\count($allowedMethods) !== 1 ||
        C\contains($allowedMethods, Http\Message\RequestMethod::Get)
      ) {
        // Only reroute GET -> HEAD, otherwise the application might fall into a security trap.
        // see: https://blog.teddykatz.com/2019/11/05/github-oauth-bypass.html
        throw $e;
      }

      $response = await $handler->handle(
        $request->withMethod(Http\Message\RequestMethod::Get)
          ->withAttribute(
            self::ForwardedHttpMethodAttribute,
            Http\Message\RequestMethod::Head,
          ),
      );

      return $response->withBody(Message\Body\temporary());
    }
  }
}
