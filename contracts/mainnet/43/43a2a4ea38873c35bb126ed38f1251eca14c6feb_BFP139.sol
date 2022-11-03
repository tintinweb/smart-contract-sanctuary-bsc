/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
 
interface IInvite {
    // function addRecord(address) external returns(bool);
    function getParents(address) external view returns(address[7] memory);
    function getChilds(address) external view returns(address[] memory);
    function getInviteNum(address) external view returns(uint256[3] memory);
    
}
 
 
contract BFP139 is IInvite {
    address public factory; 
    address public Platform; 
    mapping(address => address[]) public inviteRecords; 
    mapping(address => address[]) public existingAddress; 
    mapping(address => mapping(address=>bool)) public isExistingAddress; 
    mapping(address => uint256[]) public existingAmount; 
    // mapping(uint256 => address) public rank; 
    mapping(address => bool) public isRank;
    mapping(address => uint256[]) public rankNum; 
    mapping(address => address) public parents; 
    // mapping(address => bool) public parents; 
    mapping(address => uint256[3]) public inviteNumRecords; 
    address public firstAddress; 
    uint256 public totalPeople;
    uint256 public payNum;
    address[] public rank;
    address public rewardsAddress;
    bool public isHaveReward;
    constructor() {
        factory = msg.sender; 
        firstAddress = 0x781E9995CbAC038d3C7cDbad076647641DeaAaBD; 
        Platform = 0x21b0B9053DA81F00C2A7264B52c10B1118041E4E;
        // inviteRecords = inviteRecords_new;
    }
    fallback() external payable {
   
    }
  
    receive() external payable {

    }
    
    function blind(address  parentAddress,address  sonAddress) public{
        require(parentAddress != address(0), 'Invite: 0001'); 
        // require(msg.value != address(0), 'Invite: 0001'); 
        address myAddress = sonAddress; 
        require(parentAddress != myAddress, 'Invite: 0002');

        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, 'Invite: 0003');

        inviteRecords[parentAddress].push(myAddress);

        parents[myAddress] = parentAddress;

        inviteNumRecords[parentAddress][0]++;
        inviteNumRecords[parents[parentAddress]][1]++; 
        inviteNumRecords[parents[parents[parentAddress]]][2]++; 
        inviteNumRecords[parents[parents[parents[parentAddress]]]][2]++; 
        inviteNumRecords[parents[parents[parents[parents[parentAddress]]]]][2]++; 
        inviteNumRecords[parents[parents[parents[parents[parents[parentAddress]]]]]][2]++; 
        address sixAddress = parents[parents[parents[parents[parents[parentAddress]]]]];
        inviteNumRecords[sixAddress][2]++; 
        totalPeople++; 
        
    }

    function setIsRank(address[] memory rankArr) public {
          require(msg.sender == factory, 'Invite: Only the contract publisher can call'); 
        for (uint256 i = 0; i < rankArr.length-1; i++) {
            isRank[rankArr[i]] = true;
            rankNum[rankArr[i]].push(i);
        }
        payNum = rankArr.length;

    }

    
    
    function setRank(address[] memory rankArr) public {
          require(msg.sender == factory, 'Invite: Only the contract publisher can call'); 
          rank = rankArr;
    }

     function transderToContract() payable public {
        payable(address(this)).transfer(msg.value);
    }

    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }


    function getParents(address myAddress) external view override returns(address[7] memory myParents){

        address firstParent = parents[myAddress];
        
        address secondParent;
        
        if(firstParent != address(0)){
            secondParent = parents[firstParent];
        }
       
        address threeParent;
        
        if(secondParent != address(0)){
            threeParent = parents[secondParent];
        }
       
        address fourParent;
        
        if(threeParent != address(0)){
            fourParent = parents[threeParent];
        }
        
        address fiveParent;
        
        if(fourParent != address(0)){
            fiveParent = parents[fourParent];
        }
       
        address sixParent;
        
        if(fiveParent != address(0)){
            sixParent = parents[fiveParent];
        }
        
        address sevenParent;
       
        if(sixParent != address(0)){
            sevenParent = parents[sixParent];
        }
      
        myParents = [firstParent, secondParent, threeParent, fourParent, fiveParent, sixParent, sevenParent];
    }

    function pay(address parentAddress) public payable {
        require(parentAddress != address(0), 'Invite: 0001'); 
        // require(msg.value != address(0), 'Invite: 0001'); 
        require(msg.value >=1390000000000000000, 'value is 0'); 
        emit Log(msg.value);
        address myAddress = msg.sender; 
        require(parentAddress != myAddress, 'Invite: 0002');
       
        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, 'Invite: 0003');
       
        inviteRecords[parentAddress].push(myAddress);
        
        parents[myAddress] = parentAddress;
        
        inviteNumRecords[parentAddress][0]++;
        inviteNumRecords[parents[parentAddress]][1]++;
        inviteNumRecords[parents[parents[parentAddress]]][2]++; 
        inviteNumRecords[parents[parents[parents[parentAddress]]]][2]++; 
        inviteNumRecords[parents[parents[parents[parents[parentAddress]]]]][2]++; 
        inviteNumRecords[parents[parents[parents[parents[parents[parentAddress]]]]]][2]++; 
        address sixAddress = parents[parents[parents[parents[parents[parentAddress]]]]];
        inviteNumRecords[sixAddress][2]++; 
        totalPeople++; 
        
        require(!isRank[msg.sender], 'Already in qualifying'); 
        
        // rank[totalPeople-1]=msg.sender;
        rank.push(msg.sender);
        rankNum[msg.sender].push(payNum);
        isRank[msg.sender] = true;

        address[7] memory myParents = this.getParents(msg.sender);
  
        if(myParents[0]!=address(0)&& !isExistingAddress[msg.sender][myParents[0]]){
            existingAddress[msg.sender].push(myParents[0]);
            isExistingAddress[msg.sender][myParents[0]]=true;
            existingAmount[msg.sender].push(500000000000000000);
            // existingAmount[msg.sender].push(50000000000000000);

        }
        if(myParents[1]!=address(0)&&!isExistingAddress[msg.sender][myParents[1]]){
            existingAddress[msg.sender].push(myParents[1]);
            isExistingAddress[msg.sender][myParents[1]]=true;
            existingAmount[msg.sender].push(200000000000000000);
            // existingAmount[msg.sender].push(20000000000000000);
        }
        uint256 length = myParents.length;
        for (uint256 i = 2; i < length; i++) {
            if(myParents[i] != address(0)){
                address[] memory currParents = this.getChilds(myParents[i]); 
                // require(myParents[0]==address(0), "No superior is bound")
                if(currParents.length>=2&&!isExistingAddress[msg.sender][myParents[i]]){
                    existingAddress[msg.sender].push(myParents[i]);
                    existingAmount[msg.sender].push(20000000000000000);
                    // existingAmount[msg.sender].push(2000000000000000);
                }
            }
        }
        uint256 lengths = existingAddress[msg.sender].length;
       
        for (uint256 i = 0; i < lengths; i++) {
            payable(existingAddress[msg.sender][i]).transfer(existingAmount[msg.sender][i]);
        }
       payable(Platform).transfer(70000000000000000);
    //    payable(Platform).transfer(7000000000000000);

        payNum++;
        
    }

    
    event Log(uint256);
 

      function payReply() public  payable {
          require(msg.sender == factory, 'Invite: Only the contract publisher can call'); 
        //   address[] memory newRank;
        address addressRank;
        // newRank = [firstAddress];
        // emit Log(newRank)
 
        // delete rank[0];
        

        address[7] memory myParents = this.getParents(rank[0]);
     
        rankNum[rank[0]].push(payNum);
       
        if(myParents[0]!=address(0)&& !isExistingAddress[rank[0]][myParents[0]]){
            existingAddress[rank[0]].push(myParents[0]);
            existingAmount[rank[0]].push(500000000000000000);
            // existingAmount[rank[0]].push(50000000000000000);
        }
        if(myParents[1]!=address(0) && !isExistingAddress[rank[0]][myParents[1]]){
            existingAddress[rank[0]].push(myParents[1]);
            existingAmount[rank[0]].push(200000000000000000);
            // existingAmount[rank[0]].push(20000000000000000);
        }
        uint256 length = myParents.length;
        for (uint256 i = 2; i < length; i++) {
            if(myParents[i] != address(0)){
                address[] memory currParents = this.getChilds(myParents[i]); 
                if(currParents.length>=2 && !isExistingAddress[rank[0]][myParents[i]]){
                    existingAddress[rank[0]].push(myParents[i]);
                    existingAmount[rank[0]].push(20000000000000000);
                    // existingAmount[rank[0]].push(2000000000000000);
                }
            }
        }
        uint256 lengths = existingAddress[rank[0]].length;
       payable(rank[0]).transfer(1210000000000000000);
    //    payable(rank[0]).transfer(121000000000000000);
       payable(Platform).transfer(70000000000000000);
    //    payable(Platform).transfer(7000000000000000);
        for (uint256 i = 0; i < lengths; i++) {
            payable(existingAddress[rank[0]][i]).transfer(existingAmount[rank[0]][i]);
        }
      
        isHaveReward = true;
        
        rewardsAddress=rank[0];
          
        payNum++;

        addressRank = rank[0];
         for (uint i = 0; i < rank.length-1; i++) {
            rank[i] = rank[i+1];
        //   newRank[i] = rank[i+1];
        }
        rank[rank.length -1] = addressRank;
        // newRank[newRank.length-1]=rank[0];
        // rank = newRank;

    }

 
      function getAddressRank(address myAddress) external view  returns(uint256 ranks){
        ranks = rankNum[myAddress][rankNum[myAddress].length - 1];
    }
 
      function getRewardAddressRank() external view  returns(uint256 ranks){
        ranks = rankNum[rewardsAddress][rankNum[rewardsAddress].length - 2];
    }
 
 
      function getLastAddressRank() external view  returns(uint256 ranks){
        ranks = rankNum[rank[rank.length-1]][rankNum[rank[rank.length-1]].length - 1];
    }
 

    function getChilds(address myAddress) external view override returns(address[] memory childs){
        childs = inviteRecords[myAddress];
    }
    // 
 
  
    function getInviteNum(address myAddress) external view override returns(uint256[3] memory){
 
        return inviteNumRecords[myAddress];
    }
  
    function transferTo(address payable accountAddress) external returns(bool){
        require(msg.sender == factory, 'Invite: Only the contract publisher can call'); 
        // rewardAmount[sender][3] = rewardAmount[sender][3] + actualBonusAmount;
        accountAddress.transfer(address(this).balance);
        return true;
    }
    
}