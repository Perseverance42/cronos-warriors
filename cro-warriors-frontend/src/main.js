import Vue from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';
import Web3 from 'web3';

Vue.config.productionTip = false
Vue.prototype.$Web3 = Web3;

//router
import Router from 'vue-router';
import router from './plugins/router'

const wallet = Vue.observable({wallet:null});

Object.defineProperty(Vue.prototype, '$wallet', {
  get(){return wallet.wallet},
  set(value){wallet.wallet=value}
})

Vue.prototype.$wallet = "cake";
Vue.use(Router)
new Vue({
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
