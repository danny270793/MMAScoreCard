import type { PostProcessorModule } from 'i18next'

export const uppercaseProcessor: PostProcessorModule = {
  type: 'postProcessor',
  name: 'uppercase',
  process(value: string): string {
    return value.toUpperCase()
  },
}
