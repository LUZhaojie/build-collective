pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

 //user   Une adresse peut créer un user
 //entreprise   Un user ne peut créer qu'une seule entreprise
 //project   Peut être créé à partir de l'interface user ou de l'entreprise Le nom du projet ne peut pas être répété
contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    address adr;
    bool registered;
  }

  struct Entreprise{
    string name;
    User owner;
    address[] members;
    uint256 balance;
    bool registered;
  }

  struct Project{
    uint256 id;
    string name;
    address[] contributors;
    uint256 balance;
    address owner;
    string link;
    bool registered;
  }

  uint256 internal Id;

  struct Issue{
    string projectname;
    string name;
    string contenu;
    address owner;
    uint256 reward;
    bool issue_fixed;
  }

  struct Event{
     uint time;
     string contenu;
  }



  address[] public userlist;

  Project[] public projectlist;


  mapping(string => Project) private projects;

  mapping(address => User) private users;

  mapping(address => Entreprise) private entreprises;

  mapping(string => address[]) private members;

  mapping(uint => Issue[]) private issues;

  mapping(uint => Event[]) private events;



  event UserSignedUp(address indexed userAddress, User indexed user);

  event EntrepriseSignedUp(address indexed ownerAddress, Entreprise indexed entreprise);

  //event ProjectSignedUp(uint256 indexed idProject, Project indexed project);

  //event IssueSignedUp(address indexed ownerAddress, Issue indexed issue);


  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal returns (string memory){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
  }

  function strConcat(string memory _a, string memory _b) internal returns (string memory) {
    return strConcat(_a, _b, "", "", "");
  }


//user
  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function allusers() public view returns (address[] memory){
    return userlist;
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0,msg.sender,true);
    userlist.push(msg.sender);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return users[msg.sender];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

//entreprise
  function entreprise(address ownerAddress) public view returns(Entreprise memory){
    return entreprises[ownerAddress];
  }

  function member(string memory name) public view returns (address[] memory){
    return members[name];
  }

  function entrepriseSignUP(string memory name,address[] memory Emembers) public returns (Entreprise memory){
    require(bytes(name).length > 0);
    require(users[msg.sender].registered);
    entreprises[msg.sender] = Entreprise(name,users[msg.sender],Emembers,0, true);
    members[name] = Emembers;
    emit EntrepriseSignedUp(msg.sender,entreprises[msg.sender]);
    return entreprises[msg.sender];
  }


  function addBalanceToEntreprise(uint256 amount) public returns (bool) {
    require(entreprises[msg.sender].registered);
    entreprises[msg.sender].balance += amount;
    return true;
  }

  //project
  function project(string memory name) public view returns (Project memory){
    return projects[name];
  }

    function allprojects() public view returns (Project[] memory){
      return projectlist;
    }

  function projectSignUP(string memory name,address[] memory contributors,uint256 amount,string memory link) public returns (Project memory){
    require(bytes(name).length > 0);
    require(users[msg.sender].registered);
    require(!projects[name].registered);
    require(users[msg.sender].balance >= amount);
    Id ++;

    users[msg.sender].balance -= amount;
    projects[name] = Project(Id,name,contributors,amount,msg.sender,link,true);
    projectlist.push(projects[name]);
    events[Id].push(Event(now,strConcat("Project created :",name)));
    return projects[name];
  }

  function giveToken(string memory name,address adr,uint256 amount) public returns (bool){
    require(projects[name].registered);
    require(users[adr].registered);
    require(projects[name].balance >= amount);
    require(projects[name].owner == msg.sender);
    projects[name].balance -= amount;
    users[adr].balance += amount;

    string memory str = strConcat("Transaction :  from ",name);
    string memory str2 = strConcat(str," to ");
    string memory str3 = strConcat(str2,users[adr].username);
    events[projects[name].id].push(Event(now,str3));

    return true;
  }

  //issue

    function isEqual(string memory a, string memory b) internal returns (bool) {
            if (bytes(a).length != bytes(b).length) {
                return false;
            }
            for (uint i = 0; i < bytes(a).length; i ++) {
                if(bytes(a)[i] != bytes(b)[i]) {
                    return false;
                }
            }
            return true;
        }

    function issue(uint256 id) public view returns (Issue[] memory){
      return issues[id];
    }


  function issueSignUP (string memory projectname,string memory name,string memory contenu,uint256 reward) public returns (Issue memory){
    require(bytes(projectname).length > 0);
    require(bytes(name).length > 0);
    require(bytes(contenu).length > 0);
    require(users[msg.sender].registered);
    require(users[msg.sender].balance >= reward);
    require(projects[projectname].registered);

    for(uint i = 0; i < issues[projects[projectname].id].length ; i++){
      string memory str = issues[projects[projectname].id][i].name;
      require(!isEqual(name,str));
    }

    users[msg.sender].balance -= reward;
    projects[projectname].balance += reward;
    Issue memory tache = Issue(projectname,name,contenu,msg.sender,reward,false);
    issues[projects[projectname].id].push(tache);

    string memory str = strConcat("Bounty Task created by ",users[msg.sender].username);
    string memory str2 = strConcat(str," : ");
    string memory str3 = strConcat(str2,name);
    events[projects[projectname].id].push(Event(now,str3));
    return tache;
  }

  function fix(string memory projectname,string memory name) public returns (bool){
    require(bytes(projectname).length > 0);
    require(bytes(name).length > 0);
    require(users[msg.sender].registered);
    require(projects[projectname].registered);

    for(uint i = 0; i < issues[projects[projectname].id].length ; i++){
      string memory str = issues[projects[projectname].id][i].name;
      if(isEqual(name,str)){
        uint reward = issues[projects[projectname].id][i].reward;
        require(projects[projectname].balance >= reward);
        projects[projectname].balance -= reward;
        users[msg.sender].balance += reward;
        issues[projects[projectname].id][i].issue_fixed = true;

        string memory str1 = strConcat("Bounty Task ",issues[projects[projectname].id][i].name);
        string memory str2 = strConcat(str1," : fixed by ");
        string memory str3 = strConcat(str2,users[msg.sender].username);
        events[projects[projectname].id].push(Event(now,str3));
        return true;
      }
    }
    return false;
  }

  //events
  function eventlist (uint256 id) public view returns (Event[] memory){
    return events[id];
  }


}
