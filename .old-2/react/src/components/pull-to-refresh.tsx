import { type FC, type ReactNode } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowDown, faSpinner } from '@fortawesome/free-solid-svg-icons'
import { usePullToRefresh } from '../hooks/usePullToRefresh'

interface PullToRefreshProps {
  onRefresh: () => void
  isRefreshing: boolean
  children: ReactNode
}

export const PullToRefresh: FC<PullToRefreshProps> = ({
  onRefresh,
  isRefreshing,
  children,
}) => {
  const {
    containerRef,
    pullDistance,
    pullProgress,
    shouldTriggerRefresh,
  } = usePullToRefresh({
    onRefresh,
    isRefreshing,
  })

  return (
    <div ref={containerRef} className="relative">
      {/* Pull indicator */}
      <div
        className="absolute top-0 left-0 right-0 flex items-center justify-center transition-all duration-200 ease-out pointer-events-none z-10"
        style={{
          height: `${pullDistance}px`,
          opacity: pullDistance > 0 ? 1 : 0,
        }}
      >
        <div className="bg-white dark:bg-gray-800 rounded-full shadow-lg p-3 border border-gray-200 dark:border-gray-700">
          {isRefreshing ? (
            <FontAwesomeIcon
              icon={faSpinner}
              className="w-5 h-5 text-blue-600 dark:text-blue-400 animate-spin"
            />
          ) : (
            <FontAwesomeIcon
              icon={faArrowDown}
              className={`w-5 h-5 transition-all duration-200 ${
                shouldTriggerRefresh
                  ? 'text-blue-600 dark:text-blue-400 rotate-180'
                  : 'text-gray-400 dark:text-gray-500'
              }`}
              style={{
                transform: shouldTriggerRefresh ? 'rotate(180deg)' : `rotate(${pullProgress * 1.8}deg)`,
              }}
            />
          )}
        </div>
      </div>

      {/* Content */}
      <div
        className="transition-transform duration-200 ease-out"
        style={{
          transform: `translateY(${pullDistance}px)`,
        }}
      >
        {children}
      </div>
    </div>
  )
}

