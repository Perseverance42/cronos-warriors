import VueRouter from "vue-router";

const Leaderboard = () => import('../views/Leaderboard.vue');
const Arena = () => import('../views/Arena.vue');
const Army = () => import('../views/Army.vue');
const Mint = () => import( '../views/Minting.vue');

const routes = [
    {
        path:"/",
        component: Army
    },
    {
        path: "/leaderboard",
        component: Leaderboard
    },
    {
        path: "/mint",
        component: Mint
    },
    {
        path: "/arena",
        component: Arena
    },
    {
        path: "/army",
        component: Army
    },
]

// configure router
const router = new VueRouter({
    mode: "history",
    base: process.env.BASE_URL,
    routes, // short for routes: routes
    linkExactActiveClass: "active",
    scrollBehavior: (to) => {
      if (to.hash) {
        return { selector: to.hash }
      } else {
        return { x: 0, y: 0 }
      }
    }
});

export default router