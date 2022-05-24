/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

pragma solidity ^0.8.0;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity ^0.8.0;
contract annexIronNftVault is Ownable 
{
    using SafeMath for uint256;
    IERC721 public nft;
    IERC20 public token;     
    uint256 public lockPeriod = 1 seconds;  
    uint256 public APY = 12; // 12% return per year for staking EDIPI
    uint256 public oneYear = 365 days; //12% return per year for staking EDIPI
              
    constructor (IERC721 _nft,address  _token)
    {
     token = IERC20(_token);
     nft=_nft;
    }
    struct Staker
    {
        uint256[] tokenIds;  
        uint256 rewardRelased;
        uint256 balance;
        mapping(uint256=>uint256) nftStakeTime;
        uint256 lastTimeClaim;
        bool isSwap;
    }
   uint256 public totalStaked;   
//    address public targetToken;
   uint256 private constant DAY_SEC=86400;
   uint256 private constant MONTH_SEC=2629743;

   mapping(address => Staker ) public stakerInfo;

   event Staked(address owner,uint256 tokenid);
   event UnStaked(address owner,uint256 tokenid);
   event Claim(address owner,uint256 amount);
   
   function stakeNft(uint256 _tokenid) public returns(bool )
   {
     require(nft.ownerOf(_tokenid)==msg.sender,"user should be the owner of nft");
     Staker storage staker  = stakerInfo[msg.sender];
     if(staker.lastTimeClaim == 0)
     {
        staker.lastTimeClaim=block.timestamp;
     }
     staker.tokenIds.push(_tokenid);
     staker.nftStakeTime[_tokenid]=block.timestamp;
     totalStaked++;
     emit Staked(msg.sender,_tokenid);
     return true;
   }
   function setNftAddress(IERC721 _nft) public onlyOwner returns(bool)
   {
       nft = _nft ;
       return true;
   }
   function claimBonus() public enableSwap returns(bool)
   {
      Staker storage staker  = stakerInfo[msg.sender];
      bool claimEligible = checkRewardClaimEligible(staker.lastTimeClaim);
      require(claimEligible == true , "not claim eligible");
    //   require(staker.lastTimeClaim.add(DAY_SEC) < block.timestamp,"one time claim allow in 24 hours");
      uint256 claimProfit = staker.tokenIds.length.div(totalStaked);
      uint256 timeDifference = block.timestamp.sub(staker.lastTimeClaim );
      uint256 totalDay=timeDifference.div(DAY_SEC);
      uint256 totalClaim=totalDay.mul(claimProfit);
      staker.balance = totalClaim;
      staker.lastTimeClaim=block.timestamp;
      if(getTokenBalance() < 1 ){
          return false;
      }else{
          token.transfer(msg.sender , totalClaim);
      }
      emit Claim(msg.sender,totalClaim);
      return true;

   }
    function getStakerTokenIds(address _user) public view returns (uint[] memory tokenIds) {
      tokenIds = stakerInfo[_user].tokenIds; // In case you have array of transactions
    }

    function getStakerNftTime(address _user,uint256 _tokenid) public view returns (uint256) {
        stakerInfo[_user].nftStakeTime[_tokenid];// In case you have array of transactions
    }

   function unStakeNft(uint256 _tokenid) public returns(bool)
   {
     require(nft.ownerOf(_tokenid)==msg.sender,"user should be the owner of nft");
     Staker storage staker  = stakerInfo[msg.sender];
     require(staker.nftStakeTime[_tokenid].add(MONTH_SEC) < block.timestamp,"unstake only allowed after 30 days");
     uint256 lastIndex = staker.tokenIds.length.sub(1);
     
     if ( lastIndex > 0)
     {
         staker.tokenIds.pop();
     }
     else 
     {
         delete stakerInfo[msg.sender];
     }
      staker.nftStakeTime[_tokenid]=0;
      // nft.transferFrom(address(this),msg.sender,_tokenid);
      emit UnStaked(msg.sender,_tokenid);
      return true;

   }


    /*
     * @dev Check claim eligible.
     *
     * @param from uint representing the deposit time start
     * @param uint256 _startDate repersent the time when stake initlizated
     * @return bool whether the call correctly returned the expected magic value
     */

    function checkRewardClaimEligible(uint depositedTime) public view returns(bool) {
        if (block.timestamp - depositedTime > DAY_SEC) {
            return true;
        }
        return false;
    }
    function isDistributionDue () public view returns (bool) {
        return getTokenBalance() > 1;
    }
    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /*
        Auto lending
        Users can enable auto compound features to get better rewards in ANN. 
        This features will work in this way, everyday at 00.00 UTC we will swap
        TUSD rewards to ANN using our dex stableswap, stake in the lending and 
        send to users the correspondent aANN.   
        We will show the compositions of vault rewards APY + lending ANN APY and people will choose this generating ANN buy pressure
    */

    /*
     * @dev vault rewards APY.
     *
     * @param from uint256 representing the stake amount
     * @param uint256 _startDate repersent the time when stake initlizated
     * @return uint256 reward on stake amount
     */
    
    function getReward(uint256 _amount, uint256 _startDate)
        internal
        view
        returns (uint256)
    {
        uint256 initialized = block.timestamp;
        uint256 stakedTime = initialized.sub(_startDate);
        uint256 lockPeriodsPassed = stakedTime.div(lockPeriod);
        uint256 stakedTimeForReward = lockPeriodsPassed.mul(lockPeriod);
        uint256 reward =
            _amount.mul(stakedTimeForReward).mul(APY).div(100).div(oneYear);
        //uint256 rewards = ((stakeamt.mul(APY[mos]).mul (mos.div(12)) )).div(100);
        return reward;
    }
     /*
     * @dev set the claim token.
     *
     * @param from address set the token address
     * @return index of token
     */

    function setToken(address _token)
        public
        returns (bool)
    {
        token = IERC20(_token);
        return true;
    }

    modifier enableSwap(){
        Staker storage staker  = stakerInfo[msg.sender];
        require(staker.isSwap == false,"You cannot claim before Annex swap.");
        _;
    }
}