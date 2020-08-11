#' Load Cached Log
#' @seealso
#'  \code{\link[R.cache]{loadCache}}
#' @rdname loadLog
#' @export
#' @importFrom R.cache loadCache

loadLog <-
        function() {

                R.cache::loadCache(dirs = "setupAthena",
                                   key = list("history"))


        }
