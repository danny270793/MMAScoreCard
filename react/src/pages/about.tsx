import {
  BlockTitle,
  Link,
  List,
  ListItem,
  Navbar,
  Page,
} from 'framework7-react'
import { useTranslation } from 'react-i18next'
import { App, type AppInfo } from '@capacitor/app'
import { useEffect, useState } from 'react'

export const AboutPage = () => {
  const { t } = useTranslation()
  const [appInfo, setAppInfo] = useState<AppInfo | undefined>(undefined)

  const getAppInfo = async () => {
    const info: AppInfo = await App.getInfo()
    setAppInfo(info)
  }

  useEffect(() => {
    getAppInfo()
  }, [])

  return (
    <Page>
      <Navbar
        title={t('about', { postProcess: 'capitalize' })}
        large
        backLink
      />
      <BlockTitle>{t('application', { postProcess: 'capitalize' })}</BlockTitle>
      {appInfo && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            title={t('name', { postProcess: 'capitalize' })}
            after={appInfo.name}
          />
          <ListItem
            title={t('version', { postProcess: 'capitalize' })}
            after={appInfo.version}
          />
          <ListItem
            title={t('buildNumber', { postProcess: 'capitalize' })}
            after={appInfo.build}
          />
        </List>
      )}
      {!appInfo && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={t('name', { postProcess: 'capitalize' })}
            after={'appInfo.name'}
          />
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={t('version', { postProcess: 'capitalize' })}
            after={'appInfo.version'}
          />
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={t('buildNumber', { postProcess: 'capitalize' })}
            after={'appInfo.build'}
          />
        </List>
      )}

      <BlockTitle>{t('application', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        <ListItem
          title={t('name', { postProcess: 'capitalize' })}
          after={'Danny Vaca'}
        />
        <ListItem
          title={t('email', { postProcess: 'capitalize' })}
          after={'danny270793@gmail.com'}
        />
      </List>

      <BlockTitle>{t('social', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        <ListItem>
          <Link href="https://danny270793.github.io" external>
            Website
          </Link>
        </ListItem>
        <ListItem>
          <Link href="https://www.github.com/danny270793" external>
            Github
          </Link>
        </ListItem>
        <ListItem>
          <Link
            href="https://www.youtube.com/channel/UC5MAQWU2s2VESTXaUo-ysgg"
            external
          >
            Youtube
          </Link>
        </ListItem>
        <ListItem>
          <Link href="https://www.linkedin.com/in/danny270793" external>
            LinkedIn
          </Link>
        </ListItem>
      </List>
    </Page>
  )
}
