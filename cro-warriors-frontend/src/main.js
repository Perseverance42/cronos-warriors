import Vue from 'vue';
import App from './App.vue';
import vuetify from './plugins/vuetify';
import Web3 from 'web3';

Vue.config.productionTip = false
Vue.prototype.$Web3 = Web3;
new Vue({
  vuetify,
  render: h => h(App)
}).$mount('#app')
