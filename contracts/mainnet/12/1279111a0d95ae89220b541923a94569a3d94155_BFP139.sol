/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity >=0.8.0;

interface IInvite {
    function getParents(address) external view returns(address[6] memory);
    function getChilds(address) external view returns(address[] memory);
    function getInviteNum(address) external view returns(uint256[3] memory);
}
 
contract BFP139 is IInvite {
    address public factory; 
    address public Platform;
    address public reInvestmentCollectionaddress;
    mapping(address => bool) public whiteList;
    mapping(address => bool) public revoteWhiteList;
    mapping(address => uint256) public remainNumberRerolls;
    mapping(address => address[]) public inviteRecords;
    mapping(address => address[]) public existingAddress;
    mapping(address => mapping(address=>bool)) public isExistingAddress;
    mapping(address => uint256[]) public existingAmount;
    mapping(address => bool) public isRank;
    mapping(address => uint256[]) public rankNum;
    mapping(address => address) public parents;
    mapping(address => uint256[3]) public inviteNumRecords;
    address public firstAddress;
    uint256 public totalPeople;
    uint256 public payNum;
    address[] public rank;
    address public rewardsAddress;
    bool public isHaveReward;

    modifier onlyOwner(){
        require(msg.sender == factory,'Invite: Only the contract publisher can call');
        _;
    }
    
    constructor() {
        factory = msg.sender;
        firstAddress = 0x781E9995CbAC038d3C7cDbad076647641DeaAaBD;
        Platform = 0x21b0B9053DA81F00C2A7264B52c10B1118041E4E;
        reInvestmentCollectionaddress = 0x71d377CB595F9cd8C97e58Bf32790D491Ef056D8;
    }
    fallback() external payable {
   
    }
  
    receive() external payable {

    }

    function blind(address  parentAddress,address  sonAddress) public onlyOwner{
        require(parentAddress != address(0), 'Invite: 0001');
        // require(msg.value != address(0), 'Invite: 0001');
        address myAddress = sonAddress;
        require(parentAddress != myAddress, 'Invite: 0002');
        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, 'Invite: 0003');
        inviteRecords[parentAddress].push(myAddress);
        parents[myAddress] = parentAddress;
        remainNumberRerolls[myAddress]+=5;
        address markAddress = parentAddress;
        uint256 directPushesNumber1 = inviteNumRecords[markAddress][0] + 1;
        updateAddressData(markAddress,0,directPushesNumber1);

        markAddress = parents[markAddress];
        uint256 directPushesNumber2 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber3 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber4 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber5 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber5 + directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber6 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber6 + directPushesNumber5 + directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        totalPeople++;
    }

    function updateAddressData(address markAddress_th,uint inviteNumRecords_subscript,uint256 directPushesNumber) private {
        inviteNumRecords[markAddress_th][inviteNumRecords_subscript]++;
        remainNumberRerolls[markAddress_th]+=5;

        if(!revoteWhiteList[markAddress_th]){
            if(directPushesNumber >= 5){
                 revoteWhiteList[markAddress_th] = true;
            }
        }
    }

    function setIsRank(address[] memory rankArr) public onlyOwner{
        for (uint256 i = 0; i < rankArr.length-1; i++) {
            isRank[rankArr[i]] = true;
            rankNum[rankArr[i]].push(i);
        }
        payNum = rankArr.length;

    }

    
    
    function setRank(address[] memory rankArr) public onlyOwner{
          rank = rankArr;
    }
     function transderToContract() payable public {
        payable(address(this)).transfer(msg.value);
    }
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }

    function getParents(address myAddress) external view override returns(address[6] memory myParents){
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
        myParents = [firstParent, secondParent, threeParent, fourParent, fiveParent, sixParent];
    }


    function pay(address parentAddress) public payable {
        require(msg.value >= 1390000000000000000, 'Invite: 0001');

        address myAddress = msg.sender;

        require(!isRank[myAddress], 'Already in qualifying'); 

        require(parentAddress != address(0), 'Invite: 0001');
        require(parentAddress != myAddress, 'Invite: 0002');
        require(parents[parentAddress] != address(0) || parentAddress == firstAddress, 'Invite: 0003');
        inviteRecords[parentAddress].push(myAddress);
        parents[myAddress] = parentAddress;

        remainNumberRerolls[myAddress]+=5;

        address markAddress = parentAddress;
        uint256 directPushesNumber1 = inviteNumRecords[markAddress][0] + 1;
        updateAddressData(markAddress,0,directPushesNumber1);

        markAddress = parents[markAddress];
        uint256 directPushesNumber2 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber3 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber4 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber5 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber5 + directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);
        
        markAddress = parents[markAddress];
        uint256 directPushesNumber6 = inviteNumRecords[markAddress][0];
        updateAddressData(markAddress,2,directPushesNumber6 + directPushesNumber5 + directPushesNumber4 + directPushesNumber3 + directPushesNumber2 + directPushesNumber1);

        totalPeople++;

        rank.push(myAddress);
        rankNum[myAddress].push(payNum);
        isRank[myAddress] = true;
    
        rewardDistribution(myAddress);
        payNum++;
    }




    
    event Log(uint256);
    event Log(bool);
 
      function payReply() public  payable onlyOwner{
        address addressRank;
        rankNum[rank[0]].push(payNum);

        if(whiteList[rank[0]] || revoteWhiteList[rank[0]] || remainNumberRerolls[rank[0]] > 0){
            payable(rank[0]).transfer(290000000000000000);
            if(remainNumberRerolls[rank[0]] > 0){
                remainNumberRerolls[rank[0]]--;
            }
            rewardDistribution(rank[0]);
        }else {
            payable(reInvestmentCollectionaddress).transfer(77000000000000000);
            payable(Platform).transfer(70000000000000000);
        }

        isHaveReward = true;
        rewardsAddress=rank[0];  
        payNum++;
        addressRank = rank[0];
         for (uint i = 0; i < rank.length-1; i++) {
            rank[i] = rank[i+1];
        }
        rank[rank.length -1] = addressRank;

    }

    function rewardDistribution(address myAddress_th) private{
        address[6] memory myParents = this.getParents(myAddress_th);
        if(myParents[0]!=address(0)&& !isExistingAddress[myAddress_th][myParents[0]]){
            existingAddress[myAddress_th].push(myParents[0]);
            isExistingAddress[myAddress_th][myParents[0]]=true;
            existingAmount[myAddress_th].push(300000000000000000);

        }
        if(myParents[1]!=address(0)&&!isExistingAddress[myAddress_th][myParents[1]]){
            existingAddress[myAddress_th].push(myParents[1]);
            isExistingAddress[myAddress_th][myParents[1]]=true;
            existingAmount[myAddress_th].push(100000000000000000);
        }
        uint256 length = myParents.length;
        for (uint256 i = 2; i < length; i++) {
            if(myParents[i] != address(0)){
                address[] memory currParents = this.getChilds(myParents[i]); 
                if(currParents.length>=2&&!isExistingAddress[myAddress_th][myParents[i]]){
                    existingAddress[myAddress_th].push(myParents[i]);
                    existingAmount[myAddress_th].push(20000000000000000);
                }
            }
        }
        uint256 lengths = existingAddress[myAddress_th].length;
       
        for (uint256 i = 0; i < lengths; i++) {
            payable(existingAddress[myAddress_th][i]).transfer(existingAmount[myAddress_th][i]);
        }
       payable(Platform).transfer(70000000000000000);
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

      function getAddressRemainNumber(address myAddress) external view returns(uint256 remainNumber){
        remainNumber = remainNumberRerolls[myAddress];
    }
    function getInviteNum(address myAddress) external view override returns(uint256[3] memory){
        return inviteNumRecords[myAddress];
    }
    function transferTo(address payable accountAddress) external onlyOwner returns(bool){
        accountAddress.transfer(address(this).balance);
        return true;
    }

    function batchAddWhiteList(address[] calldata whiteList_) external onlyOwner{
        for(uint256 i; i<whiteList_.length; i++){
            whiteList[whiteList_[i]] = true;
        }
    }

    function batchRmWhiteList(address[] calldata whiteList_) external onlyOwner{
        for(uint256 i; i<whiteList_.length; i++){
            delete whiteList[whiteList_[i]];
        }
    }
}