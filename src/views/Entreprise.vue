<template lang="html">
  <div class="home" v-if="!entrepriseAccount">
    <form>
      <card
        title="Enter EntrepriseAccount name "
      >
        <input
          type="text"
          class="input-username"
          v-model="entrepriseName"
          placeholder="Type your EntrepriseName here"
        />
      </card>
      <spacer :size="24" />
      <card title="Choose one or multiple members ">
        <div v-for="items in userlist" v-bind:key="items.adr" class="input-username">
          <input type="checkbox"  :id= "items.adr" :value="items.adr" v-model="entrepriseMembersforSign" >
          <label>{{items.username}}</label>
        </div>
<!--        <span>entrepriseMembersforSign: {{ entrepriseMembersforSign }}</span>-->
<!--        <span>userlist: {{ userlist }}</span>-->
<!--        <span>entrepriseName: {{ entrepriseName }}</span>-->
      </card>
    </form>
    <spacer :size="24" />
    <card title="Create your Entreprise Account"  :blue="true">
      <collective-button :transparent="true" @click="EntrepriseSignUP">
        Create!
      </collective-button>
    </card>
  </div>


  <div class="home" v-else>
    <div class="card-home-wrapper">
      <card
        :title="'Entreprise Account'"
        :gradient="true"
      >
        <div class="explanations">
          <p><b>Name of Entreprise: </b>{{ entrepriseAccount.name }}</p>
          <p><b>Owner: </b>{{ entrepriseAccount.owner.username }}</p>
          <p><b>Members: </b></p>

            <span
                v-for="member in entrepriseMembers"
                v-bind:key="member.adr"
            >
            <p>{{ member.username }} -> {{ member.adr }}</p>
          </span>
          <p><b>Balance: </b>{{ entrepriseAccount.balance }} Tokens</p>
<!--        <span>entrepriseMembers: {{ entrepriseMembers }}</span>-->
<!--          <span>entrepriseMembersAddresses: {{ entrepriseMembersAddresses }}</span>-->
<!--          <p><b>entrepriseAccount: </b>{{ entrepriseAccount}}</p>-->
        </div>
      </card>
      <spacer :size="24" />
      <form @submit.prevent="addBalanceToEntreprise">
        <card
            title="Add tokens for your Entreprise Account"
            subtitle="After Addition  please F5"
        >
          <input
              type="number"
              class="input-username"
              v-model="entreprisebalance"
              placeholder="Type your tokens here"
          />
        </card>
      </form>
    </div>
    <spacer :size="24" />
    <div class="explanations">
      <card title="Create a Project"  :blue="true">
        <collective-button :transparent="true" @click="goToProject">
          Go to Create!
        </collective-button>
      </card>
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
      this.entrepriseAccount = await contract.methods.entreprise(address).call()

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

</style>
