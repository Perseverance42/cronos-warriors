import Vue from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';
import Wallet from './scripts/wallet.js';

Vue.config.productionTip = false

//router
import Router from 'vue-router';
import router from './plugins/router';

const wallet = Vue.observable({wallet:Wallet});
const selectedWarrior = Vue.observable({warrior:0});

Object.defineProperty(Vue.prototype, '$wallet', {
  get(){return wallet.wallet},
  set(value){wallet.wallet=value}
})

Object.defineProperty(Vue.prototype, '$selectedWarrior', {
  get(){return selectedWarrior.warrior},
  set(value){selectedWarrior.warrior=value}
})

Vue.use(Router)
new Vue({
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
