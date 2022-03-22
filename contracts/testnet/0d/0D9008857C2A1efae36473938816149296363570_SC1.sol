/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: GPL-3.0 or later
pragma solidity ^0.8.5;

abstract contract Context {

    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    /**
     * @dev Returns message sender
     */
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    /**
     * @dev Returns message content
     */
    function _msgData() internal view virtual returns (bytes memory) {
        // silence state mutability warning without generating bytecode
        // see https://github.com/ethereum/solidity/issues/2691
        this;

        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IBEP20 {

    /**
     * @dev Emitted when `value` tokens are moved
     * from one account (`from`) to another account (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);


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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface ISC3{
    function update() external payable;
    function getAssetPrice() external view returns(uint);
}
interface ISC2{
    function transferEABCDForUser(address addr, uint256 amount) external;
}
interface IEABCD {
    function mint(address _to, uint256 amount) external returns (bool);
}
contract SC1 is Ownable {

    // address private _BUSDADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
    address public _BUSDADDRESS = 0xD7946143Da3d7B3e4127A4d9C36926df05b84863; //testnet
    address public _THALESADDRESS = 0x7E53cBAEcbBC85261fe5305dFf06590f98D75D04; //testnet
    address public _EABCDADDRESS = 0x0A50590a7F70990CAC0c97C93a4DE9e10dDbFC3e; //testnet
    address public _PANCAKEROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;  //testnet
    // address public _PANCAKEROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;  //mainnet
    address public _SC2ADDRESS = 0x6cd820795c2325a3c9e705AA44209032f6b96777;
    address public _SC3ADDRESS = 0x46aC104558d58D462Eed70E5FCE9b35720A07651;
    address public trustWallet;

    uint256 public plan_A_Fee = 1000;
    uint256 public plan_B_Fee = 500;
    uint256 public plan_C_Fee = 250;
    uint256 public plan_D_Fee = 125;

    uint256 public plan_A_Tokens = 10;
    uint256 public plan_B_Tokens = 100;
    uint256 public plan_C_Tokens = 1000;
    uint256 public plan_D_Tokens = 5000;

    uint256 public buybackFee = 50;

    address [] public whitelist_address;
    mapping (address => bool) private whitelist;
    mapping (address => uint256) private whitelist_amount;

    function depositBNB() public payable returns(bool){
        return true;
    }
    function withdrawBNB(uint256 amount) public onlyOwner{
        uint256 balanceOfBNB = address(this).balance;
        require (balanceOfBNB > amount, "Insufficient Amount");
        payable(trustWallet).transfer(amount);
        
    }
    function setBuyBackFee(uint256 amount) public onlyOwner{
        buybackFee = amount;
    }
    function setTrustWallet(address addr) public onlyOwner{
        trustWallet = addr;
    }
    function setBUSDAddress(address addr) public onlyOwner{
        _BUSDADDRESS = addr;
    }
    function setPancakeRouter(address addr) public onlyOwner{
        _PANCAKEROUTER = addr;
    }
    function setSC2Address(address addr) public onlyOwner{
        _SC2ADDRESS = addr;
    }
    function setSC3Address(address addr) public onlyOwner{
        _SC3ADDRESS = addr;
    }
    function setTHALESAddress(address addr) public onlyOwner{
        _THALESADDRESS = addr;
    }
    function setEABCAddress(address addr) public onlyOwner{
        _EABCDADDRESS = addr;
    }
    function setPlanAFee(uint256 fee) public onlyOwner{
        plan_A_Fee = fee;
    }
    function setPlanBFee(uint256 fee) public onlyOwner{
        plan_B_Fee = fee;
    }
    function setPlanCFee(uint256 fee) public onlyOwner{
        plan_C_Fee = fee;
    }
    function setPlanDFee(uint256 fee) public onlyOwner{
        plan_D_Fee = fee;
    }
    function setPlanATokens(uint256 amount) public onlyOwner{
        plan_A_Tokens = amount;
    }
    function setPlanBTokens(uint256 amount) public onlyOwner{
        plan_B_Tokens = amount;
    }
    function setPlanCTokens(uint256 amount) public onlyOwner{
        plan_C_Tokens = amount;
    }
    function setPlanDTokens(uint256 amount) public onlyOwner{
        plan_D_Tokens = amount;
    }
    function getBalanceOfBUSD() public view returns(uint256){
        uint256 balance = IBEP20(_BUSDADDRESS).balanceOf(address(this));
        return balance;
    }
    function transferBUSD(uint256 amount) public onlyOwner{
        uint256 balance = IBEP20(_BUSDADDRESS).balanceOf(address(this));
        require(balance > amount, "Insufficient Amount");
        IBEP20(_BUSDADDRESS).transfer(trustWallet, amount);
    }


    function buyOrder(uint256 amount) public{
        
        uint256 BUSD_decimal = IBEP20(_BUSDADDRESS).decimals();
        uint256 eABCD_decimal = IBEP20(_EABCDADDRESS).decimals();

        uint256 feeForBuyer = _getFeeForBuyer(msg.sender);
        uint256 priceFromOracle = ISC3(_SC3ADDRESS).getAssetPrice();
        uint256 allowance = IBEP20(_BUSDADDRESS).allowance(msg.sender, address(this));
        require(whitelist[msg.sender], "not approve SC1 yet");
        require(feeForBuyer > 0, "not enough THALES");
        require(allowance >= amount, "approve issue");
        require(priceFromOracle > 0, "price from oracle not update");
        ISC2(_SC2ADDRESS).transferEABCDForUser(msg.sender, amount * (100 * 1000 - feeForBuyer) * (10 ** eABCD_decimal) / (10 ** BUSD_decimal)/  1000 / 100 / priceFromOracle);
        IBEP20(_BUSDADDRESS).transferFrom(msg.sender, address(this), amount);
        swapBUSDForTHALES(amount * feeForBuyer * buybackFee / 1000 / 100 / 100 );
        IBEP20(_BUSDADDRESS).transfer(_SC2ADDRESS, amount * feeForBuyer * (100 - buybackFee) / 1000 / 100 / 100);

    }

    function swapBUSDForTHALES(uint256 amount) internal{
        address[] memory path = new address[](2);
        path[0] = address(_BUSDADDRESS);
        path[1] = address(_THALESADDRESS);

        IBEP20(_BUSDADDRESS).approve(address(_PANCAKEROUTER), amount);

        IPancakeRouter02(_PANCAKEROUTER).swapExactTokensForTokens(
            amount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp * 2
        );
    }

    function airDropTHALES() public {
        uint256 amount = IBEP20(_THALESADDRESS).balanceOf(address(this));
        require(amount > 0 , "no THALES token");
        uint256 totalTHALESForWhitelist = 0;
        for(uint i=0; i<whitelist_address.length; i++){
            if(whitelist[whitelist_address[i]]){
                uint256 balance = IBEP20(_THALESADDRESS).balanceOf(whitelist_address[i]);
                whitelist_amount[whitelist_address[i]] = balance;
                totalTHALESForWhitelist += balance;

            }
        }

        require(totalTHALESForWhitelist > 0, "totalTHALESForWhitelist 0");
        for(uint i=0; i<whitelist_address.length; i++){
            if(whitelist[whitelist_address[i]])
                IBEP20(_THALESADDRESS).transfer(
                    whitelist_address[i],
                    amount * whitelist_amount[whitelist_address[i]] / totalTHALESForWhitelist);
        }
    }
    function getFeeForBuyer(address seller) external view returns(uint256){
        return _getFeeForBuyer(seller);
    }
    function _getFeeForBuyer(address buyer) public view returns(uint256){
        uint256 balance = IBEP20(_THALESADDRESS).balanceOf(buyer);
        uint256 THALES_decimal = IBEP20(_THALESADDRESS).decimals();
        uint256 fee = 0;
        if(balance >= plan_A_Tokens * 10 ** THALES_decimal && balance < plan_B_Tokens * 10 ** THALES_decimal)
            fee = plan_A_Fee;
        if(balance >= plan_B_Tokens * 10 ** THALES_decimal && balance < plan_C_Tokens * 10 ** THALES_decimal)
            fee = plan_B_Fee;
        if(balance >= plan_C_Tokens * 10 ** THALES_decimal && balance < plan_D_Tokens * 10 ** THALES_decimal)
            fee = plan_C_Fee;
        if(balance >= plan_D_Tokens * 10 ** THALES_decimal)
            fee = plan_D_Fee;
        return fee;
    }

    function assignToContract() public {
        require(!whitelist[msg.sender], "already assigned");
        whitelist_address.push(msg.sender);
        whitelist[msg.sender] = true;
    }
    function getAssignToContractForUser(address addr)  external view returns(bool){
        return whitelist[addr];
    }
}