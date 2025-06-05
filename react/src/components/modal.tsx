import { faClose } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { FC, ReactNode } from 'react'

interface ModalProps {
  children?: ReactNode
  title?: string
  onClose?: () => void
}

export const Modal: FC<ModalProps> = (props: ModalProps) => {
  return (
    <div className="fixed inset-0 flex justify-center items-center bg-black bg-opacity-50 z-50">
      <div className="bg-white w-96 shadow-lg rounded-lg">
        {props.onClose && (
          <div
            className="float-right p-4 cursor-pointer"
            onClick={props.onClose}
          >
            <FontAwesomeIcon icon={faClose} />
          </div>
        )}

        <div className="p-6">
          {props.title && (
            <div className="text-lg font-semibold mb-4">{props.title}</div>
          )}
          {props.children}
        </div>
      </div>
    </div>
  )
}
