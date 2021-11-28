import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import store from '@/store'
import SignIn from '@/views/SignIn.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'SignIn',
    component: SignIn,
  },
  {
    path: '/account',
    name: 'Account',
    component: () => import('@/views/Account.vue'),
  },
  {
    path: '/entreprise',
    name: 'Entreprise',
    component: () => import('@/views/Entreprise.vue'),
  },
  {
    path: '/project',
    name: 'Project',
    component: () => import('@/views/Project.vue'),
  },
  {
    path: '/projectview',
    name: 'Projectview',
    component: () => import('@/views/Projectview.vue'),
  },
  {
    path: '/issue',
    name: 'Issue',
    component: () => import('@/views/Issue.vue'),
  },
  {
    path: '/issueview',
    name: 'Issueview',
    component: () => import('@/views/Issueview.vue'),
  },
  {
    path: '/projectlog',
    name: 'Projectlog',
    component: () => import('@/views/Projectlog.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
})

router.beforeEach((to, _from, next) => {
  if (to.name !== 'SignIn' && !store.state.account.address) {
    next({ name: 'SignIn' })
  } else {
    next()
  }
})

export default router
