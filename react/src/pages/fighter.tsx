import { BlockTitle, f7, Navbar, Page } from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { Logger } from '../utils/logger'
import type { Fighter } from '../models/fighter'

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
      {state}
      {JSON.stringify(fighter, null, 2)}
      {/* <List dividersIos mediaList strongIos inset>
        {state === 'getting_fight' && (
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={EmptyFight.fighterOne.name}
            subtitle={EmptyFight.fighterOne.nickname}
          >
            <div slot="media">
              <FontAwesomeIcon className="w-4" icon={faThumbsUp} />
            </div>
          </ListItem>
        )}
        {state === 'getting_fight' && (
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={EmptyFight.fighterTwo.name}
            subtitle={EmptyFight.fighterTwo.nickname}
          >
            <div slot="media">
              <FontAwesomeIcon className="w-4" icon={faThumbsDown} />
            </div>
          </ListItem>
        )}

        {fight && state !== 'getting_fight' && (
          <ListItem
            chevronCenter
            link={`/fighters/${fight.fighterOne.id}`}
            title={fight.fighterOne.name}
            subtitle={fight.fighterOne.nickname}
          >
            <div slot="media">
              {fight.winner === 1 && (
                <FontAwesomeIcon className="w-4" icon={faThumbsUp} />
              )}
              {fight.winner === 2 && (
                <FontAwesomeIcon className="w-4" icon={faThumbsDown} />
              )}
            </div>
          </ListItem>
        )}
        {fight && state !== 'getting_fight' && (
          <ListItem
            chevronCenter
            link={`/fighters/${fight.fighterTwo.id}`}
            title={fight.fighterTwo.name}
            subtitle={fight.fighterTwo.nickname}
          >
            <div slot="media">
              {fight.winner === 2 && (
                <FontAwesomeIcon className="w-4" icon={faThumbsUp} />
              )}
              {fight.winner === 1 && (
                <FontAwesomeIcon className="w-4" icon={faThumbsDown} />
              )}
            </div>
          </ListItem>
        )}
      </List> */}
    </Page>
  )
}
