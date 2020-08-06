#' Load Cached Log
#' @import R.cache
#' @export

loadLog <-
        function() {

                R.cache::loadCache(dirs = "setupAthena",
                                   key = list("history"))


        }
