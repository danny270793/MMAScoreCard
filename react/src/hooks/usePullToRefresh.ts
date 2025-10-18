import { useEffect, useRef, useState } from 'react'

interface UsePullToRefreshOptions {
  onRefresh: () => void
  isRefreshing: boolean
  threshold?: number
  resistance?: number
}

export const usePullToRefresh = ({
  onRefresh,
  isRefreshing,
  threshold = 80,
  resistance = 2.5,
}: UsePullToRefreshOptions) => {
  const [pullDistance, setPullDistance] = useState(0)
  const [isPulling, setIsPulling] = useState(false)
  const startY = useRef(0)
  const currentY = useRef(0)
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const container = containerRef.current
    if (!container) return

    let rafId: number | null = null

    const handleTouchStart = (e: TouchEvent) => {
      // Only start pulling if at the top of the page
      if (window.scrollY === 0) {
        startY.current = e.touches[0].clientY
        setIsPulling(true)
      }
    }

    const handleTouchMove = (e: TouchEvent) => {
      if (!isPulling || isRefreshing) return

      currentY.current = e.touches[0].clientY
      const distance = currentY.current - startY.current

      // Only allow pulling down
      if (distance > 0 && window.scrollY === 0) {
        // Prevent default scroll behavior
        e.preventDefault()

        // Apply resistance to the pull distance
        const resistedDistance = distance / resistance
        
        if (rafId) {
          cancelAnimationFrame(rafId)
        }

        rafId = requestAnimationFrame(() => {
          setPullDistance(Math.min(resistedDistance, threshold * 1.5))
        })
      }
    }

    const handleTouchEnd = () => {
      if (pullDistance >= threshold && !isRefreshing) {
        onRefresh()
      }

      setIsPulling(false)
      setPullDistance(0)
      startY.current = 0
      currentY.current = 0

      if (rafId) {
        cancelAnimationFrame(rafId)
        rafId = null
      }
    }

    // Add passive: false to allow preventDefault
    container.addEventListener('touchstart', handleTouchStart, { passive: true })
    container.addEventListener('touchmove', handleTouchMove, { passive: false })
    container.addEventListener('touchend', handleTouchEnd, { passive: true })
    container.addEventListener('touchcancel', handleTouchEnd, { passive: true })

    return () => {
      container.removeEventListener('touchstart', handleTouchStart)
      container.removeEventListener('touchmove', handleTouchMove)
      container.removeEventListener('touchend', handleTouchEnd)
      container.removeEventListener('touchcancel', handleTouchEnd)

      if (rafId) {
        cancelAnimationFrame(rafId)
      }
    }
  }, [isPulling, pullDistance, threshold, onRefresh, isRefreshing, resistance])

  const pullProgress = Math.min((pullDistance / threshold) * 100, 100)
  const shouldTriggerRefresh = pullDistance >= threshold

  return {
    containerRef,
    pullDistance,
    pullProgress,
    isPulling,
    isRefreshing,
    shouldTriggerRefresh,
  }
}

