import { ListItem } from 'framework7-react'
import type { FC } from 'react'
import type { Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faLocation,
  faMap,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { useTranslation } from 'react-i18next'

interface EventListItemProps {
  event: Event
  skeleton?: boolean
}

export const EventListItem: FC<EventListItemProps> = (
  props: EventListItemProps,
) => {
  const { t } = useTranslation()

  return (
    <ListItem
      className={props.skeleton ? 'skeleton-text skeleton-effect-wave' : ''}
      link={`/events/${props.event.id}`}
      key={props.event.id}
      title={props.event.name}
      subtitle={props.event.fight}
      after={
        props.skeleton
          ? 'uppcoming'
          : props.event.status === 'uppcoming'
            ? t('upcoming', { postProcess: 'capitalize' })
            : ''
      }
    >
      <br />
      <div>
        {!props.skeleton && (
          <>
            <FontAwesomeIcon className="w-4" icon={faCalendar} />{' '}
          </>
        )}
        <span className="opacity-60">
          {props.event.date.toISOString().split('T')[0]}
        </span>{' '}
        <span className="opacity-60">
          {t('inXXDays', {
            days: DateUtils.daysBetween(props.event.date, new Date()),
          })}
        </span>
      </div>
      <div>
        {!props.skeleton && (
          <>
            <FontAwesomeIcon className="w-4" icon={faMap} />{' '}
          </>
        )}
        <span className=" opacity-60">
          {props.event.location.city.country.name} -{' '}
          {props.event.location.city.name}
        </span>
      </div>
      <div>
        {props.event.location.name !== '' && (
          <>
            {!props.skeleton && (
              <>
                <FontAwesomeIcon className="w-4" icon={faLocation} />{' '}
              </>
            )}
            <span className="opacity-60">{props.event.location.name}</span>
          </>
        )}
      </div>
    </ListItem>
  )
}
