<template lang="html">
  <div class="home">
    <form>
      <card
          title="Bounty Task  "
      >
        <div class="explanations">
          <p><b>Name : </b>{{ issue[1]}}</p>
          <p><b>In project : </b>{{ issue[0] }}</p>
          <p><b>Detail: </b>{{ issue[2] }}</p>
          <p><b>reward: </b>{{ issue[4] }}</p>
        </div>

      </card>
    </form >
    <spacer :size="24" />
    <card title="Fix this Bounty Task"  :blue="true" v-if="!fixed">
      <collective-button :transparent="true" @click="fix">
        Fix!
      </collective-button>
    </card>
  </div>



<!--  <span> address : {{ address }}</span>-->
<!--  <span> issue : {{ issue }}</span>-->
<!--  <span> account : {{ account }}</span>-->
<!--  <span> issueName : {{ issueName }}</span>-->
<!--  <span> issueContenu: {{ issueContenu }}</span>-->
<!--  <span> reward : {{ reward }}</span>-->
<!--  <span> created : {{ created }}</span>-->
<!--  <span> issue_type : {{ issue_type }}</span>-->


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
    const issue = this.$route.query.issue
    const issueName = ''
    const issueContenu = ''
    const reward = 0
    const created = false;
    const issue_type = null;
    const fixed = false;
    return { account,issue,issueName,issueContenu,reward,created,issue_type,fixed}
  },
  methods: {
    async fix() {
      const {address, contract,issue} = this
      if (issue != null) {
        const n = issue[0]
        const isname = issue[1]
        this.account = await contract.methods.fix(n, isname).send()
        this.fixed = true
      }
    },
  },
  async mounted() {
    const { address, contract,issue } = this
    const account = await contract.methods.user(address).call()
    if (issue != null) {
      const n = issue[0]
      const project = await contract.methods.project(n).call()
      const id = project.id
      const issues = await contract.methods.issue(id).call()
      const isname = issue[1]
      for (const IS of issues) {
        if (IS.name == isname ){
          this.issue_type = IS
        }
      }

    }
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