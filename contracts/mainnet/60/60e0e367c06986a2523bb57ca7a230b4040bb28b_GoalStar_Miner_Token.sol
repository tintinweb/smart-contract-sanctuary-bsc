/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SignedSafeMath {
    /**
     * @dev Returns the multiplication of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two signed integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }

    /**
     * @dev Returns the addition of two signed integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    // function allowance(address owner, address spender) external view returns (uint256);

    // function approve(address spender, uint256 amount) external returns (bool);
    
    // function increaseAllowance(address spender, uint256 addedValue) external  returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function name() external  view  returns(string memory);
    function symbol() external view   returns (string memory);
    function decimals() external view  returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IGoalNFT
{
function balanceOf(address _user) external view returns(uint256);    
//function getTokenIdsOwnedBy(address  _owner)external view  returns (uint256 [] memory);

}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    address payable public owner;
    mapping (address => bool ) public admin;

    address payable public buybackWallet;
    address payable public projectWallet;

    uint256 public END_REWARD = 1673308800;//9 Jan 2023 24:00:00 UTC

    mapping (address => uint256 ) internal earnedBNB;
    mapping (address => uint256 []) public earnedBNBDate;
    uint256 public intervalRewardTime = 1 days;

    mapping (address => uint256 ) public minerTokenIds;
    bool public minerIsON = false;
 
    mapping (address => mapping (uint256 => uint256))  minerDateOwner;
    mapping (address => mapping (uint256 => uint256))  minerTokenAmountOwner;

    uint256 public tokenPrice;

    mapping (address => uint256) public maxLimitWallet;
    uint256 public maxLimit = 30 ether;
    uint256 public totRewards;
    uint256 public totReferralRewards;
    uint256 public minPurchase = 0.3 ether;

    mapping (address  => bool) internal referralAddress;
    mapping (address  => uint256) internal referralRewards;
    mapping (address  => address []) internal referralArray;
    mapping (address  => address) internal referralPair;
    address [] public referralList;
   /*  */

    uint256 public divider = 1000;
    uint256 public minerReward = 30 ; // 3% each day
    uint256 public referralFee = 100;//10%
    uint256 public projectFeeRate = 40;//4%
    uint256 public buybackFeeRate = 10;//1%
    uint256 public buybackFeesAmount;
    uint256 public depositedAmount;

    uint256 public referralTokenPrize = 10;// 1% 

    bool public tradeIsOpen = false;

    address nftAddress = 0x5E9C28204714095f179217C7Ff07C3436ae3e04a;
    IGoalNFT public nftToken = IGoalNFT(nftAddress);
    mapping (uint256  => uint256) internal nftBoost;

    constructor ( string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = payable(msg.sender);
        admin[msg.sender] = true;
        tokenPrice = 0.00001 ether;
        referralAddress[msg.sender] = true;
    
    
    projectWallet   = payable(0x422278F46632F8F4250a5e076252f415A0D4162a);
    buybackWallet = payable(0x9538123ec964489D0dDf8F8e82Fe496FF8a64168);
    
    nftBoost[5] = 100;//10% more GOALS with 5 NFTs
    nftBoost[3] = 80;//8% more GOALS with 3 NFTs
    nftBoost[1] = 70;//7% more GOALS with 1 NFTs
    }
   
    /* DEFAULT FUNCTIONS*/
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {//
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address Owner, address spender) public view virtual  returns (uint256) {//override
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) internal virtual  returns (bool) {//override
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {//
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(((currentAllowance >= amount)), "Transfer amount exceeds allowance ");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance.sub(amount));
             }
        return true;
    }
  
    function increaseAllowance(address spender, uint256 addedValue) internal virtual  returns (bool) {//override
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) internal virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance.sub(subtractedValue));
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tradeIsOpen, "transfership not allowed : New owner can't receive rewards");
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance.sub(amount);
        }
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance.sub(amount);
        }
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, deadAddress, amount);
    }

   
    function _approve(address Owner, address spender, uint256 amount) internal virtual {
        require(Owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Owner][spender] = amount;
        emit Approval(Owner, spender, amount);
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }

    /* maybe in the future: holders can sell tokens in pancakeswap only if enabled*/
    function openTrade(bool _isOpen) public  returns (bool ) {
        require(msg.sender == owner,"Only Admin can open Trade");
        tradeIsOpen = _isOpen;
        return _isOpen;
    }
    
    /*REFERRAL*/
    function addReferral(address _referral, bool isOn) public returns (bool )  {
        require(admin[msg.sender], "Only Admin can act with this");
        referralAddress[_referral] = isOn;
        if(isOn == true)referralList.push(_referral);
        return isOn;
    }
    function setMaxLimitWallet(uint256 _maxWei) public returns (bool )  {
        require(admin[msg.sender], "Only Admin can act with this");
        maxLimit = _maxWei;
        return true;
    }
    function getReferralList() public view returns (address[] memory )  {
        return referralList ;
    }
    function getIsReferral(address _referral ) public view returns (bool )  {
        return referralAddress[_referral] ;
    }
    function getReferralPair(address _user ) public view returns (address )  {
        return referralPair[_user];
    }
    function getReferralRewards(address _referral ) public view returns (uint256 )  {
        return referralRewards[_referral];
    }
    function getReferralArray(address _referral ) public view returns (address [] memory )  {
        return referralArray[_referral];
    }
    function setNftBoost (uint256 balance, uint256 boost) public {
        nftBoost[balance] = boost;
    }
    mapping (address => uint256) purchasedBNB;
    mapping (address => uint256) withdrawnBNBrewards;
    /* TOKEN MINTING. */
    function buyToken (uint256 tokens, address _referral) public payable returns (bool){
        uint amount = msg.value;
        require(minerIsON == true, "Contract is ON");
        require(tokens > 0, "Not enough Token");
        require(amount >= minPurchase, "Not enough Token");
        uint256 price;
        if(nftToken.balanceOf(msg.sender) >= 5){
            price = tokenPrice * (divider - nftBoost[5]) / divider;//100    -10%
            tokens = tokens.add(tokens * nftBoost[5] / divider);
        } else if(nftToken.balanceOf(msg.sender) >= 3){
            price = tokenPrice * (divider - nftBoost[3]) / divider;//80
            tokens = tokens.add(tokens * nftBoost[3] / divider);
        } else if(nftToken.balanceOf(msg.sender) >= 1){
            price = tokenPrice * (divider - nftBoost[1]) / divider;//70
            tokens = tokens.add(tokens * nftBoost[1] / divider);
        }
        else {price = tokenPrice;}

            require(amount >= price * (tokens / (10 ** uint256(_decimals))), "Wrong Amount!");
            require(maxLimitWallet[msg.sender].add(amount) <= maxLimit, "Limit reached");
            maxLimitWallet[msg.sender] = maxLimitWallet[msg.sender].add(amount);
       
        address _holder = msg.sender;

        referralAddress[msg.sender]=true;
        
        uint256 fee;//referral Fee
        if((referralAddress[_referral] == true) && (_referral!=msg.sender) && (referralPair[msg.sender]==address(0)) ){//
            referralPair[msg.sender]=_referral;
            referralList.push(_referral);
            fee = amount.mul(referralFee).div(divider);
            payable(_referral).transfer(fee * 50 / 100);// -> 1/2 1st level referral fees
            referralRewards[_referral] += fee  * 50 / 100;
            referralArray[_referral].push(msg.sender);
            
                if(referralPair[_referral]!=address(0)){
                    payable(referralPair[_referral]).transfer(fee * 30 / 100);//-> 1/3 referral fees
                    referralRewards[referralPair[_referral]] += fee  * 30 / 100;
                    referralArray[referralPair[_referral]].push(msg.sender);
                }

                if(referralPair[referralPair[_referral]]!=address(0)){
                    payable(referralPair[referralPair[_referral]]).transfer(fee * 20 / 100);//-> 1/5 referral fees
                    referralRewards[referralPair[referralPair[_referral]]] += fee  * 20 / 100;
                    referralArray[referralPair[referralPair[_referral]]].push(msg.sender);
                }

            tokens = tokens.add(tokens.mul(referralTokenPrize).div(divider)); // % for referral 
            totReferralRewards= totReferralRewards.add(fee);
        }
        
        buybackFeesAmount +=amount.mul(buybackFeeRate).div(divider);//buyBack fee
        
        projectWallet.transfer(amount.mul(projectFeeRate).div(divider));
        
        minerTokenIds[_holder]+=1;
        minerDateOwner[_holder][minerTokenIds[_holder]] = block.timestamp;
        minerTokenAmountOwner[_holder][minerTokenIds[_holder]] = tokens;        
        purchasedBNB[_holder] += amount;

        _mint(_holder,tokens);
        return true;
    }

    
     /* Function claim burns Token*/

    function claimRewards () public virtual returns (bool ){
        address payable _holder = payable(msg.sender);
        require(claimDateLast[_holder] <= block.timestamp.sub(intervalRewardTime), "Only once a day");

        uint256 balanceMiner = balanceOf(_holder);
        uint256 rewards = claimCalculateOwnerReward (_holder);
        uint256 oneDayBnbReward = (balanceMiner * minerReward).div(divider).mul(tokenPrice).div(10 ** decimals());
        rewards = min(rewards,oneDayBnbReward);
           uint256 fee = rewards.mul(projectFeeRate).div(divider);
            projectWallet.transfer(fee);
            uint256 feeBB = rewards.mul(buybackFeeRate).div(divider);
            buybackFeesAmount += feeBB;//contract exit fee
            
            fee = fee.add(feeBB);
            _holder.transfer(rewards.sub(fee));
            withdrawnBNBrewards[_holder] += rewards.sub(fee);

            earnedBNBDate[_holder].push(block.timestamp);
            earnedBNB[_holder] = earnedBNB[_holder].add(rewards.sub(fee));
            totRewards = totRewards.add(rewards.sub(fee));
            claimDateLast[_holder]=block.timestamp;

            //if rewards withdrawn by holder > 250% invested the position will be closed
            if(withdrawnBNBrewards[_holder] >= purchasedBNB[_holder].mul(250).div(100)){
                exitFromPool(_holder);
            }

        return true;
    }

    function exitFromPool (address _holder) private returns (bool){
        uint256 balanceMiner = balanceOf(_holder);

        for (uint i=1; i <= minerTokenIds[_holder]; i++) {
            minerDateOwner[_holder][i] = 0;
            minerTokenAmountOwner [_holder][i] = 0;
        }
        
        minerTokenIds[_holder] = 0;
        compounded[_holder] = 0;    
            
            _burn(_holder,balanceMiner);

            maxLimitWallet[_holder]=0;
            rebuyied[_holder] = 0;
            withdrawnBNBrewards[_holder] = 0;
            purchasedBNB[_holder] = 0;
       return true;
    }
    mapping (address => uint256) claimDateLast;

    /* Calculate BNB Reward : this is called from claim function */
    function claimCalculateOwnerReward (address _holder) public view returns (uint256 ){
    uint256 reward = 0;
          if(minerTokenIds[_holder]>0){ 
            for (uint i=1; i <= minerTokenIds[_holder]; i++) {
                
                uint256 timeNow = min(END_REWARD, block.timestamp);
                uint256 timeToken = minerDateOwner[_holder][i];
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = minerTokenAmountOwner [_holder][i];
                reward += (amount.mul(intervals) * minerReward).div(divider);
                    if(intervals <= 6){
                    reward = reward.sub(rebaseAntiwhale(intervals,reward));
                        } 
                    }
                }
            }
        }
        
        reward = reward.mul(tokenPrice).div(10 ** decimals());//transform to BNB
        
        (bool check, uint256 rewardNet) = SafeMath.trySub(reward,withdrawnBNBrewards[_holder]);
        
        if(check && rewardNet > 0){
        reward = rewardNet;
        }else{
           reward = 0; 
        }
       return min(reward,getMaxBNBrewardsLeft(_holder));
    }

    function rebaseAntiwhale (uint256 interval, uint256 _reward) internal view returns (uint256 ){
        uint256 taxWhale = 0;
        if(interval <= 2){taxWhale = _reward.mul(80).div(divider);} 
        else if(interval <= 3){taxWhale = _reward.mul(40).div(divider);}
        else if(interval <= 6){taxWhale = _reward.mul(20).div(divider);}
                  
        return taxWhale;            
    }
    /* Calculate Reward Fractions : this is called only for dashboard showing DATAS 
    Rewards mature each 24h (intervalRewardTime uint256 var)
    This function shows rewards matured each 15 minutes but with Claim action only 24h matured rewards will be considered
    */
    function claimCalculateRewardFraction (address _holder) public view returns (uint256 ){
    uint256 reward = 0;
        if(minerTokenIds[_holder]>0){ 
            for (uint i=1; i <= minerTokenIds[_holder]; i++) {
                
                uint256 timeNow = min(END_REWARD, block.timestamp).mul(100);
                uint256 timeToken = minerDateOwner[_holder][i].mul(100);
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                if(intervals>0){
                uint256 amount = minerTokenAmountOwner [_holder][i];
                reward += (amount.mul(intervals) * minerReward).div(divider * 100); 
                        if(intervals <= 6){
                            reward = reward.sub(rebaseAntiwhale(intervals,reward));
                        }              
                    }
                }
            }
        }
        
        reward = reward.mul(tokenPrice).div(10 ** decimals());
        
        (bool check, uint256 rewardNet) = SafeMath.trySub(reward,withdrawnBNBrewards[_holder]);
        
        if(check && rewardNet > 0){
        reward = rewardNet;
        }else{
           reward = 0; 
        }
       return max(0,reward);
    }

    function getDateMinerAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
        return max(0,minerDateOwner[_holder][_index]);
    }

