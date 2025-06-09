import { List, ListItem, Navbar, Page } from 'framework7-react'
import { type FC } from 'react'
import { useTranslation } from 'react-i18next'

export const NotFound: FC = () => {
  const { t } = useTranslation()

  return (
    <Page>
      <Navbar
        title={t('notFound', { postProcess: 'capitalize' })}
        large
        backLink
      />
      <List dividersIos mediaList strongIos inset>
        <ListItem title={window.location.pathname} />
      </List>
    </Page>
  )
}
