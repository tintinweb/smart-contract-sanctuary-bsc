/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface Factory {
  function addIgniteStaffWallet ( address _igniteStaffWallet ) external;
  function deployNewInstance ( address tokenAddress, uint256 tokenPrice, address _routerAddress, address _idoAdmin, uint256 _maxAmount, uint256 _tokenDecimals, uint256 _softcap, uint256 _hardcap, uint256 _liquidityToLock ) external;
  function getFeeAddress (  ) external view returns ( address );
  function igniteStaffAtIndex ( uint256 _index ) external view returns ( address );
  function igniteStaffContainsWallet ( address _wallet ) external view returns ( bool );
  function igniteStaffLength (  ) external view returns ( uint256 );
  function owner (  ) external view returns ( address );
  function presaleAtIndex ( uint256 _index ) external view returns ( address );
  function presalesLength (  ) external view returns ( uint256 );
  function removeIgniteStaffWallet ( address _igniteStaffWallet ) external;
  function renounceOwnership (  ) external;
  function seeFeeForBuy (  ) external view returns ( uint256 );
  function seeFeeForDeployment (  ) external view returns ( uint256 );
  function transferOwnership ( address newOwner ) external;
  function updateFeeAddress ( address newAddress ) external;
  function updateFeeForBuy ( uint256 newFee ) external;
  function updateFeeForDeployment ( uint256 newFee ) external;
  function withdrawFees (  ) external;
}


pragma solidity ^0.8.0;

