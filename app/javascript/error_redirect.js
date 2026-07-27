const ERROR_PAGE_PATHS = {
  400: "/400.html",
  404: "/404.html",
  406: "/406-unsupported-browser.html",
  422: "/422.html",
  500: "/500.html"
}

const ERROR_PAGE_PATH_SET = new Set(Object.values(ERROR_PAGE_PATHS))

export function redirectOnError(response) {
  const redirectedUrl = new URL(response.url, window.location.origin)

  if (response.redirected && ERROR_PAGE_PATH_SET.has(redirectedUrl.pathname)) {
    window.location.assign(redirectedUrl.href)
    return true
  }

  if (response.ok) return false

  redirectToErrorPage(response.status)
  return true
}

export function redirectToErrorPage(status = 500) {
  window.location.assign(errorPagePath(status))
}

function errorPagePath(status) {
  if (ERROR_PAGE_PATHS[status]) return ERROR_PAGE_PATHS[status]
  if (status >= 400 && status < 500) return ERROR_PAGE_PATHS[400]

  return ERROR_PAGE_PATHS[500]
}
