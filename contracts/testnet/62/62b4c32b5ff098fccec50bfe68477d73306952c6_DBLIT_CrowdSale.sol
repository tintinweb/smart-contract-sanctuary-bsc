/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
    mapping (address => bool) authorized;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
        authorized[_msgSender()] = true; 
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
        require(owner() == _msgSender() || authorized[_msgSender()] == true , "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DBLIT_CrowdSale is Ownable {
    
    address public tokenAddress; // Token address
    IBEP20 token = IBEP20(tokenAddress);
    
    mapping (address => uint256) public presaleInvestments;
    mapping (address => uint256) public tokensAllocated;
    mapping(address => bool) public presaleEligible;

    uint256 public presaleInvestorsCount;
    uint256 public tokenSold;
    uint256 public fundsRaised;
    uint256 public fundsClaimed;
    uint256 public tokensClaimed;

    uint256 public currentRound;
    
    uint256 public minContribution;
    uint256 public maxContribution;

    uint256 public softcap; 
    uint256 public hardcap; 
    
    uint256 public presaleRate;
    uint256 public dexListingRate;

    uint256 public startTime = block.timestamp;
    uint256 public endTime = block.timestamp + 8 days;

    uint256 public lockedBNBbalance;
    bool public presaleFinalized = false;
    bool public presaleWhiteListRequired = true;
    bool public releaseTokens = false;
    bool isPaused = true;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensClaimed(address indexed buyer, uint256 amount);
    
    modifier unpaused() {
        require(isPaused == false , "The contract is paused");
        _;
    }

    constructor () {
        setTokenAddress(0x54c7c2616E4bc1cCF5A857e0cEAb9E0427a97342);
    }

    function startRound1() public onlyOwner {
        unpause();
        setCurrentRound(1);
        setMinContribution(0.53 ether);
        setMaxContribution(13.2 ether);
        setPresaleRate(7600);
        setDexListingRate(2535);
        setSoftcap(0);
        setHardcap(1320);
        setStartTime(block.timestamp);
        setEndTime(block.timestamp + 12 days);
    }

    function startRound2() public onlyOwner {
        unpause();
        setCurrentRound(2);
        setMinContribution(0.53 ether);
        setMaxContribution(13.2 ether);
        setPresaleRate(4750);
        setDexListingRate(2535);
        setSoftcap(0);
        setHardcap(2640);
        setStartTime(block.timestamp);
        setEndTime(block.timestamp + 12 days);
    }

    function startRound3() public onlyOwner {
        unpause();
        setCurrentRound(3);
        setMinContribution(0.53 ether);
        setMaxContribution(13.2 ether);
        setPresaleRate(3800);
        setDexListingRate(2535);
        setSoftcap(0);
        setHardcap(3960);
        setStartTime(block.timestamp);
        setEndTime(block.timestamp + 12 days);
    }
    
    function setCurrentRound (uint256 _currentRound) public onlyOwner {
        currentRound = _currentRound;
    }

    function setMinContribution (uint256 _minContribution) public onlyOwner {
        minContribution = _minContribution;
    }

    function setMaxContribution (uint256 _maxContribution) public onlyOwner {
        maxContribution = _maxContribution;
    }
    
    function setSoftcap (uint256 _softcap) public onlyOwner {
        softcap = _softcap * 10 ** token.decimals();
    }

    function setHardcap (uint256 _hardcap) public onlyOwner {
        hardcap = _hardcap ** token.decimals();
    }

    function setPresaleRate (uint256 _presaleRate) public onlyOwner {
        presaleRate = _presaleRate * 10 ** token.decimals();
    }

    function setDexListingRate(uint256 _dexListingRate) public onlyOwner{
        dexListingRate = _dexListingRate * 10 ** token.decimals();
    }
    
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
        token = IBEP20(_tokenAddress);
    }

    function setPresaleWhiteListRequired(bool _presaleWhiteListRequired) public onlyOwner {
        presaleWhiteListRequired = _presaleWhiteListRequired;
    }

    function setReleaseTokens(bool _setReleaseTokens) public onlyOwner {
        releaseTokens = _setReleaseTokens;
    }

    function setStartTime(uint256 _startTime) public onlyOwner{
        startTime = _startTime;
    }

    function quickStartICO() public onlyOwner{
        startTime = block.timestamp;
    }
    
    function setEndTime(uint256 _endTime) public onlyOwner{
        endTime = _endTime;
    }

    function pause() public onlyOwner{
        isPaused = true;
    }

    function unpause() public onlyOwner{
        isPaused = false;
    }

    function quickEndICO() public onlyOwner{ //If anything goes wrong the ICO can be ended quickly to stop new investments and can be resumed later as required
        endTime = block.timestamp;
        pause();
    }

    function addToPresale(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Cannot add null address");

            presaleEligible[addresses[i]] = true;
        }
    }

    function checkPresaleEligiblity(address addr) public view returns (bool) {
        return presaleEligible[addr];
    }

    function invest() public payable unpaused returns (bool)  {
        if(presaleWhiteListRequired == true){
            require(checkPresaleEligiblity(msg.sender) == true, "You are not eligibale for presale");
        }

        require(startTime <= block.timestamp,"Presale is not started yet");
        require(presaleFinalized == false,"Presale is finalized, wait for the token listing on DEX and CEX");
        require(msg.value >= minContribution,"Amount is less than minimum contribution");
        require(msg.value <= maxContribution,"Amount is more than maximum contribution");
        require(endTime >= block.timestamp, "Presale has ended");
        require(fundsRaised <= hardcap, "Presale target is reached");
        
        uint amount = (msg.value * presaleRate)/1 ether;

        address investor = msg.sender;
        
        if(presaleInvestments[investor] > 0){
            presaleInvestorsCount++;
        }
        
        presaleInvestments[investor] = presaleInvestments[investor] + msg.value;
        tokensAllocated[investor] = amount;

        fundsRaised += msg.value;
        tokenSold += amount;
        
        emit TokensPurchased(investor, amount);
        return true;
    }

    function claimTokens() public unpaused {
        require (releaseTokens == true,'Tokens not released yet, You cannot claim tokens yet');
        address investor = msg.sender;
        uint256 amount = tokensAllocated[investor];
        tokensAllocated[investor] = 0;
        token.transfer(investor, amount);
        emit TokensClaimed(investor, amount);
    }

    //Temp function
    function calculateTokens(uint256 _amount) public view returns(uint256){
         return ((_amount * presaleRate)/1 ether);
    }
    
    //Temp function
    function getWeisValue() public view returns (uint256){
        return (1 * 10 ** token.decimals());
    }

    function getContractTokenBalance() public view returns(uint){
        return token.balanceOf(address(this));
    }
    
    function getUserTokenBalance() public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    
    function getBNBInvestment(address _address) external view returns(uint256){
        return presaleInvestments[_address];
    }

    function getTokenDecimals() external view returns(uint256){
        return token.decimals();
    }
    
    function authorize (address _authorizedAddress) external onlyOwner{
        authorized[_authorizedAddress] = true;
    }

    function unauthorize (address _authorizedAddress) external onlyOwner{
        authorized[_authorizedAddress] = false;
    }
    
    function withdrawUnsoldToken(address _withdrawAddress) external onlyOwner {
        require(token.balanceOf(address(this)) > 0,"Insufficient token balance");
        bool success = token.transfer(_withdrawAddress,token.balanceOf(address(this)));
        require(success, "Token Transfer failed.");
    }

    function withdrawBNB(address _withdrawalAddress) public onlyOwner {
        (bool success, ) = _withdrawalAddress.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function claimInvestment() external { // In case some problem occures and liquidity is not added on DEX (Pancakeswap), Investors can claim back the invested amount.
        require (block.timestamp > endTime + 3 days, 'Presale is not finalized yet');
        require (presaleFinalized == false,"Presale is finalized you can wait for DEX and CEX listing");
        require(presaleInvestments[msg.sender] > 0, "You do not have any Presale investments");
        (bool success, ) = msg.sender.call{value: presaleInvestments[msg.sender]}("");
        require(success, "Transfer failed.");
    }

    function refundInvestment(address _address) external onlyOwner { // In case some problem occures and liquidity is not added on DEX (Pancakeswap), Admin can refund back the invested amount.
        require(presaleInvestments[_address] > 0, 'User do not have any Presale investments');
        (bool success, ) = msg.sender.call{value: presaleInvestments[_address]}("");
        require(success, "Transfer failed.");
    }

    receive() external payable {
        invest();
    }
}