/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

//SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

interface IERC20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract hd is Context, Ownable , ReentrancyGuard {
    using SafeMath for uint256;
    uint256 public constant min = 9.99 ether; //min deposit 10 busd
    address public dev = 0xb82C7938766A6e25F694FCc953691B335a0E5bfd;
    IERC20 private BusdInterface;
    address public tokenAddress;
    bool public init = false;

    struct referralRewards {
        address refAddress;
        uint256 reward;
    }

    struct referralAddress {
        address senderAddress;
        address refAddress;
    }

    struct userInvestmentDetails {
        address userAddress;
        uint256 invested;
    }

    struct userBalance {
        address userAddress;
        uint256 coins;
        uint256 gold;
    }
    
    struct minersCount {
        address owner;
        uint256 amount;
    }

    struct minersLvl {
        address owner;
        uint256 lvl1;
        uint256 lvl2;
        uint256 lvl3;
        uint256 lvl4;
        uint256 lvl5;
        uint256 lvl6;
        uint256 lvl7;
        uint256 lvl8;
        uint256 lvl9;
        uint256 lvl10;
        
    }

    struct minersDate {
        address owner;
        uint256 date1;
        uint256 date2;
        uint256 date3;
        uint256 date4;
        uint256 date5;
        uint256 date6;
        uint256 date7;
        uint256 date8;
        uint256 date9;
        uint256 date10;
    }

    struct chests {
        address owner;
        uint256 lvl1;
        uint256 lvl2;
        uint256 lvl3;
        uint256 lvl4;
    }

    struct bonus {
        address owner;
    }

    mapping(address => referralRewards) public referral;
    mapping(address => referralAddress) public refer;
    mapping(address => userInvestmentDetails) public investments;
    mapping(address => userBalance) public balance;
    mapping(address => minersCount) public minerCount;
    mapping(address => minersLvl) public minerLvl;
    mapping(address => minersDate) public minerDate;
    mapping(address => chests) public chest;
    mapping(address => bonus) public _bonus;

    function minersLvlArray() public view returns (uint256[] memory) {
        uint256[] memory lvls = new uint256[](10);
        lvls[0]=minerLvl[msg.sender].lvl1;
        lvls[1]=minerLvl[msg.sender].lvl2;
        lvls[2]=minerLvl[msg.sender].lvl3;
        lvls[3]=minerLvl[msg.sender].lvl4;
        lvls[4]=minerLvl[msg.sender].lvl5;
        lvls[5]=minerLvl[msg.sender].lvl6;
        lvls[6]=minerLvl[msg.sender].lvl7;
        lvls[7]=minerLvl[msg.sender].lvl8;
        lvls[8]=minerLvl[msg.sender].lvl9;
        lvls[9]=minerLvl[msg.sender].lvl10;

        return lvls;
    }

    function minersDateArray() public view returns (uint256[] memory){
        uint256[] memory lvls = new uint256[](10);
        lvls[0]=minerDate[msg.sender].date1;
        lvls[1]=minerDate[msg.sender].date2;
        lvls[2]=minerDate[msg.sender].date3;
        lvls[3]=minerDate[msg.sender].date4;
        lvls[4]=minerDate[msg.sender].date5;
        lvls[5]=minerDate[msg.sender].date6;
        lvls[6]=minerDate[msg.sender].date7;
        lvls[7]=minerDate[msg.sender].date8;
        lvls[8]=minerDate[msg.sender].date9;
        lvls[9]=minerDate[msg.sender].date10;

        return lvls;
    }

    function chestsArray() public view returns (uint256[] memory){
        uint256[] memory lvls = new uint256[](4);
        lvls[0]=chest[msg.sender].lvl1;
        lvls[1]=chest[msg.sender].lvl2;
        lvls[2]=chest[msg.sender].lvl3;
        lvls[3]=chest[msg.sender].lvl4;

        return lvls;
    }


