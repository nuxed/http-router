namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Contract\Http;
use namespace Nuxed\Http\{Message, Router};

final class NotFoundMiddleware implements Http\Server\IMiddleware {
  public function __construct() {}

  public async function process(
    Http\Message\IServerRequest $request,
    Http\Server\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\NotFoundException $e) {
      return Message\response()
        ->withStatus(Http\Message\StatusCode::NotFound);
    }
  }
}
