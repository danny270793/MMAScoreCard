import {
  BlockTitle,
  Link,
  List,
  ListItem,
  Navbar,
  Page,
} from 'framework7-react'
import { useTranslation } from 'react-i18next'

export const AboutPage = () => {
  const { t } = useTranslation()

  return (
    <Page>
      <Navbar
        title={t('about', { postProcess: 'capitalize' })}
        large
        backLink
      />
      <BlockTitle>{t('application', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        <ListItem
          title={t('name', { postProcess: 'capitalize' })}
          after={'MMA ScoreCard'}
        />
        <ListItem
          title={t('version', { postProcess: 'capitalize' })}
          after={'1.0.0'}
        />
        <ListItem
          title={t('buildNumber', { postProcess: 'capitalize' })}
          after={'1'}
        />
      </List>

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
