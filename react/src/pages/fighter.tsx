import { BlockTitle, f7, List, ListItem, Navbar, Page } from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { Logger } from '../utils/logger'
import { EmptyFighter, type Fighter } from '../models/fighter'

const logger: Logger = new Logger('/src/pages/fighter.tsx')

type FighterPageProps = {
  id: string
}

export const FighterPage: FC<FighterPageProps> = (props: FighterPageProps) => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const fighter: Fighter | undefined = useSelector(backendSelectors.getFighter)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getFighter(props.id))
    done()
  }

  useEffect(() => {
    logger.debug(`props.id=${props.id}`)
    dispatch(backendActions.getFighter(props.id))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (!error) {
      return
    }

    logger.error('error on component', error)
    f7.dialog.alert(
      error?.message || t('unknownError', { postProcess: 'capitalize' }),
      () => {
        dispatch(backendActions.clearError())
      },
    )
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [error])

  const cmToFeetInches = (cm: number): string => {
    const totalInches: number = cm / 2.54
    const feet: number = Math.floor(totalInches / 12)
    const inches: number = Math.round(totalInches % 12)
    return `${feet}'${inches}''`
  }

  return (
    <Page ptr ptrMousewheel={true} onPtrRefresh={onPullRefreshed}>
      <Navbar
        title={
          fighter
            ? `${fighter.name}`
            : t('fighter', { postProcess: 'capitalize' })
        }
        large
        backLink
      />

      <BlockTitle>{t('fighter', { postProcess: 'capitalize' })}</BlockTitle>
      {state === 'getting_fighter' && (
        <List
          className="skeleton-text skeleton-effect-wave"
          dividersIos
          mediaList
          strongIos
          inset
        >
          <ListItem
            after={EmptyFighter.name}
            title={t('name', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={EmptyFighter.nickname}
            title={t('nickname', { postProcess: 'capitalize' })}
          />
          {EmptyFighter.city?.country && (
            <ListItem
              after={EmptyFighter.city.country.name}
              title={t('country', { postProcess: 'capitalize' })}
            />
          )}
          {EmptyFighter.city && (
            <ListItem
              after={EmptyFighter.city.name}
              title={t('city', { postProcess: 'capitalize' })}
            />
          )}
          <ListItem
            after={EmptyFighter.weight}
            title={t('weight', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={EmptyFighter.height}
            title={t('height', { postProcess: 'capitalize' })}
          />
        </List>
      )}
      {state !== 'getting_fighter' && fighter && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            after={fighter.name}
            title={t('name', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={fighter.nickname}
            title={t('nickname', { postProcess: 'capitalize' })}
          />
          {fighter.city?.country && (
            <ListItem
              after={fighter.city.country.name}
              title={t('country', { postProcess: 'capitalize' })}
            />
          )}
          {fighter.city && (
            <ListItem
              after={fighter.city.name}
              title={t('city', { postProcess: 'capitalize' })}
            />
          )}
          <ListItem title={t('height', { postProcess: 'capitalize' })}>
            <span slot="after">
              {cmToFeetInches(fighter.height)} / {fighter.height} cm
            </span>
          </ListItem>
          <ListItem title={t('weight', { postProcess: 'capitalize' })}>
            <span slot="after">
              {(fighter.weight * 2.2).toFixed(2)} lbs / {fighter.weight} kgs
            </span>
          </ListItem>
        </List>
      )}
    </Page>
  )
}