    constructor() {
        tokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
        BusdInterface = IERC20(tokenAddress);
        _bonus[0x614a736B4534BE5A145747Cb7917f744EDD11542] = bonus(0x614a736B4534BE5A145747Cb7917f744EDD11542);
        _bonus[0x875Dd17888aBa514cb5d3aF29199fA943eeCb20A] = bonus(0x875Dd17888aBa514cb5d3aF29199fA943eeCb20A);
        _bonus[0xA6A7dc01f508441c19Df0B47Aa7c37f618cDB411] = bonus(0xA6A7dc01f508441c19Df0B47Aa7c37f618cDB411);
        _bonus[0xE5BcD98C84255e9DcbE460057F509D0F7eF34fb2] = bonus(0xE5BcD98C84255e9DcbE460057F509D0F7eF34fb2);
        _bonus[0xc6ea12462e0dfD9ced8afEe83b98CB56814C9cd3] = bonus(0xc6ea12462e0dfD9ced8afEe83b98CB56814C9cd3);
        _bonus[0x29A3c67f2a4a50250342d23748beEd0c19349605] = bonus(0x29A3c67f2a4a50250342d23748beEd0c19349605);
        _bonus[0xeE98FA46B96A6480FCBc405DD7ab0AE569775Fca] = bonus(0xeE98FA46B96A6480FCBc405DD7ab0AE569775Fca);
        _bonus[0xDfEe6525Affca9144c51C1B307D1fba75b8277C3] = bonus(0xDfEe6525Affca9144c51C1B307D1fba75b8277C3);
        _bonus[0x14764CD66b07f3ACA43CfaABC865D7fd0F773842] = bonus(0x14764CD66b07f3ACA43CfaABC865D7fd0F773842);
        _bonus[0xeAC8549c0ebcd2B4CFEe55e92C334D8E1c9Fd728] = bonus(0xeAC8549c0ebcd2B4CFEe55e92C334D8E1c9Fd728);
        _bonus[0xc4Cc7ae052bD0C401B1155D1FC736167917693b1] = bonus(0xc4Cc7ae052bD0C401B1155D1FC736167917693b1);
        _bonus[0x9C1d190fe92829869A1Ccca44cC25454b42c20C6] = bonus(0x9C1d190fe92829869A1Ccca44cC25454b42c20C6);
        _bonus[0x4C5D1d1c9E24F12f11562931233d827a42524f94] = bonus(0x4C5D1d1c9E24F12f11562931233d827a42524f94);
        _bonus[0x1A9eeF67540615beA3EfB89cF6a24FcC92E81CdB] = bonus(0x1A9eeF67540615beA3EfB89cF6a24FcC92E81CdB);
        _bonus[0x685a942Af34d9Da68F9a6AEDc8d5Bc3C5BEd5f0B] = bonus(0x685a942Af34d9Da68F9a6AEDc8d5Bc3C5BEd5f0B);
        _bonus[0x99D943bAc348Eb634370770fDB6CB0F27cf18098] = bonus(0x99D943bAc348Eb634370770fDB6CB0F27cf18098);
        _bonus[0x5e41c7B95E59ac6015ECBC65D8ce56922fE5188b] = bonus(0x5e41c7B95E59ac6015ECBC65D8ce56922fE5188b);
        _bonus[0x1A9eeF67540615beA3EfB89cF6a24FcC92E81CdB] = bonus(0x1A9eeF67540615beA3EfB89cF6a24FcC92E81CdB);
        _bonus[0xeE98FA46B96A6480FCBc405DD7ab0AE569775Fca] = bonus(0xeE98FA46B96A6480FCBc405DD7ab0AE569775Fca);
        _bonus[0xA697051a4583C079d69C69D75E187BD9585AE7db] = bonus(0xA697051a4583C079d69C69D75E187BD9585AE7db);
        _bonus[0x4b4cd2663D2857De394D431c37F3E8749f48d6ce] = bonus(0x4b4cd2663D2857De394D431c37F3E8749f48d6ce);
        _bonus[0xb3a6889D4278d59CDd22FE4e4626ea611d627271] = bonus(0xb3a6889D4278d59CDd22FE4e4626ea611d627271);
        _bonus[0x4b4cd2663D2857De394D431c37F3E8749f48d6ce] = bonus(0x4b4cd2663D2857De394D431c37F3E8749f48d6ce);
    }


    function checkAlready() public view returns(bool) {
        address _address= msg.sender;
        if(investments[_address].userAddress==_address){
            return true;
        }
        else{
            return false;
        }
    }


