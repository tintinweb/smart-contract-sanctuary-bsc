//SPDX-License-Identifier: MIT
// contracts/ERC721.sol

pragma solidity >=0.6.2;


import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC721Enumerable.sol";


interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface Randomizer {
   function random() external view returns(uint32);
}

contract Freeper is ERC721Enumerable, Ownable {
    using SafeMath for uint;

    Randomizer public randomizerContract;

    uint constant ONE_MILLION = 10_000;
    // mapping(uint256 => Project) projects;

    mapping(address => bool) public isWhitelisted;

    uint public nextDomainId = 1;

    // constructor(address _randomizerContract) ERC721("Freeper", "FPE") {
    //   isWhitelisted[msg.sender] = true;
    //   randomizerContract = Randomizer(_randomizerContract);
    // }

    modifier onlyWhiteListed(){
        require(isWhitelisted[msg.sender],"only whitelisted");
        _;
    }

    struct Domain{
        string domain;
        address creator;
        bool isPublish;
        uint fans;
        uint avaliableFans;
        uint friends;
        string fansDesc;
        string friendsDesc;
    }

    struct Fans{
        uint domainId;
        address creator;
        string path;
        // address creator;
    }

    struct Friends{
        uint domainId;
        address creator;
        string path;
        // address creator;
    }

    mapping(string=>bool) registedDomain;    // check domain register
    mapping(uint=>Domain) public tokenIdToDomain;
    mapping(uint=>Fans) public tokenIdToFans;
    mapping(uint=>Friends) public tokenIdToFriends;
    mapping(uint=>string) tokenURIs;
    mapping(string=>uint) public domainToTokenId;


    struct User{
        string name;  // auto set when publish 150 and 1000
        bool isVerified;  // only can set by system
        uint domainId;
        mapping(string=>string) detail;
    }


    struct Ledger{
        uint domainId;

    }

    mapping(address=>User) public users;
    mapping(string=>bool) keys; 

    // mapping(uint=>domainId)

    // uint register_fee = 100 ether;
    
    struct Reward {
        uint total;
        mapping(uint => uint) fansReward;
        mapping(uint => uint) friendsReward;
    }

    mapping(uint => Reward) allRewards;

    // uint public totalDomain = 0;

    //event
    event RegistDomain(address indexed creator, uint indexed tokenId, string domain);
    event CreateFansNft(address indexed creator, uint indexed fansTokenId, uint indexed domainId);
    event CreateFriendsNft(address indexed creator, uint indexed friendsTokenId, uint indexed domainId);

    address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

    event TransferErc20(address indexed from, address indexed to, uint value);
    
    address [] whitelist;

    constructor() ERC721("Freeper", "FPE") {
        isWhitelisted[msg.sender] = true;
    //   randomizerContract = Randomizer(_randomizerContract);
        setBaseURI("https://source.freeper.io/nftdetail/");
    }


    // function addWhitelisted(address _address) public onlyOwner {
    //     isWhitelisted[_address] = true;
    // }

    // function removeWhitelisted(address _address) public onlyOwner {
    //     isWhitelisted[_address] = false;
    // }

    function addWhiteListed(address addr) public onlyOwner{
        require(isWhitelisted[addr] == false, "already in whitelist");
        isWhitelisted[addr] = true;
    }

    function removeWhiteList(address addr) public onlyOwner{
        require(isWhitelisted[addr] == true, "not in whitelist");
        isWhitelisted[addr] = false;
        uint i = 0;
        for(uint ii = 0 ;ii < whitelist.length ;ii++){
            if(whitelist[ii]==addr){
                i = ii;
                break;
            }
        }
        if (i >= whitelist.length) return;
        for (; i < whitelist.length - 1; i++){
            whitelist[i] = whitelist[i + 1];
        }
        whitelist.pop();
    }

    function showAllWhiteList() public view returns(address [] memory){
        return whitelist;
    }

    function getDomainName(uint id) public view returns(Domain memory){
        return tokenIdToDomain[id];
    }

    function getFansNft(uint id) public view returns(Fans memory){
        return tokenIdToFans[id];
    }

    function getFriendsNft(uint id) public view returns(Friends memory){
        return tokenIdToFriends[id];
    }

    function getUserName(address addr)public view returns(string memory){
        return users[addr].name;
    }

    function isVerifiedUser(address addr) public view returns(bool){
        return users[addr].isVerified;
    }

    function getPublishDomainId(address addr) public view returns (uint){
        return users[addr].domainId;
    }

    function setKeys(string memory key, bool flag) public onlyWhiteListed {
        keys[key]=flag;
    }


    function removeDomain()public onlyWhiteListed{
        users[msg.sender].domainId = 0;
    }

    function setDomainMint(uint tokenId, address owner, uint amount) public onlyWhiteListed{ 
        uint p = tokenId.div(10000).mul(10000);
        require(p == tokenId,"invalid tokenId");
        require(tokenId != 0 ,"tokenId can't be zero");
        require(users[owner].domainId == tokenId,"token not use");
        require(tokenIdToDomain[tokenId].avaliableFans <= 1000, "reach maximum fans token");
        if (tokenIdToDomain[tokenId].avaliableFans + amount >1000){
            tokenIdToDomain[tokenId].avaliableFans = 1000;
        }else{
            tokenIdToDomain[tokenId].avaliableFans = tokenIdToDomain[tokenId].avaliableFans.add(amount);
        }
    }

    function setUserDetail(string memory key, string memory value) public{
        require(bytes(key).length < 20,"key is too long");
        require(bytes(value).length <= 256,"value is too long");
        require(keys[key],"not support this key");
        users[msg.sender].detail[key]=value;
    }

    function setVerify(address addr, bool flag) public {
        users[addr].isVerified = flag;
    }

    function charCheck(bytes1 a) internal returns(bool){
        if ((a>=0x30 && a<=0x39)||(a>=0x40 && a<=0x5a)||(a>=0x61 && a<=0x7a)||a==0x5f){
            return true;
        }
        return false;
    }

    function strCheck(bytes memory str) internal returns(bool){
        uint len = str.length;
        for (uint i = 0 ;i < len ; i++){
            require(charCheck(str[i]),"string has invalid charactor");
        }
        return true;
    }

    //register domain
    function registerDomain(string memory domain, address owner) public onlyWhiteListed returns (uint) {
        domain = string(abi.encodePacked(domain,".free"));
        require(registedDomain[domain] == false,"domain is exist");
        registedDomain[domain]=true;
        uint tokenId = nextDomainId.mul(ONE_MILLION);
        tokenIdToDomain[tokenId].domain = domain;
        tokenIdToDomain[tokenId].creator = owner;
        tokenIdToDomain[tokenId].avaliableFans = 50;
        domainToTokenId[domain] = tokenId;
        _mint(owner,tokenId);
        emit RegistDomain(owner,tokenId, domain);
        nextDomainId = nextDomainId.add(1);
        return tokenId;

    }

    function checkInternal(uint tokenId) internal {
        uint p = tokenId.div(10000).mul(10000);
        require(p == tokenId,"invalid tokenId");
        require(users[msg.sender].isVerified,"account is not verify");
        require(users[msg.sender].domainId == 0 || users[msg.sender].domainId == tokenId, "this address has  already created nft");
        address addr = ownerOf(tokenId);
        require(msg.sender == addr,"domain not yours");
        if(users[msg.sender].domainId == 0){
            users[msg.sender].name = tokenIdToDomain[tokenId].domain;
            users[msg.sender].domainId = tokenId;
        }
    }

    function mintFriends(uint amount, uint tokenId)public{
        checkInternal(tokenId);
        require(150 - tokenIdToDomain[tokenId].friends >= amount,"amount is too high");
        lockToken(msg.sender, tokenId);
        for(uint i = tokenIdToDomain[tokenId].friends ; i < tokenIdToDomain[tokenId].friends + amount ; i++){
            uint id = tokenId.add(i).add(1000);

            tokenIdToFriends[id].domainId = tokenId;
            tokenIdToFriends[id].creator = msg.sender;
            _mint(msg.sender,id);
            if (i == 0){
                lockToken(msg.sender, id);
            }
        }
        tokenIdToDomain[tokenId].friends = tokenIdToDomain[tokenId].friends.add(amount);

    }

    function setFanDescription(uint tokenId, string memory description) public {
        require(tokenIdToDomain[tokenId].creator == msg.sender,"invalid tokenId");
        tokenIdToDomain[tokenId].fansDesc = description;
        
    }

    function setFriendDescription(uint tokenId, string memory description) public {
        require(tokenIdToDomain[tokenId].creator == msg.sender,"invalid tokenId");
        tokenIdToDomain[tokenId].friendsDesc = description;
    }



    function mintFans(uint amount,uint tokenId)public{
        checkInternal(tokenId);
        uint max = 1000;
        require(max.sub(tokenIdToDomain[tokenId].fans) >= amount,"amount is too high");
        require(tokenIdToDomain[tokenId].fans.add(amount) < tokenIdToDomain[tokenId].avaliableFans,"please try to finish more quests, unlock more token");
        // if 
        lockToken(msg.sender, tokenId);
        for(uint i = tokenIdToDomain[tokenId].fans ;i < tokenIdToDomain[tokenId].fans + amount ;i++){
            uint id = tokenId.add(i).add(3000);

            tokenIdToFans[id].domainId = tokenId;
            tokenIdToFans[id].creator = msg.sender;
            _mint(msg.sender, id);
             if (i == 0){
                lockToken(msg.sender, id);
            }
        }
        tokenIdToDomain[tokenId].fans = tokenIdToDomain[tokenId].fans.add(amount);
    }

    function getTokenIdCreator(uint tokenId) public view returns(address){
        if(tokenIdToDomain[tokenId].creator !=address(0)){
            return tokenIdToDomain[tokenId].creator;
        }
        if(tokenIdToFriends[tokenId].creator != address(0)){
            return tokenIdToFriends[tokenId].creator;
        }
        if(tokenIdToFans[tokenId].creator != address(0)){
            return tokenIdToFans[tokenId].creator;
        }
        return address(0);
    }


    function insert(uint tokenId, uint amount) onlyWhiteListed public {
        ownerOf(tokenId);
        allRewards[tokenId].total = allRewards[tokenId].total.add(amount);
    }

    function getReward(uint domainId, uint [] memory nftId) public{
        uint total = 0;
        for (uint i = 0 ;i < nftId.length ; i++){
            if(ownerOf(nftId[i])==msg.sender){
                if (nftId[i].sub(domainId).sub(1000) >=2000){ // fans
                    uint amount = allRewards[domainId].total.mul(400).div(1000).div(1000);
                    total = total.add(amount.sub(allRewards[domainId].fansReward[nftId[i]]));
                    allRewards[domainId].fansReward[nftId[i]] = amount;
                }else{ //friends
                    uint amount = allRewards[domainId].total.mul(300).div(1000).div(150);
                    total = total.add(amount.sub(allRewards[domainId].friendsReward[nftId[i]]));
                    allRewards[domainId].friendsReward[nftId[i]] = amount;
                }
            }
        }
        IERC20(usdtAddress).transfer(msg.sender, total);
    }

    function checkReward(uint domainId, uint [] memory nftId) public view returns(uint){
        uint total = 0;
        for (uint i = 0 ; i < nftId.length ; i++){
            if (nftId[i].sub(domainId).sub(1000) >=2000){ // fans
                uint amount = allRewards[domainId].total.mul(400).div(1000).div(1000);
                total = total + amount - allRewards[domainId].fansReward[nftId[i]];
            }else{ //friends
                uint amount = allRewards[domainId].total.mul(300).div(1000).div(150);
                total = total + amount - allRewards[domainId].friendsReward[nftId[i]];
            }
        }
        return total;
    }
}