function getTokenMinerAtIndex (address _holder, uint256 _index) public view returns (uint256 ){
    return max(0,minerTokenAmountOwner[_holder][_index]);
}

function getMaxBNBrewardsLeft (address _holder) public view returns (uint256 rewardNet){
    (, rewardNet) = SafeMath.trySub(purchasedBNB[_holder].mul(250).div(100),withdrawnBNBrewards[_holder]);
    return rewardNet;
}

function getWithdrawnBNBrewards (address _holder) public view returns (uint256 ){
    return withdrawnBNBrewards[_holder];
}

function getNftBalance (address _holder) public view returns (uint256 ){
    return nftToken.balanceOf(_holder);
}

function getEarnedBNB (address _holder) public view returns (uint256 ){
    return max(0,earnedBNB[_holder]);
}

function setAdmin (address _admin, bool _isOn) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    admin[_admin] = _isOn;
    return _isOn;
}

/* this is the fee when you enter in the pool */
function setProjectFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee <= 50 , "Max fee 5%");
    projectFeeRate = _fee;
    return true;
}

function setReferralFee (uint256 _fee) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_fee >= 10 , "Minimal fee 1%");
    referralFee = _fee;
    return true;
}

function setEndReward (uint256 _date) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    END_REWARD = _date;
    return true;
}
function setTokenReward (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    minerReward = _reward;
    return true;
}
function setMinPurchase (uint256 _minWei) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_minWei <= 0.3 ether, "Minimal purchase can only be < 0.3 BNB");
    minPurchase = _minWei;
    return true;
}


