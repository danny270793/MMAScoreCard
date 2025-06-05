import type { FC } from 'react'

export const Loader: FC = () => {
  return (
    <div className="fixed inset-0 flex justify-center bg-black/70 z-101">
      <span className="loading loading-spinner loading-xl text-white" />
    </div>
  )
}
