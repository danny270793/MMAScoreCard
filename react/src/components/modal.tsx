import { faClose } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { FC, ReactNode } from 'react'

interface ModalProps {
  children?: ReactNode
  title?: string
  onClose?: () => void
  type?: 'error' | 'info' | 'success'
}

export const Modal: FC<ModalProps> = (props: ModalProps) => {
  return (
    <div className="fixed inset-0 flex justify-center items-center bg-black/70 z-50">
      <div
        className={[
          'w-96 shadow-lg rounded-lg',
          props.type === 'error'
            ? 'bg-red-500'
            : props.type === 'success'
              ? 'bg-green-500'
              : props.type === 'info'
                ? 'bg-white'
                : 'bg-white',
        ].join(' ')}
      >
        {props.onClose && (
          <div
            className={[
              'float-right px-2 cursor-pointer rounded-tr-lg hover:bg-red-500',
              props.type === 'error'
                ? 'text-white hover:bg-red-800'
                : 'text-black hover:bg-red-500 hover:text-white',
            ].join(' ')}
            onClick={props.onClose}
          >
            <FontAwesomeIcon icon={faClose} />
          </div>
        )}

        <div
          className={[
            'p-6',
            props.type === 'error' ? 'text-white' : 'text-black',
          ].join(' ')}
        >
          {props.title && (
            <div className="text-lg font-semibold mb-4">{props.title}</div>
          )}
          {props.children}
        </div>
      </div>
    </div>
  )
}
