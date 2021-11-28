<template lang="html">
  <div class="home">
    <card
        title="Logs"
        :blue="true"
    >
      <div class="explanations">

        <span
            v-for="cons in logs"
            v-bind:key="cons.time"
        >
            <p>{{ cons.time }} -> {{ cons.contenu }}</p>
          </span>


      </div>
    </card>
  </div>
<!--  <span> address : {{ address }}</span>-->
<!--  <span> projectName : {{ projectName }}</span>-->
<!--  <span> account : {{ account }}</span>-->
<!--  <span> project : {{ project }}</span>-->
<!--  <span> issueContenu: {{ issueContenu }}</span>-->
<!--  <span> reward : {{ reward }}</span>-->
<!--  <span> logs : {{ logs }}</span>-->


</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import moment from 'moment'
import CollectiveButton from '@/components/CollectiveButton.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  components: { Card},
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const projectName = this.$route.query.projectName
    const project = null
    const issueName = ''
    const issueContenu = ''
    const reward = 0
    const created = false;
    const logs : any[] = []
    return { account,projectName,project,issueName,issueContenu,reward,created,logs}
  },
  methods: {
    async IssueSignUP(){
      const {contract,projectName,issueName,issueContenu,reward} = this
      await contract.methods.issueSignUP(projectName,issueName,issueContenu,reward).send()
      // this.project = await contract.methods.project(Pname);
      this.created = true;
    }
  },
  async mounted() {
    const { address, contract,projectName } = this
    const account = await contract.methods.user(address).call()
    this.account = account
    const proj = await contract.methods.project(projectName).call()
    this.project = proj
    const logs = await contract.methods.eventlist(proj.id).call()
    for (const l of logs){
      this.logs.push({time: new Date(l.time*1000).toUTCString(), contenu: l.contenu})
    }
    //this.logs = logs
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 1000px;
  margin: auto;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}

</style>