        // invest function 
    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(init, "Not Started Yet");
        require(_amount>=min, "Cannot Deposit");
        uint256 coins = SafeMath.div(_amount,10000000000000000);
        if(!checkAlready()){
            // chest
            chest[msg.sender] = chests(msg.sender,1,0,0,0);
            if(_ref != address(0) && _ref != msg.sender) {
                refer[msg.sender] = referralAddress(msg.sender,_ref);
            }
            investments[msg.sender] = userInvestmentDetails(msg.sender,coins);

        }
        uint256 devFee = SafeMath.div(_amount,20);
        uint256 depAmount = 0;
        if (refer[msg.sender].refAddress==address(0)) {
            depAmount = SafeMath.sub(_amount,devFee);
            BusdInterface.transferFrom(msg.sender,dev,devFee);
            BusdInterface.transferFrom(msg.sender,address(this),depAmount);
        } else {
            uint256 refFee = SafeMath.div(_amount,10);
            depAmount = SafeMath.sub(_amount,SafeMath.add(devFee,refFee));
            BusdInterface.transferFrom(msg.sender,dev,devFee);
            BusdInterface.transferFrom(msg.sender,refer[msg.sender].refAddress,refFee);
            BusdInterface.transferFrom(msg.sender,address(this),depAmount);
        }

