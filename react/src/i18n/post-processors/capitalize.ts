import type { PostProcessorModule } from 'i18next'
import { StringUtils } from '../../utils/string-utils'

export const capitalizeProcessor: PostProcessorModule = {
  type: 'postProcessor',
  name: 'capitalize',
  process(value: string): string {
    return StringUtils.capitalize(value)
  },
}
