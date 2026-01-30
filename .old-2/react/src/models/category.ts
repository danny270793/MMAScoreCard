export interface Category {
  id: number
  name: string
  weight: number
}

export const EmptyCategory: Category = {
  id: 0,
  name: '',
  weight: 0,
}
