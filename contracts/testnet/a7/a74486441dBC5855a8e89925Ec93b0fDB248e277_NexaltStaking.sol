// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./SafeMath.sol";
//import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
//import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract NexaltStaking {
  using SafeMath for uint256;
    string public name; // Holds the name of the token
    string public symbol; // Holds the symbol of the token
    uint8 public decimals; // Holds the decimal places of the token
    uint256 public totalSupply; // Holds the total suppy of the token
    address payable public owner; // Holds the owner of the token
    uint256 private lastHalvedTime; //Holds the reward halving time
    uint256 private rewardAmount = 40; //Holds the reward amount
    uint256 private mlcReward = 20; // Holds the mlc reward amount
    uint256 private halvingInterval = 2073600 minutes; //Holds the halving interval

    /* This creates a mapping with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates a mapping of accounts with allowances */
    mapping (address => mapping (address => uint256)) public allowance;
    /* This event is always fired on a successfull call of the
    transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approve(address indexed owner, address indexed spender, uint256 value);
    //We usually require to know who are all the stakeholders.
    address[] internal stakeholders;
    //@notice To hold sponsors keys against every stake holder
    mapping(address => address) internal sponsor;
    //@notice The stakes for each stakeholder.
    mapping(address => uint256) internal stakes;
    //@notice The stakes for each stakeholder who stakes BNB.
    mapping(address => uint256) internal stakesBNB;
    //@notice The accumulated rewards for each stakeholder.
    mapping(address => uint256) internal rewards;

    mapping(address => uint256) internal lastRewardWithDraw;

    constructor() {
        name = "Nexalt"; // Sets the name of the token, i.e Ether
        symbol = "XLT"; // Sets the symbol of the token, i.e ETH
        decimals = 18; // Sets the number of decimal places
        uint256 _initialSupply = 1000000000000000000000; // Holds an initial supply of coins
        owner = payable(msg.sender); //Sets the owner of the token to whoever deployed it
        balanceOf[owner] = _initialSupply; // Transfers all tokens to owner
        totalSupply = _initialSupply; // Sets the total supply of tokens
        lastHalvedTime = block.timestamp;

        /* Whenever tokens are created, burnt, or transfered,
            the Transfer event is fired */
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");

        balanceOf[msg.sender] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool success) {
        uint256 senderBalance = balanceOf[msg.sender];
        uint256 fromAllowance = allowance[_from][msg.sender];
        uint256 receiverBalance = balanceOf[_to];

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(senderBalance > _value, "Not enough balance");
        require(fromAllowance >= _value, "Not enough allowance");

        balanceOf[_from] = senderBalance - _value;
        balanceOf[_to] = receiverBalance + _value;
        allowance[_from][msg.sender] = fromAllowance - _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_value > 0, "Value must be greater than 0");

        allowance[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _amount) internal returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        totalSupply += _amount;
        balanceOf[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }

    function burn(uint256 _amount) internal returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balanceOf[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balanceOf[msg.sender] -= _amount;
      totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }

    //Staking 
    //anyone with token balance can add stake
    function addStake(address _sponsorKey , uint256  _stakeValue) public {
        uint256 senderBalance = balanceOf[msg.sender];
        bool isSponsor = isSponsorAddress(_sponsorKey);
        
        require(senderBalance > _stakeValue, "Not enough balance");

        if(isSponsor){
            addSponsor(_sponsorKey);
            if(stakes[msg.sender] == 0) addStakeHolder(msg.sender);
            stakes[msg.sender] = stakes[msg.sender].add(_stakeValue);
            lastRewardWithDraw[msg.sender] = block.timestamp;
            
            burn(_stakeValue);
        }else{
            revert("Given key is not sponsors key please add valid sponsor key");
        }
    }
 
    //Staking BNB 
    function addStakeBNB(address _sponsorKey , uint256  _stakeValue) external payable {
        bool isSponsor = isSponsorAddress(_sponsorKey);
        
        require(msg.value != _stakeValue, "Not Enough BNB");

        if(isSponsor){
            addSponsor(_sponsorKey);
            if(stakesBNB[msg.sender] == 0) addStakeHolder(msg.sender);
            stakesBNB[msg.sender] = stakesBNB[msg.sender].add(_stakeValue);
            lastRewardWithDraw[msg.sender] = block.timestamp;
            
            burn(_stakeValue);
        }else{
            revert("Given key is not sponsors key please add valid sponsor key");
        }
    }

    //anyone who has added stake can remove their stakes
    function removeStake(uint256 _stake)
        public
    {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);

        if(_isStakeholder){
            require(stakes[msg.sender] >= _stake , "Dont have enogh Stakes to remove");
            stakes[msg.sender] = stakes[msg.sender].sub(_stake);
            mint(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        }
    }

    //anyone who has added BNB stake can withdraw BNB
    function removeStakeBNB(uint256 _stake)
        external
    {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);

        if(_isStakeholder){
            require(stakesBNB[msg.sender] >= _stake , "Dont have enogh Stakes to remove");
            stakesBNB[msg.sender] = stakesBNB[msg.sender].sub(_stake);
            //mint(_stake);
            payable(msg.sender).transfer(_stake);
            if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        }
    }

    //find the number of xlt's user staked
    function stakedXLTOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }

    //find the number of BNB's user staked
    function stakedBNBOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakesBNB[_stakeholder];
    }

    //total stakes users added
    function totalStakedXLT()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    //total stakes users added
    function totalStakedBNB()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakesBNB[stakeholders[s]]);
        }
        return _totalStakes;
    }

    //removing stake holders
    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    //Sponsor checking
    /**
     * @notice checking that the given address is eligible sponsor.
     * @param _address the addrress of the sponsor to check eligibility.
     */
    function isSponsorAddress(address _address) internal view returns(bool){
        if(_address != 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2){
            if(sponsor[_address] == 0x0000000000000000000000000000000000000000){
                return false;
            }else{
                return true;
            }
        }else{
            return true;
        }
    }

    /**
     * @notice adding sponsor to give rewards.
     * @param _sponsor the addrress of the sponsor to be added.
     */
    function addSponsor(address _sponsor) internal {
        sponsor[msg.sender] = _sponsor;
    }

    /*adding stakeholders address in stake holders list
    *@param _stakeholder the address of stakeholder
    */
    function addStakeHolder(address _stakeholder) internal {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /*to check address is stake holder
    *@param _address to check is stake holder
    */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    //Rewards Distributions
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return rewards[_stakeholder];
    }

    function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    function withdrawReward()
    public
    {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        if(_isStakeholder){
            calculateReward();
            uint256 reward = rewards[msg.sender];
            require (reward > 0 ,"You are not eligible for reward withdraw");
            mint(reward);
            rewards[msg.sender] = 0;
        }else{
            revert("Not a valid stake holder");
        }
    }

    function calculateReward()
        internal
    {
        uint256 _halvingInterval =  block.timestamp - lastHalvedTime;
        if(_halvingInterval > halvingInterval) {
            lastHalvedTime = block.timestamp;
            rewardAmount = rewardAmount / 2;
            mlcReward = mlcReward / 2;
        }
        
        uint256 laswithDraw = lastRewardWithDraw[msg.sender];
        uint256 numberOfRewards = (block.timestamp - laswithDraw)/(2.5 minutes);
        //require (numberOfRewards >= 1 ,"You are not eligible for reward withdraw");
        uint256 rewardToWithDraw = numberOfRewards * rewardAmount; 
        uint256 mlcRewardToWithDraw = numberOfRewards * mlcReward; 
        rewards[msg.sender] = rewards[msg.sender].add(rewardToWithDraw);
        lastRewardWithDraw[msg.sender] = block.timestamp;
       
        address SponsorAddress = sponsor[msg.sender];
        for (uint256 ii = 0 ; ii < 10 ; ii += 1){
            rewards[SponsorAddress] = rewards[SponsorAddress].add(mlcRewardToWithDraw);
            SponsorAddress = sponsor[SponsorAddress];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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