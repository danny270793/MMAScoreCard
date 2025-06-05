import type { FC } from 'react'

export const Loader: FC = () => {
  return (
    <div className="fixed inset-0 flex justify-center items-center z-50">
      <div className="border-4 border-dashed rounded-full w-16 h-16 animate-spin" />
    </div>
  )
}
