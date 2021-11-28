<template lang="html">
  <div class="home" v-if="!created">
    <form>
      <card
          title="Create Bounty Task  "
      >
        <span class="input-username">Name</span>
        <input
            type="text"
            class="input-username"
            v-model="issueName"
            placeholder="Type here"
        />
        <span class="input-username">Task details</span>
        <input
            type="text"
            class="input-username"
            v-model="issueContenu"
            placeholder="Type here"
        />
        <span class="input-username">Bounty</span>
        <input
            type="number"
            class="input-username"
            v-model="reward"
            placeholder="Type here"
        />
      </card>
    </form>
    <spacer :size="24" />
    <card title="Create your Bounty Task"  :blue="true">
      <collective-button :transparent="true" @click="IssueSignUP">
        Create!
      </collective-button>
    </card>
  </div>

  <div class="home" v-else>
    <div class="card-home-wrapper">
      <card
          title="Created!"
          :blue="true"
          :subtitle="`Task Name: ${issueName} `"
      >
      </card>
    </div>


  </div>
<!--  <span> address : {{ address }}</span>-->
<!--  <span> projectName : {{ projectName }}</span>-->
<!--  <span> account : {{ account }}</span>-->
<!--  <span> issueName : {{ issueName }}</span>-->
<!--  <span> issueContenu: {{ issueContenu }}</span>-->
<!--  <span> reward : {{ reward }}</span>-->
<!--  <span> created : {{ created }}</span>-->


</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  components: { Card,CollectiveButton,Spacer},
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
    return { account,projectName,project,issueName,issueContenu,reward,created}
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
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    this.account = account
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