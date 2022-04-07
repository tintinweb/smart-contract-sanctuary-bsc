// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./SafeMathInt.sol";
import "./SafeMath.sol";
import "./owned.sol";
import "./UInt256Lib.sol";
import "./IERC20.sol";

contract RebaseToken is owned{
    using SafeMath for uint256;
    using UInt256Lib for int256;
    using SafeMathInt for int256;

///////////////////////////////////////////////////////////////////////////////////////////////////
/////////////                   EVENTS                                                 //////////
/////////////////////////////////////////////////////////////////////////////////////////////////

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    //event LogRebasePaused(bool paused);
    //event LogTokenPaused(bool paused);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);
     // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

/////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////// VARIABLES NEEDED FOR BASIC REBASE TOKEN OPERATIONS ///////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

    // Public variables of the token
    string public name;
    string public symbol;

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5000000 * 10**DECIMALS;

    // TOTAL_DINGS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _dingsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private constant TOTAL_DINGS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

   
    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 private _totalSupply;
    uint256 private _dingsPerFragment;

    mapping(address => uint256) private _dingBalances;

    mapping (address => mapping (address => uint256)) private _alloweddings;

    address public monetaryPolicy;
//////////////////////////////////////////////////////////////////////////////////////////////////
////////////// Modifiers/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }
//////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////
///////////// Initial Pools Setup ////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
    uint256 private intialpoollimit = 12000000*10**DECIMALS; 
    uint256 private poolduration;  

    struct assetInvestment{
        address userAddress;
        address tokenAddress;
        uint256 amount;
        uint256 timeofstake;
        uint256 lastclaimtime;
    }
    mapping (bytes32 => assetInvestment) public assetInvestments;

    uint256 private APY = 10;

///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////LP Setup//////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    address private lpaddress;
    address private stakinglpapy;



// This is denominated in Fragments, because the dings-fragments conversion might change before
    // it's fully paid.
 

    constructor(string memory tName, string memory tSymbol)  {
       name = tName;     // Set the name for display purposes
        symbol = tSymbol; 
        owner = msg.sender;                                     // Set the symbol for display purposes                    
    }   

    function initialize(address _monetaryPolicy)public onlyOwner {
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _dingBalances[address(this)] = TOTAL_DINGS;
        _dingsPerFragment = TOTAL_DINGS.div(_totalSupply);
        uint256 dingValue = (1*10**DECIMALS).mul(_dingsPerFragment);
        _transfer(address(this), owner, dingValue);
        monetaryPolicy=_monetaryPolicy;
        //_transfer(address(0x0),owner,TOTAL_DINGS);
        //emit Transfer(address(0x0),owner, _totalSupply);
    }

    function setPairAddress(address pair) public {
        lpaddress = pair;
    }

    function rebase(uint256 epoch, int256 supplyDelta) external onlyMonetaryPolicy returns (uint256) {
        if (supplyDelta >= 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } 


        // From this point forward, _dingssPerFragment is taken as the source of truth.
        // We recalculate a new _totalSupply to be in agreement with the _dingsPerFragment
        // conversion rate.
        // _totalSupply = TOTAL_DINGS.div(_dingssPerFragment)

         _dingsPerFragment = TOTAL_DINGS.div(_totalSupply);

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function totalSupply()   public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address who)   public view returns (uint256) {
        return _dingBalances[who].div(_dingsPerFragment);
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value) public validRecipient(to) returns (bool) {
        uint256 dingValue = value.mul(_dingsPerFragment);
        //_dingBalances[msg.sender] = _dingBalances[msg.sender].sub(dingValue);
        //_dingBalances[to] = _dingBalances[to].add(dingValue);
        _transfer(msg.sender, to, dingValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender) public view returns (uint256)  {
        return _alloweddings[owner_][spender].div(_dingsPerFragment);
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value) public validRecipient(to) returns (bool){
        require (_alloweddings[from][msg.sender]>=value.mul(_dingsPerFragment));
        _alloweddings[from][msg.sender] = _alloweddings[from][msg.sender].sub(value.mul(_dingsPerFragment));
        uint256 dingValue = value.mul(_dingsPerFragment);
        _dingBalances[from] = _dingBalances[from].sub(dingValue);
        _dingBalances[to] = _dingBalances[to].add(dingValue);
        _transfer(from,to,dingValue);
        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Approve tokens from one address to another.
     * @param spender is the address approve to spnd. 
     * @param value The amount of tokens to be transferred.
     */
    function approve(address spender, uint256 value) public returns (bool){
        _alloweddings[msg.sender][spender] = value.mul(_dingsPerFragment);
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * Internal transfer, only can be called by this contract. Its transfer value in dings
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0x0));
        // Check if the sender has enough
        require(_dingBalances[_from] >= _value);
        // Check for overflows
        require(_dingBalances[_to] + _value > _dingBalances[_to]);
        // Subtract from the sender
        _dingBalances[_from] -= _value;
        // Add the same to the recipient
        _dingBalances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function setMonetaryPolicy(address _monetaryPolicy) public onlyOwner returns(bool success){
        require (_monetaryPolicy != address(0x0));
        monetaryPolicy=_monetaryPolicy;
        return true;
    }

    /**
    * Only owner can change the limit of intial pool
    */

    function setIntialPoolLimit(uint256 limit) public onlyOwner{
        intialpoollimit = limit;
    }
    // function to start the Genesis Pool of the token
    function startPool(uint numberofdays) public onlyOwner{

        poolduration = block.timestamp +(numberofdays * 1 days);

    }
    // Get Key to store Investments
    function getPrivateUniqueKey(address contractAddress, address userAddress) private pure returns (bytes32){
        return keccak256(abi.encodePacked(contractAddress, userAddress));
    }

    function getInvestment(bytes32 uniqueKey) private view returns (assetInvestment memory){
        return assetInvestments[uniqueKey];
    }    

    function updateInvestment(assetInvestment memory investment, bytes32 uniqueKey ) private returns (assetInvestment memory){
        assetInvestments[uniqueKey] = investment;

        return investment;
    }

    function chkallowance(address tokenAddress) public view returns (uint256 allowedTokens){
        return IERC20(tokenAddress).allowance(msg.sender, address(this));
    }


    function investinpool (address tokenaddress, uint256 amount) public returns (assetInvestment memory){
        
        require (block.timestamp<poolduration, "Genesis Pool ended");
        require (amount > 0 , "Amount cannot be Zero");

        bytes32 uniqueKey = getPrivateUniqueKey(tokenaddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);

        IERC20(tokenaddress).transferFrom(msg.sender, address(this), amount);

        if(investment.amount == 0)
        {
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenaddress;
            investment.amount= amount; 
            investment.timeofstake= block.timestamp;
            investment.lastclaimtime = block.timestamp;
        }
        else
        {
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenaddress;
            investment.amount += amount; 
        }

        return updateInvestment(investment, uniqueKey);

    }

    function getEarnedRewards(address tokenAddress) public view returns (uint256 rewards){
        
       return  calculateRewards(tokenAddress, msg.sender);

    }

    function claimRewards(address tokenAddress) public {

        uint256 rewards = calculateRewards(tokenAddress, msg.sender);
        uint256 dingValue = rewards.mul(_dingsPerFragment);
        _transfer(address(this),msg.sender,dingValue);

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);
        investment.lastclaimtime=block.timestamp;
        updateInvestment(investment, uniqueKey);
    }

    function calculateRewards(address tokenAddress, address investor) private view returns(uint256 rewards){

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, investor);
        assetInvestment memory investment = getInvestment(uniqueKey);

        uint256 timenow = block.timestamp;

        uint256 numofminutes = (timenow-investment.lastclaimtime) * 1 minutes;
        require (numofminutes >= 1,"Rewards are distributed every minute");

        return (investment.amount.mul(APY)).div(100);
    }

    function withdrawRewards(address tokenAddress, uint256 withdrawAmount) public {

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);
        require (withdrawAmount <= investment.amount, "Invalid amount");

        claimRewards(tokenAddress);

        investment.amount -= withdrawAmount;
        updateInvestment(investment, uniqueKey);
    }

    function getInvestment(address tokenAddress, address investorAddress) public view returns(assetInvestment memory){
        
        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, investorAddress);
        return getInvestment(uniqueKey);

    }

    function stakeLp(address tokenAddress, uint256 amount) public returns (assetInvestment memory){
        require (tokenAddress==lpaddress, "Only Str-Busd-LP can be staked");
        require (amount > 0 , "Amount cannot be Zero");

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        if(investment.amount == 0)
        {
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenAddress;
            investment.amount= amount; 
            investment.timeofstake= block.timestamp;
            investment.lastclaimtime = block.timestamp;
        }
        else
        {
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenAddress;
            investment.amount += amount; 
        }

        return updateInvestment(investment, uniqueKey);
    }
    
}