function setIntervalRewardTime (uint256 _time) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    intervalRewardTime = _time;
    return true;
}

function setMinerIsON (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    minerIsON = _isLive;
    return _isLive;
}

function withdrawAdmin (uint256 _feesWei) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require(_feesWei <= buybackFeesAmount, "Max fees amount");
   
    buybackWallet.transfer(_feesWei);
    buybackFeesAmount = buybackFeesAmount.sub(_feesWei);
    return true;
} 

bool public rebuyIsOn = true;
mapping (address => uint256) public rebuyied;
mapping (address => uint256) rebuyDateLast;

function reBuy () public returns (uint256){
        require(rebuyIsOn == true, "rebuy is OFF");
        address _holder = msg.sender;
        require(rebuyDateLast[_holder] <= block.timestamp.sub(intervalRewardTime), "Only once a day");

        uint256 _newBalance;
        uint256 rewards;
          if(minerTokenIds[_holder]<1){return 0;}

            for (uint i=1; i <= minerTokenIds[_holder]; i++) {
                _newBalance = _newBalance.add(minerTokenAmountOwner [_holder][i]);
                uint256 timeNow = min(END_REWARD, block.timestamp);
                uint256 timeToken = minerDateOwner[_holder][i];
                    if(timeToken>0){
                uint256 intervals = (timeNow.sub(timeToken )).div(intervalRewardTime);

                    if(intervals>0){
                    uint256 amount = minerTokenAmountOwner [_holder][i];
                    rewards = rewards.add( (amount.mul(intervals) * minerReward).div(divider) );
                        }           
                    }
                minerTokenAmountOwner [_holder][i] = 0;
                minerDateOwner[_holder][i] = 0;
            }
        _newBalance = _newBalance.add(rewards);
        minerTokenIds[_holder] = 1;
        minerDateOwner[_holder][minerTokenIds[_holder]] = block.timestamp;
        minerTokenAmountOwner[_holder][minerTokenIds[_holder]] = _newBalance;
        
        (bool check, uint256 balanceAdd) = SafeMath.trySub(_newBalance,balanceOf(_holder));
        
        if(check && balanceAdd > 0){
        _mint(_holder,balanceAdd);
        rebuyDateLast[_holder] = block.timestamp;
        rebuyied[_holder] ++;
        }
       return balanceAdd;
}  
function getRebuyLast (address _holder) public view returns (uint256 ){
    return rebuyDateLast[_holder];
}

