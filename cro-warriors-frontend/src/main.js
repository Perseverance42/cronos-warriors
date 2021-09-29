import Vue from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';
import Wallet from './scripts/wallet.js';

Vue.config.productionTip = false

//router
import Router from 'vue-router';
import router from './plugins/router';

const wallet = Vue.observable({wallet:Wallet});

Object.defineProperty(Vue.prototype, '$wallet', {
  get(){return wallet.wallet},
  set(value){wallet.wallet=value}
})
Vue.use(Router)
new Vue({
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
