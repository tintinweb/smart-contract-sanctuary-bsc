/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _operator;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _operator = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOperator() {
        require(_operator == _msgSender(), "Ownable: caller is not the operator");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function changeOperator(address newOperator) public virtual onlyOwner {
        _operator = newOperator;
    }
}

contract GodDragonGold is Ownable, ReentrancyGuard {
    //address private GOD  = 0xd14791Bf63AeAB3903d5112BBF13993230D057b4;
    address private BUSD = 0xBcE69a42462A781650a92c5143D425244dBDacd8;

    //IUniswapV2Pair private godPair  = IUniswapV2Pair(0x67a6DCA182A3E3554853D699e4f8210DcE986294);
    IUniswapV2Pair private busdPair = IUniswapV2Pair(0xf8504B31808C9652E9BC76022f219972F81c810C);

    uint256 private nonce;
    uint256 public  rate = 1000;
    uint256 public  cashOutAmount = 20_000;
    uint256 public  minimumBuy = 5_000;

    bool private isPaused;

    struct Partner {
        address tokenAddress;
        IUniswapV2Pair pair;
        uint256 depositFee;
        uint256 withdrawFee;
    }

    Partner[] public partnerInfo;

    event BuyGold(address indexed user, uint256 amount, uint256 nonce, address currency, uint256 tokenAmount);
    event CashOut(address indexed user, uint256 amount, uint256 nonce, address currency, uint256 tokenAmount);

    constructor( ) {
        setPartner(Partner(0xd8f5Ee82d444182a48eB73d01F21B79bCe22D28d, IUniswapV2Pair(0xE33F17647Fa2623B6d4BacAEe4c5F5DA05399108), 0,  0));
        setPartner(Partner(0x614c7e8E035379355D687B1db4709D65Ce5Bc8C1, IUniswapV2Pair(0xcb02B8e8793134513a01643EBd0ea93cD29B6CBe), 10, 10));
        setPartner(Partner(0x5dc7b08054F2fa2a888DFCfB25f4E51fA9dA4913, IUniswapV2Pair(0x8d6ca9BF65435f9eAADA7e5e5FaF75B2aa1e2c00), 15, 15));
        changeOperator(0x60D07c772fb4b3c09Fac6F3306Ff96D54Cb053eF);
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function buyGold(uint256 amountGold, uint256 partnerID) external nonReentrant {
        require(amountGold >= minimumBuy, "Under minimum buy amount");
        address token = partnerInfo[partnerID].tokenAddress;
        uint256 tax   = partnerInfo[partnerID].depositFee;

        uint256 tokenAmount = tokenAmountForDragonGold(partnerID, amountGold);
        tokenAmount += ((tokenAmount * tax) / 100);

        require(IERC20(token).balanceOf(msg.sender) >= tokenAmount , "Not enough balance to buy");

        IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);

        emit BuyGold(msg.sender, amountGold, nonce, token, tokenAmount);
        nonce++;
    }

    function cashOut(address user, uint256 partnerID) external onlyOperator{
        address token = partnerInfo[partnerID].tokenAddress;
        uint256 tax   = partnerInfo[partnerID].withdrawFee;

        uint256 tokenAmount = tokenAmountForDragonGold(partnerID, cashOutAmount);
        tokenAmount -= ((tax * tokenAmount) / 100);

        require(IERC20(token).balanceOf(address(this)) >= tokenAmount , "Not enough tokens inside the contract");
        IERC20(token).transfer(user, tokenAmount);

        emit CashOut(msg.sender, cashOutAmount, nonce, token, tokenAmount);
        nonce++;
    }

    function setCashOutAmount(uint256 amount) external onlyOwner {
        cashOutAmount = amount;
    }

    function setMinimumBuy(uint256 amount) external onlyOwner {
        minimumBuy = amount;
    }

    function setPartner(Partner memory newPartner) public onlyOwner{
        partnerInfo.push(newPartner);
    }

    function setPartnerFess(uint256 partnerID, uint256 depositFee, uint256 withdrawFee) public onlyOwner {
        partnerInfo[partnerID].depositFee = depositFee;
        partnerInfo[partnerID].withdrawFee = withdrawFee;
    }

    function changeTicketRate(uint256 newRate) public onlyOwner{
        rate = newRate;
    }

    function pause(bool value) public onlyOwner{
        isPaused = value;
    }

    function tokenAmountForDragonGold(uint256 partnerID, uint256 amountGold) public view returns(uint256){
        uint256 bnbInBusdPair;
        uint256 busdInBusdPair;
        uint256 BNB;
        uint256 Token;

        uint8 decimals = IERC20Metadata(partnerInfo[partnerID].tokenAddress).decimals();
        
        if(address(busdPair.token0()) == BUSD)
            (busdInBusdPair, bnbInBusdPair,  ) = busdPair.getReserves();
        else
            (bnbInBusdPair, busdInBusdPair, ) = busdPair.getReserves();
            
        uint256 aDollarWorthOfBNB = (bnbInBusdPair * 1e18) / busdInBusdPair;

        if(address(partnerInfo[partnerID].pair.token0()) == partnerInfo[partnerID].tokenAddress)
            (Token, BNB,) = partnerInfo[partnerID].pair.getReserves();
        else
            (BNB, Token,) = partnerInfo[partnerID].pair.getReserves();

        uint256 aTokenWorthOfBNB = (BNB * (10 ** decimals)) / Token;

        uint256 aDollarWorthOfToken = (aDollarWorthOfBNB * (10 ** decimals))/ aTokenWorthOfBNB;

        return ((aDollarWorthOfToken * amountGold) / rate);
    }
}