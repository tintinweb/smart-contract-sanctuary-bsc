/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;
/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: 小精灵/@openzeppelin-0.8/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: 小精灵/@openzeppelin-0.8/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: 小精灵/buyTokenAndReward-bsc.sol


pragma solidity ^0.8.7;


// import "./00_hardhat-console.sol";

contract buyTokenAndReward is Ownable{

    address public linkAddress = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD; //bep20
    uint public numberOfPeopleForRewards = 500;
    uint public rewardPoolTotal;
    uint public round=1; 
    mapping(uint => uint) public rewardPoolSeason;  
    mapping(uint => bool) public canClaimReward; 
    mapping(uint => uint) public everyRoundClaimDeadline; 
    mapping(uint => uint) public rewardToBeClaim1; 
    mapping(uint => uint) public rewardToBeClaim2; 
    mapping(uint => uint) public rewardToBeClaim3;
    mapping(uint => mapping(address => uint)) public whiteList1;  
    mapping(uint => mapping(address => uint)) public whiteList2;  
    mapping(uint => mapping(address => uint)) public whiteList3;  
    // div 10**9
    uint[] rewardRatio = [101108827,80587061,60065296,50554413,40443531,36399178,32354825,28310472,24266118,20221765,19210677,18199589,17188501,16177412,15166324,14155236,13144147,12133059,10110883,9605339,9099794,8594250,8088706,7583162,7077618,6572074,6066530,5560985,5055441,4549897,4044353,3538809,3066968,2527721,2224394,2123285,2072731,2022177,2012066,2001955,1991844,1981733,1971622,1961511,1941289,1910957,1900846,1890735,1880624,1870513,1860402,1850292,1840181,1819959,1799737,1779515,1759294,1739072,1718850,1698628,1678407,1658185,1637963,1617741,1597519,1577298,1557076,1536854,1516632,1496411,1476189,1455967,1435745,1415524,1395302,1375080,1354858,1334637,1314415,1294193,1273971,1253749,1233528,1213306,1193084,1172862,1152641,1132419,1112197,1091975,1071754,1051532,1031310,1011088,990867,970645,950423,930201,909979,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,900000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,800000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,700000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,600000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,500000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,400000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,300000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,200000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000,100000];

    constructor(){
    }

    function buyEgt(uint256 _amount) public {
        IBEP20(linkAddress).transferFrom(msg.sender, address(this), _amount); 
        rewardPoolTotal += _amount *48 / 100; 
        rewardPoolSeason[round] += _amount *12 / 100; 
        emit BuyEgt(msg.sender, _amount);
    }

    function claimRewards(uint _type) public { 
        require(canClaimReward[round-1],"Before Start");  
        require(block.timestamp > everyRoundClaimDeadline[round-1],"Overtime");
        if(_type==1){
            require(whiteList1[round-1][msg.sender] !=0,"No Reward"); 
            uint rank = whiteList1[round-1][msg.sender];
            whiteList1[round-1][msg.sender] = 0;
            IBEP20(linkAddress).transfer(msg.sender, rewardToBeClaim1[round-1] * rewardRatio[rank]/10**9 );
            emit ClaimRewards(msg.sender, rewardToBeClaim1[round-1] * rewardRatio[rank]/10**9);
        }else if(_type==2){
            require(whiteList2[round-1][msg.sender] !=0,"No Reward"); 
            uint rank = whiteList2[round-1][msg.sender];
            whiteList2[round-1][msg.sender] = 0; 
            IBEP20(linkAddress).transfer(msg.sender, rewardToBeClaim2[round-1] * rewardRatio[rank]/10**9 ); 
            emit ClaimRewards(msg.sender, rewardToBeClaim2[round-1] * rewardRatio[rank]/10**9);
        }else if(_type==3){
            require(whiteList3[round-1][msg.sender] !=0,"No Reward"); 
            uint rank = whiteList3[round-1][msg.sender];
            whiteList3[round-1][msg.sender] = 0; 
            IBEP20(linkAddress).transfer(msg.sender, rewardToBeClaim3[round-1] * rewardRatio[rank]/10**9 );
            emit ClaimRewards(msg.sender, rewardToBeClaim3[round-1] * rewardRatio[rank]/10**9);
        }
        
    }
    
    //   *******  view function  *******  //
    function getRewardPoolTotal() external view returns (uint){
        return rewardPoolTotal;
    }
    function getRewardPoolThisSeason() external view returns (uint){   
        return rewardPoolSeason[round];
    }
    function getRewardPoolLastSeason() external view returns (uint){   
        return rewardPoolSeason[round-1];
    }
    function getRound() external view returns (uint){
        return round;
    }
    function getUserReward(uint _type) external view returns (uint){
        if(block.timestamp > everyRoundClaimDeadline[round-1]){
            return 0;
        }else{
            if(_type == 1){
                return rewardToBeClaim1[round-1] * rewardRatio[whiteList1[round-1][msg.sender]]/10**9;
            }else if(_type == 2){
                return rewardToBeClaim2[round-1] * rewardRatio[whiteList2[round-1][msg.sender]]/10**9;
            }else if(_type == 3){
                return rewardToBeClaim3[round-1] * rewardRatio[whiteList3[round-1][msg.sender]]/10**9;
            }else{
                return 0;
            }
        }
    }

    //   *******  admin function  *******  //
    function setWhiteList1(address[] calldata _whiteList1) external onlyOwner {
        for(uint i=0;i<numberOfPeopleForRewards;i++){ 
            whiteList1[round][_whiteList1[i]] = i+1;
        }
    }
    function setWhiteList2(address[] calldata _whiteList2) external onlyOwner {
        for(uint i=0;i<numberOfPeopleForRewards;i++){ 
            whiteList2[round][_whiteList2[i]] = i+1;
        }
    }
    function setWhiteList3(address[] calldata _whiteList3) external onlyOwner {
        for(uint i=0;i<numberOfPeopleForRewards;i++){ 
            whiteList3[round][_whiteList3[i]] = i+1;
        }
    }
    function setBeforeNextSeasonStart() external onlyOwner {
        rewardToBeClaim1[round] = rewardPoolSeason[round] *34 /100;
        rewardToBeClaim2[round] = rewardPoolSeason[round] *33 /100;
        rewardToBeClaim3[round] = rewardPoolSeason[round] *33 /100;
        canClaimReward[round] = true;
        everyRoundClaimDeadline[round] = block.timestamp + 86400;
        round = round+1;
        rewardPoolSeason[round] = rewardPoolTotal *5 /10;
    }

    function setLinkAddress(address _linkAddress) external onlyOwner {
        linkAddress = _linkAddress;
    }
    function setNumberOfPeopleForRewards(uint _numberOfPeopleForRewards) external onlyOwner {
        numberOfPeopleForRewards = _numberOfPeopleForRewards;
    }
    function setRewardRatio(uint[] calldata _rewardRatio) external onlyOwner {
        rewardRatio = _rewardRatio;
    }
    function withdraw(address _token, uint256 _amount) external onlyOwner{
        IBEP20(_token).transfer(owner(), _amount);
    }
    function withdrawBnb(uint _amount) external onlyOwner {
        payable(owner()).transfer(_amount);
    }

    //   *******  event  *******  //

    event BuyEgt(address indexed who, uint amountLink);

    event ClaimRewards(address indexed who, uint amount);

}