function setRebuyIsOn (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    rebuyIsOn = _isLive;
    return _isLive;
}



bool public compoundIsOn = false;
mapping (address => uint256) compounded;
uint256 compoundRate = 1000;// 100%
mapping (address => uint256) compoundDateLast;

 /* Calculate Token Reward */
function compoundCalculate (address _holder) public view returns (uint256){
    uint256 rewards = claimCalculateOwnerReward(_holder).div(tokenPrice).mul(10 ** decimals());
    return rewards;
}    
function compoundRewards () public returns (uint256){
        require(compoundIsOn == true, "Compound is OFF");
        address _holder = msg.sender;
        require(compoundDateLast[_holder] <= block.timestamp.sub(intervalRewardTime), "Only once a day");

        uint256 balanceRewards = compoundCalculate(_holder);
        require(balanceRewards > 0, "Not enough rewards to compound");
        uint256 compoundTokens = (balanceRewards.mul(compoundRate).div(divider));
        (bool check, uint256 compoundTokensAdd) = SafeMath.trySub(compoundTokens,compounded[_holder]);
        
        if(check && compoundTokensAdd > 0){
        compounded[_holder] += compoundTokensAdd;
        minerTokenIds[_holder] += 1;
        minerDateOwner[_holder][minerTokenIds[_holder]] = block.timestamp;
        minerTokenAmountOwner[_holder][minerTokenIds[_holder]] = compoundTokensAdd;
        _mint(_holder,compoundTokensAdd);
        compoundDateLast[_holder] = block.timestamp;
        }
       return compoundTokensAdd;
}    
function setCompoundIsOn (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    compoundIsOn = _isLive;
    return _isLive;
}
function setCompoundRate (uint256 _rate) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    compoundRate = _rate;
    return true;
}

function getCompounded(address _holder ) public view returns (uint256 )  {
    return compounded[_holder];
}

function setNftAddress (address _addr) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    nftToken = IGoalNFT(_addr);
    return true;
}

receive() external payable {
 depositedAmount+= msg.value;
}

}
contract GoalStar_Miner_Token is ERC20 {
  //Name symbol decimals  
    constructor() ERC20("GoalStar", "GOALS" , 18)  { //aggiornare nftAddress
    }
}