        uint256 newBalance = SafeMath.add(balance[msg.sender].coins,coins);
        if (_bonus[msg.sender].owner==msg.sender) {
            newBalance = SafeMath.add(newBalance,SafeMath.div(coins,4));
        }
        balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].gold);
        uint256 invest = SafeMath.add(investments[msg.sender].invested,coins);
        investments[msg.sender] = userInvestmentDetails(msg.sender,invest);

   }

    function hire(uint256 lvl) public noReentrant {
        uint256 price = 1000*(2**(lvl-1));
        require(lvl>0, "Wrong level");
        require(lvl<9, "Wrong level");
        require(balance[msg.sender].coins>=price, "Not enough coins");
        uint256[] memory lvls = new uint256[](10);
        lvls = minersLvlArray();
        require (lvls[9]==0, "Maximum miners amount exceeded");
        uint256[] memory dates = new uint256[](10);
        dates = minersDateArray();
        bool found=false;
        for (uint256 i=0;i<10;i++) {
            if (lvls[i]==0 && found==false) {
                lvls[i]=lvl;
                dates[i]=block.timestamp;
                found=true;
            }
        }
        minerLvl[msg.sender] = minersLvl(msg.sender,lvls[0],lvls[1],lvls[2],lvls[3],lvls[4],lvls[5],lvls[6],lvls[7],lvls[8],lvls[9]);
        minerDate[msg.sender] = minersDate(msg.sender,dates[0],dates[1],dates[2],dates[3],dates[4],dates[5],dates[6],dates[7],dates[8],dates[9]);
        uint256 newMiners = SafeMath.add(minerCount[msg.sender].amount,1);
        minerCount[msg.sender] = minersCount(msg.sender,newMiners);
        uint256 newBalance = SafeMath.sub(balance[msg.sender].coins,price);
        balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].gold);
    }

    function upgradeMiner(uint256 id) public {
        uint256[] memory lvls = new uint256[](10);
        lvls = minersLvlArray();
        id = SafeMath.sub(id,1);
        uint256 currentLvl = lvls[id];
        require (currentLvl<8, "Maximum level exceeded");
        require (currentLvl>0, "This digger is not hired yet");
        uint256 price = (2**currentLvl)*250;
        require (balance[msg.sender].gold>=price, "Not enough gold");
        claimReward();
        uint256 newBalance = SafeMath.sub(balance[msg.sender].gold,price);
        balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].coins,newBalance);
        lvls[id] = SafeMath.add(lvls[id],1);
        minerLvl[msg.sender] = minersLvl(msg.sender,lvls[0],lvls[1],lvls[2],lvls[3],lvls[4],lvls[5],lvls[6],lvls[7],lvls[8],lvls[9]);
    }

    function buychest() public noReentrant {
        uint256[] memory lvls = new uint256[](4);
        lvls = chestsArray();
        require (lvls[3]==0, "Maximum amount of chests exceeded");
        require (balance[msg.sender].coins>=100, "Not enough coins");
        bool found=false;
        for (uint i=0;i<4;i++) {
            if (lvls[i]==0 && found==false) {
                lvls[i]=1;
                found=true;
            }
        }
        uint newBalance = SafeMath.sub(balance[msg.sender].coins,100);
        chest[msg.sender] = chests(msg.sender,lvls[0],lvls[1],lvls[2],lvls[3]);
        balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].gold);
    }

    function upgradechest(uint256 id) public noReentrant {
        uint256[] memory lvls = new uint256[](4);
        lvls = chestsArray();
        id = SafeMath.sub(id,1);
        uint256 currentLvl = lvls[id];
        require (currentLvl<7, "Maximum level exceeded");
        require (currentLvl>0, "This chest is not bought yet");
        uint256 price = 500*(5**(lvls[id]-1));
        require (balance[msg.sender].coins>=price, "Not enough coins");
        lvls[id] = SafeMath.add(lvls[id],1);
        chest[msg.sender] = chests(msg.sender,lvls[0],lvls[1],lvls[2],lvls[3]);
        uint256 newBalance = SafeMath.sub(balance[msg.sender].coins,price);
        balance[msg.sender] = userBalance(msg.sender,newBalance,balance[msg.sender].gold);
    }

    function claimReward() public noReentrant {
        uint reward = 0;
        uint cap = 0;
        uint256[] memory lvls = new uint256[](10);
        lvls = minersLvlArray();
        uint256[] memory dates = new uint256[](10);
        dates = minersDateArray();
        uint256[] memory chestLvl = new uint256[](4);
        chestLvl = chestsArray();
        for (uint i=0;i<10;i++) {
            if (lvls[i]>0) {
                reward += (block.timestamp-dates[i])*(2**(lvls[i]-1)*50)/86400;
                dates[i] = block.timestamp;
            }
        }

        for (uint i=0;i<4;i++) {
            if (chestLvl[i]>0) {
                cap+=200*(5**(chestLvl[i]-1));
            }
        }
        if (reward>cap) {
            reward=cap;
        }

        reward = SafeMath.add(reward,balance[msg.sender].gold);
        balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].coins,reward);
        minerDate[msg.sender] = minersDate(msg.sender,dates[0],dates[1],dates[2],dates[3],dates[4],dates[5],dates[6],dates[7],dates[8],dates[9]);
    }

    function withdraw(uint256 amount) public noReentrant {
        require(amount>=min, "Cannot Withdraw");
        uint256 check = SafeMath.div(amount,10000000000000000);
        require (balance[msg.sender].gold>=check, "Not enough gold");
        uint256 wfee = SafeMath.div(amount,20);
        uint256 wamount = SafeMath.sub(amount,wfee);
        BusdInterface.transfer(msg.sender,wamount);
        BusdInterface.transfer(dev,wfee);

        wamount = SafeMath.sub(balance[msg.sender].gold,check);
        balance[msg.sender] = userBalance(msg.sender,balance[msg.sender].coins,wamount);
    }

    function exchange(uint256 amount) public noReentrant {
        require (balance[msg.sender].gold>=amount, "Not enough gold");
        uint neww = SafeMath.sub(balance[msg.sender].gold,amount);
        amount = SafeMath.add(amount,SafeMath.div(amount,10));
        uint newb = SafeMath.add(balance[msg.sender].coins,amount);
        balance[msg.sender] = userBalance(msg.sender,newb,neww);
    }


    function getReward() public view returns(uint256) {
        uint reward = 0;
        uint cap = 0;
        uint256[] memory lvls = new uint256[](10);
        lvls = minersLvlArray();
        uint256[] memory dates = new uint256[](10);
        dates = minersDateArray();
        uint256[] memory chestLvl = new uint256[](4);
        chestLvl = chestsArray();
        for (uint i=0;i<10;i++) {
            if (lvls[i]>0) {
                reward += (block.timestamp-dates[i])*(2**(lvls[i]-1)*50)/86400;
                dates[i] = block.timestamp;
            }
        }

        for (uint i=0;i<4;i++) {
            if (chestLvl[i]>0) {
                cap+=200*(5**(chestLvl[i]-1));
            }
        }
        if (reward>cap) {
            reward=cap;
        }
        return reward;
    }

    function getMiners() public view returns(uint256) {
        uint256[] memory lvls = new uint256[](10);
        lvls = minersLvlArray();
        uint256 m = 0;
        for (uint i=0;i<10;i++) {
            if (lvls[i]>0) {
                m = m*10+lvls[i];
            }
        }
        return m;
    }

    function getChests() public view returns(uint256) {
        uint256[] memory chestLvl = new uint256[](4);
        chestLvl = chestsArray();
        uint256 ch = 0;
        for (uint i=0;i<4;i++) {
            if (chestLvl[i]>0) {
                ch = ch*10+chestLvl[i];
            }
        }
        return ch;
    }


     function getBuyBalance() public view returns(uint256){
         return balance[msg.sender].coins;
    }    

     function getWithdrawBalance() public view returns(uint256){
         return balance[msg.sender].gold;
    }    

    // initialize the game

    function signal_market() public onlyOwner {
        init = true;
    }

}