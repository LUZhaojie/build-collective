<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="signUp">
      <card
        title="Enter your username here"
        subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="Type your username here"
        />
      </card>
    </form>
  </div>
  <div class="home" v-if="account">
    <div class="card-home-wrapper">
      <card
        :title="account.username"
        :subtitle="`Balance: ${balance} ETH  \t\t Tokens: ${account.balance}  \t\t Address: ${account.adr} `"
        :gradient="true"
      >

        <div class="explanations">

          On your account on the contract, you have
          {{ account.balance }} tokens. If you click
          <button class="button-link" @click="addTokens">here</button>, you can
          add 200 token to your account. <p>If you want create a project with tokens, you need to have enough tokens in your account.</p>
        </div>
      </card>
      <spacer :size="24" />
      <div class="explanations" v-if="!entrepriseAccount">
      <card title="Create a Entreprise Account"  :blue="true">
        <collective-button :transparent="true" @click="goToEntreprise">
          Go to Create!
        </collective-button>
      </card>
      </div>

      <div class="explanations">
        <card title="Create a Project"  :blue="true">
          <collective-button :transparent="true" @click="goToProject">
            Go to Create!
          </collective-button>
        </card>
      </div>

      <div class="explanations" v-if="entrepriseAccount">
        <card title="Go your Entreprise Account"  :blue="true">
          <collective-button :transparent="true" @click="goToEntreprise">
            Go to Entreprise Account!
          </collective-button>
        </card>
      </div>
    </div>
  </div>
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
    const entrepriseAccount = null
    const entrepriseName = ''
    const entreprisebalance = 0
    const userlist : any[] = []
    const entrepriseMembers: any[] = []
    const entrepriseMembersAddresses : any[] = []
    const entrepriseMembersforSign : any[] = []
    return { account, username, entrepriseAccount,entrepriseName,entreprisebalance,userlist,entrepriseMembers,entrepriseMembersAddresses,entrepriseMembersforSign}
  },
  methods: {
    goToEntreprise() {
      this.$router.push({ name: 'Entreprise' })
    },
    goToProject() {
      this.$router.push({ name: 'Project' })
    },
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async updateEntrepriseAccount(){
      const { address, contract } = this
      this.entrepriseAccount = await contract.methods.entreprises(address).call()

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
    async EntrepriseSignUP(){
      const {contract, entrepriseName,entrepriseMembersforSign} = this
      const name = entrepriseName.trim().replace(/ /g, '_')
      await contract.methods.entrepriseSignUP(name,entrepriseMembersforSign).send()
      await this.updateEntrepriseAccount()
      await this.goToEntreprise()
    },
    async addBalanceToEntreprise(){
      const {contract,entreprisebalance} = this
      await contract.methods.addBalanceToEntreprise(entreprisebalance).send()
      await this.updateEntrepriseAccount()
      await this.goToEntreprise()
    },
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
.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}

</style>
