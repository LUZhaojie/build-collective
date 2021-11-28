<template lang="html">
  <div class="home" v-if="!project">
    <form @submit.prevent="searchProject">
      <card
          title="Enter Project name"
      >
        <input
            type="text"
            class="input-username"
            v-model="projectName"
            placeholder="Type your ProjectName here"
        />
      </card>
      <spacer :size="24" />
    </form>
    <div class="home">
      <card
          v-for="proj in projectlist"
          :key= proj.name
          :title= proj.name
      >
      </card>
    </div>
  </div>

  <div class="home" v-else>
      <card
          title="Project"
          :blue="true"
      >
      <div class="explanations">
        <p><b>Project Name: </b>{{ project.name }}</p>
        <p><b>Balance: </b>{{ project.balance }}</p>
        <p><b>Owner: </b> {{ ownername }}</p>
        <p><b>Link: </b> {{ project.link }}</p>
        <p><b>Contributors: </b></p>
        <span
            v-for="cons in contributors"
            v-bind:key="cons.adr"
        >
            <p>{{ cons.username }} -> {{ cons.adr }}</p>
          </span>


      </div>
      </card>
    <spacer :size="24" />
    <div class="operation" v-if="ismember">
    <form >
      <card
          title="Enter the amount you want to give (only owner can use it)"
      >
        <spacer :size="24" />
        <span class="input-username">Enter the amount you want to give</span>
        <input
            type="number"
            class="input-username"
            v-model="projectbalanceforgiven"
            placeholder="Enter the amount you want to give"
        />
        <span class="input-username">Choose one member</span>
        <select v-model="received" class="input-username" style="color: grey">
          <option disabled value= null>choose</option>
          <option v-for="user in contributors"  :value="user.adr" v-bind:key= "user.adr">
            {{ user.username }}
          </option>
        </select>
        <collective-button  @click="given">
          Go transaction!
        </collective-button>
      </card>
    </form>
    <spacer :size="24" />
    <card title="list of bounties"  :blue="true">
      <form>
      <select v-model="issue" class="input-username" style="color: grey">
        <option disabled value= null >choose</option>
        <option v-for="iss in listissue"  :value="iss" v-bind:key= "iss">
          {{ iss.name }}
        </option>
      </select>
      </form>
      <collective-button :transparent="true" @click="goToIssue">
        Go !
      </collective-button>
    </card>
    <spacer :size="24" />
    <card title="Create a bounties"  :blue="true">
      <collective-button :transparent="true" @click="goToCreateIssue">
        Go Create!
      </collective-button>
    </card>

    <spacer :size="24" />
    <card title="Log page"  :blue="true">
      <collective-button :transparent="true" @click="goToLog">
        View log!
      </collective-button>
    </card>
    </div>

    <div class="operation" v-else>
      <p><b>You are not contributor of this project</b></p>
    </div>
  </div>



<!--&lt;!&ndash;  </div>&ndash;&gt;-->
<!--  <span> address : {{ address }}</span>-->
<!--  <span> projectName : {{ projectName }}</span>-->
<!--  <span> account : {{ account }}</span>-->
<!--  <span> userlist : {{ userlist }}</span>-->
<!--  <span> contributors : {{ contributors }}</span>-->
<!--  <span> project : {{ project }}</span>-->
<!--  <span> powner : {{ powner }}</span>-->
<!--&lt;!&ndash;  <span> received : {{ received }}</span>&ndash;&gt;-->
<!--  <span> received : {{ received }}</span>-->
<!--  <span> isowner : {{ isowner }}</span>-->
<!--  <span> projectbalanceforgiven : {{ projectbalanceforgiven }}</span>-->
<!--  <span> listissue : {{ listissue }}</span>-->
<!--  <span> issue : {{ issue }}</span>-->
<!--  <span> ismember : {{ ismember }}</span>-->
<!--  <span> contributors : {{ contributors }}</span>-->


</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  components: { Card,Spacer,CollectiveButton},
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
    const contributors: any[] = []
    const projectbalanceforgiven = 0
    const received = null
    const project = null
    const userlist : any[] = []
    const powner = null
    const ownername = ''
    const projectlist : any[] = []
    const isowner = false
    const listissue : any[] = []
    const issue = null
    const ismember = false
    return { account, username,ismember,contributors,projectName,project,listissue,issue,projectbalanceforgiven,received,userlist,powner,ownername,projectlist,isowner}
  },
  methods: {
    goToEntreprise() {
      this.$router.push({ name: 'Entreprise' })
    },
    goToCreateIssue() {
      const { projectName } = this
      this.$router.push({ name: 'Issue',query: {projectName: projectName } })
    },
    goToIssue() {
      const { issue } = this
      this.$router.push({ name: 'Issueview',query: {issue: issue } })
    },
    goToLog() {
      const { projectName } = this
      this.$router.push({ name: 'Projectlog',query: {projectName: projectName } })
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
      const { projectName,contract} = this
      const proj = await contract.methods.project(projectName).call()
      this.project = proj
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
    async searchProject() {
      const { contract,projectName,address } = this
      const proj = await contract.methods.project(projectName).call()
      this.project = proj

      for (const addr of proj.contributors){
        const a = addr.toLowerCase();
        if( a.match(address.toString()) != null){
          this.ismember = true;
        }
        const usercontributor = await contract.methods.user(addr).call()
        this.contributors.push(usercontributor)
      }
      const po = await contract.methods.user(proj.owner).call()
      this.powner = po
      this.ownername = po.username
      const li  = await contract.methods.issue(proj.id).call()
      for (const lis of li){
        if (lis.issue_fixed == false){
          this.listissue.push(lis)
        }
      }


    },
    async given() {
      const { contract,projectName, projectbalanceforgiven,received} = this
      await contract.methods.giveToken(projectName,received,projectbalanceforgiven).send()
      await this.updateProject()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    this.account = account
    const userlistaddress =  await contract.methods.allusers().call()
    for (const Addresse of userlistaddress) {
      const useraccount = await contract.methods.user(Addresse).call()
      this.userlist.push(useraccount)
    }

    const plist = await contract.methods.allprojects().call()
    for (const proj of plist) {
      this.projectlist.push(proj)
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