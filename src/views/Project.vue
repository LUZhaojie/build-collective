<template lang="html">
  <div class="home" v-if="!project">
    <form>
      <card
          title="Project"
      >
        <span class="input-username">Name</span>
        <input
            type="text"
            class="input-username"
            v-model="projectName"
            placeholder="Type your ProjectName here"
        />

        <span class="input-username">Link</span>
        <input
            type="text"
            class="input-username"
            v-model="link"
            placeholder="Type here"
        />

      </card>
      <spacer :size="24" />
      <card title="Choose one or multiple contibutors ">
        <div v-for="items in userlist" v-bind:key="items.adr" class="input-username">
          <input type="checkbox"  :id= "items.adr" :value="items.adr" v-model="contributorsforsign" >
          <label>{{items.username}}</label>
        </div>
      </card>
      <spacer :size="24" />
      <card
          title="Add tokens for your project"
      >
        <input
            type="number"
            class="input-username"
            v-model="projectbalanceforsign"
            placeholder="Type your tokens here"
        />
      </card>
    </form>
    <spacer :size="24" />
    <card title="Create your Project"  :blue="true">
      <collective-button :transparent="true" @click="projectSignUP">
        Create!
      </collective-button>
    </card>
  </div>

  <div class="home" v-else>
    <div class="card-home-wrapper">
    <card
        title="Created!"
        :blue="true"
        :subtitle="`Project Name: ${project.name} `"
        >
      </card>
      </div>


  </div>
<!--  <span> address : {{ address }}</span>-->
<!--  <span> created : {{ created }}</span>-->
<!--  <span> projectName : {{ projectName }}</span>-->
<!--  <span> account : {{ account }}</span>-->
<!--  <span> username : {{ username }}</span>-->
<!--  <span> entrepriseAccount : {{ entrepriseAccount }}</span>-->
<!--  <span> entrepriseName : {{ entrepriseName }}</span>-->
<!--  <span> projectbalanceforsign : {{ projectbalanceforsign }}</span>-->
<!--  <span> userlist : {{ userlist }}</span>-->
<!--  <span> entrepriseMembers: {{ entrepriseMembers }}</span>-->
<!--  <span> entrepriseMembersAddresses : {{ entrepriseMembersAddresses }}</span>-->
<!--  <span> contributorsforsign : {{ contributorsforsign }}</span>-->
<!--  <span> project : {{ project }}</span>-->



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
    const username = ''
    const projectName = ''
    const created = false
    const contributorsforsign: any[] = []
    const projectbalanceforsign = 0
    const project = null
    const entrepriseAccount = null
    const entrepriseName = ''
    const userlist : any[] = []
    const entrepriseMembers: any[] = []
    const entrepriseMembersAddresses : any[] = []
    const link = ''
    return { account, username,link,projectName,project,created,contributorsforsign,entrepriseAccount,entrepriseName,projectbalanceforsign,userlist,entrepriseMembers,entrepriseMembersAddresses}
  },
  methods: {
    goToEntreprise() {
      this.$router.push({ name: 'Entreprise' })
    },
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async updateEntrepriseAccount(){
      const { address, contract } = this
      this.project = await contract.methods.entreprises(address).call()
    },
    async updateProject(){
      const { address, projectName ,contract } = this
      const n = projectName.trim().replace(/ /g, '_')
      this.project = await contract.methods.project(n).call()
    },
    async signUp() {
      const { contract, username } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name).send()
      await this.updateAccount()
      this.username = name
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
    async projectSignUP(){
      const {contract,projectName,projectbalanceforsign,contributorsforsign,link} = this
      const Pname = projectName.trim().replace(/ /g, '_')
      await contract.methods.projectSignUP(Pname,contributorsforsign,projectbalanceforsign,link).send()
      // this.project = await contract.methods.project(Pname);
      await this.updateProject()
      this.created = false;
    }
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    const userlistaddress =  await contract.methods.allusers().call()
    for (const Addresse of userlistaddress) {
      const useraccount = await contract.methods.user(Addresse).call()
      this.userlist.push(useraccount)
    }

    const entrepriseAccount = await contract.methods.entreprise(address).call()
    if (account.registered) this.account = account
    if (entrepriseAccount.registered) {
      this.entrepriseAccount = entrepriseAccount
      const entrepriseMembersAddresses = await contract.methods.member(entrepriseAccount.name).call()
      this.entrepriseMembersAddresses = entrepriseMembersAddresses
      this.entrepriseMembers = []
      for (const memberAdresse of entrepriseMembersAddresses) {
        const account = await contract.methods.user(memberAdresse).call()
        this.entrepriseMembers.push(account)
      }
    }
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
