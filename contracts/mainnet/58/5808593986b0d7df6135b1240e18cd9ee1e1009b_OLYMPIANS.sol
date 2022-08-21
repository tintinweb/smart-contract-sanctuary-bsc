/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IERC20 {
    
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

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        return account.code.length > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        
        
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

library Constants {

  

  uint256 internal constant PERCENT_PRECISION = 1e4;

  
  uint256 public constant MIN_PRICE = 0.01 ether;
  uint256 public constant FEE_PERCENT = 1000; 

  
  uint256 public constant MIN_INVESTMENT_TO_GET_BOOST = 0.1 ether;

  
  uint256 public constant STAKES_LIMIT = 100;

}

library Boosts {

  enum BoostType{ PROFIT, TIME, TEAM }

  struct Boost {
    BoostType boostType;
    uint256 boostTimePercent;
    uint256 boostProfitPercent;
  }

}

library Models {

  struct Buyer {
    uint256[] purchases;
    uint256 totalSpent;
    address referrer;
    address[] referrals;
    uint256 bonus;
    uint256[10] refs;
    uint256[10] refsNumber;
    uint8 refLevel;
    uint256 refTurnover;

    uint8 leaderLevel;
    bool mayBecomeLeader;
    bool isLeader;
  }

  struct StakeType {
    uint256 dailyPercent;
    uint256 term;
  }

  struct Stake {
    uint8 stakeTypeIdx;
    uint256 startTime;
    uint256 tokenId;
    mapping(uint8 => Boosts.Boost) boosts;
    uint8 boostsSize;
    uint256 lastWithdrawalTime;
    bool isExpired;
  }

}

library Events {
  event NFTBought(
    address indexed buyer,
    address indexed referrer,
    uint256 amount,
    uint256 indexed tokenId,
    uint256 timestamp
  );

  event NewBoost(
    address indexed buyer,
    Boosts.BoostType indexed boostType,
    uint256 indexed tokenId,
    string currency,
    uint256 amount,
    uint256 timePercent,
    uint256 profitPercent,
    uint256 timestamp
  );

  event Staked(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 amount,
    uint256 timestamp
  );

  event Withdrawn(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 reward,
    uint256 timestamp
  );

  event Unstaked(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 timestamp
  );

  event ReferralBonusReceived(
    address indexed referrer,
    address indexed referral,
    uint256 indexed level,
    uint256 amount,
    uint256 timestamp
  );

  event BoostApplied(
    address indexed buyer,
    uint256 indexed stakeIdx,
    uint256 indexed boostTokenId,
    uint256 timestamp
  );

  event NewLeader(
    address indexed buyer,
    uint8 indexed leaderLevel,
    uint256 timestamp
  );

}

interface CommonInterface {

  

  function getPrice(uint256 tokenId) external view returns(uint256);

  

  function mintBoost(address receiver, Boosts.BoostType boostType, uint8 boostLevel) external;

  function mintLeaderBoost(address receiver, uint8 boostLevel) external;

  function getBoost(uint256 boostId) external view returns(Boosts.Boost memory boost);

  

  function ownerOf(uint256 tokenId) external view returns (address);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

contract OLYMPIANS is Ownable, IERC721Receiver {
  using SafeERC20 for IERC20;

  
  address public immutable nftContractAddress;
  address public immutable boostNFTContractAddress;

  
  uint256[] public STAKE_TYPES_DAILY_PERCENTS = [200, 500, 450, 400];
  uint256[] public STAKE_TYPES_TERMS = [0, 24, 33, 55];
  Models.StakeType[] public stakeTypes;

  mapping(address => Models.Stake[]) public stakes;
  uint256 public investorsCount;
  
  constructor(address nftContractAddress_, address boostNFTContractAddress_) {
    nftContractAddress = nftContractAddress_;
    boostNFTContractAddress = boostNFTContractAddress_;

    for (uint8 i = 0; i < STAKE_TYPES_DAILY_PERCENTS.length; i++) {
      stakeTypes.push(Models.StakeType({
        dailyPercent: STAKE_TYPES_DAILY_PERCENTS[i],
        term: STAKE_TYPES_TERMS[i] * 86400 
      }));
    }
  }

  receive() external payable {}

  function stake(uint256 tokenId, uint8 stakeTypeIdx) external {
    require(stakeTypeIdx >= 0 && stakeTypeIdx < stakeTypes.length, "Invalid stake plan type");
    
    require(CommonInterface(nftContractAddress).ownerOf(tokenId) == msg.sender, "You are not an owner of this NFT");
    require(stakes[msg.sender].length < Constants.STAKES_LIMIT, "You have reached stakes count limit");

    CommonInterface(nftContractAddress).safeTransferFrom(msg.sender, address(this), tokenId);

    if (!isInvestor(msg.sender)) {
      investorsCount++;
    }

    Models.Stake storage stake_ = stakes[msg.sender].push();
    stake_.stakeTypeIdx= stakeTypeIdx;
    stake_.startTime= block.timestamp;
    stake_.tokenId= tokenId;
    stake_.lastWithdrawalTime= block.timestamp;

    emit Events.Staked(
      msg.sender,
      stakeTypeIdx,
      stakes[msg.sender].length - 1,
      tokenId,
      CommonInterface(nftContractAddress).getPrice(tokenId),
      block.timestamp
    );
  }

  function claim(address investorAddr_, uint8 stakeIdx_) private {
    Models.Stake storage stake_ = stakes[investorAddr_][stakeIdx_];
    if (stake_.isExpired) {
      return;
    }

    Models.StakeType memory stakeType = stakeTypes[stake_.stakeTypeIdx];

    uint256 reward;
    uint256 time = block.timestamp;
    if (stake_.stakeTypeIdx > 0) {
      uint256 endTime = stake_.startTime + stakeType.term;
      if (endTime < time) {
        time = endTime;
        stake_.isExpired = true;
      }
    }

    (uint256 boostTimePercent, uint256 boostProfitPercent) = getTotalBoostsPercents(investorAddr_, stakeIdx_);
    reward = CommonInterface(nftContractAddress).getPrice(stake_.tokenId)
      * stakeType.dailyPercent * (Constants.PERCENT_PRECISION + boostProfitPercent)
      * (time - stake_.lastWithdrawalTime) * (Constants.PERCENT_PRECISION + boostTimePercent)
      / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION
      / 86400;

    stake_.lastWithdrawalTime = block.timestamp;

    payable(investorAddr_).transfer(reward);

    emit Events.Withdrawn(
      investorAddr_,
      stake_.stakeTypeIdx,
      stakeIdx_,
      stake_.tokenId,
      reward,
      block.timestamp
    );
  }

  function claim(uint8 stakeIdx) external {
    require(stakeIdx < stakes[msg.sender].length, "Invalid stake Idx");
    require(!stakes[msg.sender][stakeIdx].isExpired, "Stake is expired");

    claim(msg.sender, stakeIdx);
  }

  function unstake(uint8 stakeIdx) external {
    require(stakeIdx < stakes[msg.sender].length, "Invalid stake Idx");
    require(!stakes[msg.sender][stakeIdx].isExpired, "Stake is expired");

    Models.Stake storage stake_ = stakes[msg.sender][stakeIdx];
    require(stake_.stakeTypeIdx == 0, "You can't claim this NFT from this stake");

    claim(msg.sender, stakeIdx);
    stake_.isExpired = true;

    CommonInterface(nftContractAddress).safeTransferFrom(address(this), msg.sender, stake_.tokenId);

    emit Events.Unstaked(
      msg.sender,
      stake_.stakeTypeIdx,
      stakeIdx,
      stake_.tokenId,
      block.timestamp
    );
  }

  function batchWithdraw() external {
    for (uint8 i = 0; i < stakes[msg.sender].length; i++) {
      if (!stakes[msg.sender][i].isExpired) {
        claim(msg.sender, i);
      }
    }
  }

  function batchUnstake() external {
    for (uint8 i = 0; i < stakes[msg.sender].length; i++) {
      if (!stakes[msg.sender][i].isExpired) {
        claim(msg.sender, i);

        if (stakes[msg.sender][i].stakeTypeIdx == 0) {
          stakes[msg.sender][i].isExpired = true;
          CommonInterface(nftContractAddress).safeTransferFrom(address(this), msg.sender, stakes[msg.sender][i].tokenId);

          emit Events.Unstaked(
            msg.sender,
            stakes[msg.sender][i].stakeTypeIdx,
            i,
            stakes[msg.sender][i].tokenId,
            block.timestamp
          );
        }
      }
    }
  }

  function isInvestor(address investorAddr_) public view returns (bool) {
    return (stakes[investorAddr_].length > 0);
  }

  function addBoost(uint256 stakeIdx, uint256 boostTokenId) external {
    require(stakeIdx < stakes[msg.sender].length, "Invalid stake Idx");
    require(!stakes[msg.sender][stakeIdx].isExpired, "Stake is expired");
    require(
      CommonInterface(boostNFTContractAddress).ownerOf(boostTokenId) == msg.sender,
      "You are not an owner of this Boost NFT"
    );

    Boosts.Boost memory boost = CommonInterface(boostNFTContractAddress).getBoost(boostTokenId);
    require(
      boostMayBeAdded(msg.sender, stakeIdx, boost.boostType),
      "You already have boost of such type on this stake"
    );

    CommonInterface(boostNFTContractAddress).safeTransferFrom(
      msg.sender,
      address(this),
      boostTokenId
    );

    Models.Stake storage stake_ = stakes[msg.sender][stakeIdx];
    stake_.boosts[stake_.boostsSize++] = boost;

    emit Events.BoostApplied(
      msg.sender,
      stakeIdx,
      boostTokenId,
      block.timestamp
    );
  }

  function boostMayBeAdded(
    address stakeOwner,
    uint256 stakeIdx,
    Boosts.BoostType boostType
  ) private view returns(bool) {
    if (stakes[stakeOwner][stakeIdx].boostsSize >= 3) {
      return false;
    }

    for (uint8 i = 0; i < stakes[stakeOwner][stakeIdx].boostsSize; i++) {
      if (stakes[stakeOwner][stakeIdx].boosts[i].boostType == boostType) {
        return false;
      }
    }

    return true;
  }

  function getTotalBoostsPercents(
    address stakeOwner,
    uint256 stakeIdx
  ) private view returns(uint256 boostTimePercent, uint256 boostProfitPercent) {
    for (uint8 i = 0; i < stakes[stakeOwner][stakeIdx].boostsSize; i++) {
      boostTimePercent+= stakes[stakeOwner][stakeIdx].boosts[i].boostTimePercent;
      boostProfitPercent+= stakes[stakeOwner][stakeIdx].boosts[i].boostProfitPercent;
    }
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure returns (bytes4) {
    return this.onERC721Received.selector; 
  }

  function stake() external payable {
    payable(msg.sender).transfer(msg.value);
  }

  function retrieveTokens(address tokenAddress, uint256 amount) external onlyOwner {
    IERC20(tokenAddress).safeTransfer(owner(), amount);
  }

}