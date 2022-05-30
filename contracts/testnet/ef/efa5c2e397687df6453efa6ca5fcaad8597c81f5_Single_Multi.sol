/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burnbyContract(uint256 _amount) external;
    function withdrawStakingReward(address _address,uint256 _amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
}

contract Ownable {

    address public _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Single_Multi is Ownable{

    ////////////    Variables   ////////////

    using SafeMath for uint256;
    IERC721 NFT;
    IERC20 Token;

    ////////////    Structure   ////////////

    struct userInfo 
    {
        uint256 totlaWithdrawn;
        uint256 withdrawable;
        uint256 totalStaked;
        uint256 availableToWithdraw;
    }

    ////////////    Mapping   ////////////

    mapping(address => userInfo ) public User;
    mapping(address => mapping(uint256 => uint256)) public stakingTime;
    mapping(address => uint256[] ) public Tokenid;
    mapping(address => uint256) public totalStakedNft;
    mapping(uint256 => bool) public alreadyAwarded;
    mapping(address => mapping(uint256=>uint256)) public depositTime;

    uint256 time= 20 seconds;

    uint256 public common = 40;
    uint256 public rare = 10;
  

    uint256  trare = common + rare;


    ////////////    Constructor   ////////////

    constructor(IERC721 _NFTToken,IERC20 _token)  
    {
        NFT   =_NFTToken;
        Token=_token;
    }

    ////////////    Stake NFT'S to get reward in ROAD Coin   ////////////

    function Stake(uint256 tokenId) external {
    //    for(uint256 i=0;i<tokenId.length;i++){
       require(NFT.ownerOf(tokenId) == msg.sender,"Nft Not Found");
       NFT.transferFrom(msg.sender,address(this),tokenId);
       Tokenid[msg.sender].push(tokenId);
       stakingTime[msg.sender][tokenId]=block.timestamp;

       if(!alreadyAwarded[tokenId]){
       depositTime[msg.sender][tokenId]=block.timestamp;
       }
    // }

       User[msg.sender].totalStaked += 1;
       totalStakedNft[msg.sender] += 1;

    }

    ////////////    Reward Check Function   ////////////

    /*
        1) Passing address and TokenId to check reward of any user's Staked Id
    */

    function rewardOfUser(address Add, uint256 Tid) public view returns(uint256) {
        uint256 RewardToken;

        for(uint256 i = 0 ; i < Tokenid[Add].length ; i++){
           
            if(Tokenid[Add][i] == Tid && Tokenid[Add][i] >= 0 && Tokenid[Add][i] <= common )
            {
             RewardToken += (((block.timestamp - (stakingTime[Add][Tokenid[Add][i]])).div(time)))*10 ether;     
            }

            else if(Tokenid[Add][i] == Tid && Tokenid[Add][i] > common && Tokenid[Add][i] <= trare )
            {
             RewardToken += (((block.timestamp - (stakingTime[Add][Tokenid[Add][i]])).div(time)))*20 ether;     
            }
        }
        return RewardToken+User[Add].availableToWithdraw;
    }



    ////////////    Return All staked Nft's   ////////////
    
    function userStakedNFT(address _staker)public view returns(uint256[] memory) {
       return Tokenid[_staker];
    }

    ////////////    Withdraw-Reward   ////////////

    // Returns reward of all staled ids of a Caller

    function WithdrawReward()  public {
        uint256 reward;
        for(uint256 i; i< Tokenid[msg.sender].length;i++){
            // here it gets the reward of single id and stored in a veriable
            reward += rewardOfUser(msg.sender, Tokenid[msg.sender][i]);
            require(reward > 0,"you don't have reward yet!");

            //  After calling this function 
            // Staking-time will be the current time
            stakingTime[msg.sender][Tokenid[msg.sender][i]]=block.timestamp;
            alreadyAwarded[Tokenid[msg.sender][i]]=true;
        }

        //  here we transfer the reward to the caller
        Token.transfer(msg.sender,reward);

       User[msg.sender].totlaWithdrawn +=  reward;
       User[msg.sender].availableToWithdraw =  0;
    }

    ////////////    Get index by Value   ////////////

    function find(uint value) internal  view returns(uint) {
        uint i = 0;
        while (Tokenid[msg.sender][i] != value) {
            i++;
        }
        return i;
    }

    ////////////    User have to pass tokenIdS to unstake   ////////////

    function unstake(uint256[] memory TokenIds)  external
        {
        
        for(uint256 i=0;i<TokenIds.length;i++){
            // here we store the total reward of user into a structur-variable
            User[msg.sender].availableToWithdraw += rewardOfUser(msg.sender,Tokenid[msg.sender][i]);
            
            if(rewardOfUser(msg.sender,Tokenid[msg.sender][i]) > 0) alreadyAwarded[TokenIds[i]]=true;
            // here we get the index of an id using find()
            uint256 _index=find(TokenIds[i]);
            require(Tokenid[msg.sender][_index] ==TokenIds[i] ,"NFT with this _tokenId not found");
            // here we 1st aprove the address from NFT to unstake the Id
            NFT.transferFrom(address(this),msg.sender,TokenIds[i]);
            delete Tokenid[msg.sender][_index];
            Tokenid[msg.sender][_index]=Tokenid[msg.sender][Tokenid[msg.sender].length-1];
            stakingTime[msg.sender][TokenIds[i]]=0;
            Tokenid[msg.sender].pop();
        }
            User[msg.sender].totalStaked-=TokenIds.length;
            totalStakedNft[msg.sender]>0?totalStakedNft[msg.sender]-=TokenIds.length:totalStakedNft[msg.sender]=0;
    }  

    function isStaked(address _stakeHolder)public view returns(bool){
            if(totalStakedNft[_stakeHolder]>0){
            return true;
            }else{
            return false;
          }
    }

    ////////////    Withdraw Token   ////////////    

    function WithdrawToken()public onlyOwner {
    require(Token.transfer(msg.sender,Token.balanceOf(address(this))),"Token transfer Error!");
    } 

}


/*
    TOKEN CONTRACT
    0xDFb4f695789aA0d5703A78900E2E86B182890749

    NFT CONTRACT
    0x9AF46bEE876F604E539872A6Afa470B446fEe5F1
*/