contract IgniteIDO is ReentrancyGuard {

    // creating my structs


    struct BuyersData {
        uint256 contribution;
        uint256 owedTokens;
    }
    struct PresaleValues{
        uint256 maxAmount;
        uint256 softcap;
        uint256 hardcap;
        uint256 liquidityToLock;
        bool listed;
        uint256 phase;
    }
    struct TokenValues{
        //How many tokens do i get per bnb 18 decimals tokens can be calculated directly
        uint256 tokenPrice;
        uint256 tokenDecimals;
    }
    struct Addresses{
        address factoryAddress;
        address payable idoAdmin;
        address burnAddress;
        IERC20 tokenAddress;
        IUniswapV2Router02 routerAddress;
    }
    struct PublicSale{
        uint256 startBlock;
        uint256 endBlock;
    }
    struct Socials{
        bytes32 discord;
        bytes32 twitter;
        bytes32 telegram;
        bytes32 website;
        bytes32 imageURL;
        bytes32 description;
    }
    struct WhitelistSale{
        bool whitelist;
        uint256 whitelistStartBlock;
        uint256 whitelistEndBlock;
        uint256 paidSpots;
        uint256 currentWhitelistUsers;
        mapping(address=>bool) isWhitelisted;
    }
    struct Contributions{
        uint256 gweiCollected;
        uint256 contributorNumber;
    }
    struct Vetting{
        bool isVetted;
        uint256 vettingScore;
        bytes32 vettingCompany;
        bytes32 vettingDetails;

    }
    struct ContractInfo{
        PresaleValues presaleValues;
        TokenValues tokenValues;
        Addresses addresses;
        PublicSale publicSale;
        Socials socials;
        WhitelistSale whitelistSale;
        Contributions contributions;
        Vetting vetting;
    }

    // global variables

    ContractInfo contractInfo;
    mapping(address => BuyersData) Buyers;

    constructor (address _factory)  {
        // non-standard variable init
        contractInfo.addresses.factoryAddress = _factory;
        contractInfo.addresses.burnAddress = 0x000000000000000000000000000000000000dEaD;
        contractInfo.presaleValues.listed = true;
    }

    // set functions

    function presaleInit(
        IERC20 _tokenAddress,
        uint256 _tokenPrice,
        IUniswapV2Router02 _routerAddress,
        address payable _idoAdmin,
        uint256 _maxAmount,
        uint256 _tokenDecimals,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _liquidityToLock 
    )external{
        require(msg.sender==contractInfo.addresses.factoryAddress,"Only factory can init presale");
        contractInfo.addresses.tokenAddress = _tokenAddress;
        contractInfo.addresses.routerAddress = _routerAddress;
        contractInfo.addresses.idoAdmin = _idoAdmin;
        
        contractInfo.tokenValues.tokenDecimals = _tokenDecimals;
        contractInfo.tokenValues.tokenPrice = _tokenPrice;
        
        contractInfo.presaleValues.maxAmount = _maxAmount;
        contractInfo.presaleValues.softcap = _softcap;
        contractInfo.presaleValues.hardcap = _hardcap;
        contractInfo.presaleValues.liquidityToLock = _liquidityToLock;
    }

    // TODO: Let IDO admins fix first init variables if they messed up
    function setPublicSale(
        uint256 _startBlock,
        uint256 _endBlock
    )external{
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender) ,"Needs priviledged account");
        require(block.number <= _startBlock, "Public start time can't be in the past");
        require(block.number <= _endBlock,"Public end time can't be in the past");
        require(_startBlock < _endBlock,"Public end time can't be before the start time");
        contractInfo.publicSale.startBlock = _startBlock;
        contractInfo.publicSale.endBlock = _endBlock;
    }

    function setWhitelistSale(
        uint256 _paidSpots,
        uint256 _whitelistStartBlock,
        uint256 _whitelistEndBlock
    )external{
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender ),"Needs priviledged account");
        require(block.number <= _whitelistStartBlock, "Whitelist start time can't be in the past");
        require(block.number <= _whitelistEndBlock,"Whitelist end time can't be in the past");
        require(_whitelistStartBlock < _whitelistEndBlock,"Whitelist end time can't be before the start time");
        contractInfo.whitelistSale.whitelist = true;
        contractInfo.whitelistSale.paidSpots = _paidSpots;
        contractInfo.whitelistSale.whitelistStartBlock = _whitelistStartBlock;
        contractInfo.whitelistSale.whitelistEndBlock = _whitelistEndBlock;
    }

    function setSocials(
        bytes32 _discord,
        bytes32 _twitter,
        bytes32 _telegram,
        bytes32 _website,
        bytes32 _imageURL,
        bytes32 _description
    )external{
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender ),"Needs priviledged account");
        contractInfo.socials.discord = _discord;
        contractInfo.socials.twitter = _twitter;
        contractInfo.socials.telegram = _telegram;
        contractInfo.socials.website = _website;
        contractInfo.socials.imageURL = _imageURL;
        contractInfo.socials.description = _description;
    }

    function setVettedStatus(
        bool _isVetted, 
        uint256 _vettingScore, 
        bytes32 _vettingCompany, 
        bytes32 _vettingDetails
    ) external {
        require(this.isStaff(msg.sender),"Only Staff can do vetting");
        contractInfo.vetting.isVetted = _isVetted;
        contractInfo.vetting.vettingScore = _vettingScore;
        contractInfo.vetting.vettingCompany = _vettingCompany;
        contractInfo.vetting.vettingDetails = _vettingDetails;
    }

    // return functions

    function returnPresaleValues() external view returns(
        uint256 phase,
        uint256 maxAmount,
        uint256 softcap,
        uint256 hardcap,
        uint256 liquidityToLock,
        bool listed
    ){
        return(
            contractInfo.presaleValues.phase,
            contractInfo.presaleValues.maxAmount,
            contractInfo.presaleValues.softcap,
            contractInfo.presaleValues.hardcap,
            contractInfo.presaleValues.liquidityToLock,
            contractInfo.presaleValues.listed
        );
    }
    function returnTokenValues() external view returns(
        uint256 tokenPrice,
        uint256 tokenDecimals
    ){
        return(
            contractInfo.tokenValues.tokenPrice,
            contractInfo.tokenValues.tokenDecimals
        );
    }

    function returnAddresses() external view returns(
        address factoryAddress,
        address idoAdmin,
        address burnAddress,
        IERC20 tokenAddress,
        IUniswapV2Router02 routerAddress
    ){
        return(
            contractInfo.addresses.factoryAddress,
            contractInfo.addresses.idoAdmin,
            contractInfo.addresses.burnAddress,
            contractInfo.addresses.tokenAddress,
            contractInfo.addresses.routerAddress
        );
    }

    function returnPublicSaleInfo() external view returns(
        uint256 startBlock,
        uint256 endBlock
    ){
        return(
            contractInfo.publicSale.startBlock,
            contractInfo.publicSale.endBlock
        );
    }

    function returnSocials() external view returns(
        bytes32 discord,
        bytes32 twitter,
        bytes32 telegram,
        bytes32 website,
        bytes32 imageURL,
        bytes32 description
    ){
        return(
            contractInfo.socials.discord,
            contractInfo.socials.twitter,
            contractInfo.socials.telegram,
            contractInfo.socials.website,
            contractInfo.socials.imageURL,
            contractInfo.socials.description
        );
    }

    function returnWhitelistInfo() external view returns(
        bool whitelist,
        uint256 whitelistStartBlock,
        uint256 whitelistEndBlock,
        uint256 paidSpots,
        uint256 currentWhitelistUsers
    ){
        return(
            contractInfo.whitelistSale.whitelist,
            contractInfo.whitelistSale.whitelistStartBlock,
            contractInfo.whitelistSale.whitelistEndBlock,
            contractInfo.whitelistSale.paidSpots,
            contractInfo.whitelistSale.currentWhitelistUsers
        );
    }

    function returnContributions() external view returns(
        uint256 gweiCollected,
        uint256 contributorNumber
    ){
        return(
            contractInfo.contributions.gweiCollected,
            contractInfo.contributions.contributorNumber
        );
    }

    function returnVetting() external view returns(
        uint256 vettingScore,
        bytes32 vettingCompany,
        bytes32 vettingDetails
    ){
        return(
            contractInfo.vetting.vettingScore,
            contractInfo.vetting.vettingCompany,
            contractInfo.vetting.vettingDetails
        );
    }


    function isStaff(address _wallet) public view returns (bool){
        return Factory(contractInfo.addresses.factoryAddress).igniteStaffContainsWallet(_wallet);
    }

    function getbuyFee() public view returns (uint256){
        return Factory(contractInfo.addresses.factoryAddress).seeFeeForBuy();
    }

    // external functions

    function cancelSale() external {
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        contractInfo.presaleValues.phase = 4;
    }

    function withdrawBaseToken() external nonReentrant{
        require(contractInfo.presaleValues.phase == 4,"not a refund phase");
        address payable currentUser = payable(msg.sender);
        BuyersData storage contributionInfo = Buyers[msg.sender];
        uint256 userContribution = contributionInfo.contribution;
        require(userContribution>0 , "Not contributed");
        currentUser.transfer(userContribution);
        contributionInfo.contribution = 0;
    }
  
    function addToWhitelist (address newUser) external {
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        require(contractInfo.whitelistSale.currentWhitelistUsers <= contractInfo.whitelistSale.paidSpots, "No more whitelist spots");
        contractInfo.whitelistSale.isWhitelisted[newUser]=true;
        contractInfo.whitelistSale.currentWhitelistUsers+=1;
    }

    function whitelistMultipleAddresses(
         address [] memory accounts, 
         bool isWhitelist
    ) external {
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender) ,"Needs priviledged account");
        require(contractInfo.whitelistSale.currentWhitelistUsers <= contractInfo.whitelistSale.paidSpots, "No more whitelist spots");
        for(uint256 i = 0; i < accounts.length; i++) {
            contractInfo.whitelistSale.isWhitelisted[accounts[i]] = isWhitelist;
        }
    }

    function userDepositsWhitelist() external payable nonReentrant{//Phase =1 whitelist phase
        require(contractInfo.whitelistSale.whitelist,"not a whitelisted sale");
        require (block.timestamp >= contractInfo.whitelistSale.whitelistStartBlock && block.timestamp < contractInfo.whitelistSale.whitelistEndBlock,"not on time for whitelist");
        //require(_phase == 1,"presale not open yet");
        require(contractInfo.whitelistSale.isWhitelisted[msg.sender], "Not whitelisted");
        require(msg.value <= contractInfo.presaleValues.maxAmount, "Contribution needs to be in the minimum buy/max buy range");
        require(address(this).balance + msg.value <= contractInfo.presaleValues.hardcap, "Would overflow Hardcap");
        require(msg.value >= this.getbuyFee(),"Does not cover fees");
        
        BuyersData storage contributionInfo = Buyers[msg.sender];
        require( contributionInfo.contribution + msg.value <= contractInfo.presaleValues.maxAmount, "Cant contribute anymore");
        uint256 amountIn = msg.value;
        uint256 tokensSold = amountIn * contractInfo.tokenValues.tokenPrice;
        
        contributionInfo.contribution += msg.value;
        contributionInfo.owedTokens += tokensSold;
        contractInfo.contributions.gweiCollected += amountIn;
        contractInfo.contributions.contributorNumber+=1;
    }
 
    function userDepositPublicPhase() external payable nonReentrant {//Phase =2 public phase
        require(contractInfo.whitelistSale.whitelist,"not a whitelisted sale");
        //require(_phase==2,"Not on public _phase yet");
        require(msg.value <= contractInfo.presaleValues.maxAmount, "Contribution needs to be in the minimum buy/max buy range");
        require(address(this).balance + msg.value <= contractInfo.presaleValues.hardcap, "Would overflow Hardcap");
        require(msg.value >= this.getbuyFee(),"Does not cover fees");
        
        BuyersData storage contributionInfo = Buyers[msg.sender];
        
        require(contributionInfo.contribution + msg.value <= contractInfo.presaleValues.maxAmount,"Cant contribute anymore");
        uint256 amountIn = msg.value;
        uint256 tokensSold = amountIn * contractInfo.tokenValues.tokenPrice;
        contributionInfo.contribution += msg.value;
        contributionInfo.owedTokens += tokensSold;
        contractInfo.contributions.gweiCollected += amountIn;   
    }

    function getBlockInfo() external view returns(uint, uint){
        return (block.timestamp,block.number);
    }

    function checkContribution(address contributor) external view returns(uint256){
        BuyersData storage contributionInfo = Buyers[contributor];
        return contributionInfo.contribution;
    }

    function remainingContractTokens() external view returns (uint256) {
        return contractInfo.addresses.tokenAddress.balanceOf(address(this));
    }

    function updateTokenAddress(IERC20 newToken) external {
        require(this.isStaff(msg.sender));
        contractInfo.addresses.tokenAddress = IERC20(newToken);
    }

    function returnRemainingTokensInContract() external view returns(uint256){
        return contractInfo.addresses.tokenAddress.balanceOf(address(this));
    }
    
    function userIsWhitelisted(address userAddress) external view returns(bool){
        return contractInfo.whitelistSale.isWhitelisted[userAddress];
    }
    
    function setListed(bool value) external {
        require(this.isStaff(msg.sender));
        contractInfo.presaleValues.listed = value;
    }

    function removeListingIdoAdmin() external {
        require(msg.sender==contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        contractInfo.presaleValues.listed = false;
    }

    function startMarket() external {
        /*
        Approve balance required from this contract to pcs liquidity factory
        
        finishes ido status
        creates liquidity in pcs
        forwards funds to project creator
        forwards mcf fee to mcf wallet
        locks liquidity
        */
        require( msg.sender == contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        require( address(this).balance >= contractInfo.presaleValues.softcap, "market cant start, softcap not reached");
        uint256 amountForLiquidity = address(this).balance * contractInfo.presaleValues.liquidityToLock /100;

        addLiquidity(amountForLiquidity);
        contractInfo.presaleValues.phase = 3;
        
        uint256 remainingBaseBalance = address(this).balance;
        payable(contractInfo.addresses.idoAdmin).transfer(remainingBaseBalance);
    }

    function transferUnsold() external {
        require( msg.sender == contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        uint256 remainingCrowdsaleBalance = contractInfo.addresses.tokenAddress.balanceOf(address(this));
        contractInfo.addresses.tokenAddress.transfer(contractInfo.addresses.idoAdmin, remainingCrowdsaleBalance);
    }

    function ownerBaseTransfer(address payable destination) external {
        require( msg.sender == contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        uint256 currentBalance = address(this).balance;
        payable(destination).transfer(currentBalance);
    }
    
    function burnUnsold() public {
        require( msg.sender == contractInfo.addresses.idoAdmin || isStaff(msg.sender),"Needs priviledged account");
        uint256 remainingCrowdsaleBalance = contractInfo.addresses.tokenAddress.balanceOf(address(this));
        contractInfo.addresses.tokenAddress.transfer(payable(contractInfo.addresses.burnAddress),remainingCrowdsaleBalance);
    }

    //Contract shouldnt accept bnb/eth/etc thru fallback functions, pending implementation if its the opposite
    receive() external payable {
        //NA
    }

    function lockLiquidity() internal {
        /*liquidity Forwarder
        pairs reserved amount and bnb to create liquidity pool
        */
    }

    function withdrawTokens() public {
        //uint256 currentTokenBalance = tokenAddress.balanceOf(address(this));
        BuyersData storage buyer = Buyers[msg.sender];
        require(contractInfo.presaleValues.phase == 3 , "not ready to claim");
        uint256 tokensOwed = buyer.owedTokens;
        require(
            tokensOwed > 0,
            "No tokens to be transfered or contract empty"
        );
        contractInfo.addresses.tokenAddress.transfer(msg.sender, tokensOwed);
        buyer.owedTokens = 0;
    }

    function addLiquidity(uint256 bnbAmount) internal {
        //uint256 amountOfBNB = address(this).balance;
        uint256 amountOFTokens = contractInfo.addresses.tokenAddress.balanceOf(address(this));

        IERC20(contractInfo.addresses.tokenAddress).approve(address(contractInfo.addresses.routerAddress), amountOFTokens);

        (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        ) = IUniswapV2Router02(contractInfo.addresses.routerAddress).addLiquidityETH{
                value: bnbAmount
            }(
                address(contractInfo.addresses.routerAddress),
                amountOFTokens,
                0,
                0,
                contractInfo.addresses.idoAdmin,
                block.timestamp + 1200
            );
    }
}