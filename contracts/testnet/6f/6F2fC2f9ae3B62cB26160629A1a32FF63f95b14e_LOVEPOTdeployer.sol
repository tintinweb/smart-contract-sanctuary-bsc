pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './PreSaleBnb.sol';

contract LOVEPOTdeployer is ReentrancyGuard {

    using SafeMath for uint256;
    address payable public admin;
    IERC20 public token;
    IERC20 public nativetoken;
    // address public locker;
    address public routerAddress;
    uint256 _liquiditylockduration;

    uint256 public adminFeePercent;
    uint256 public reffralPercent;
    uint256 public buybackPercent;

    mapping(address => bool) public isPreSaleExist;
    mapping(address => address) public getPreSale;
    address[] public allPreSales;

    modifier onlyAdmin(){
        require(msg.sender == admin,"LOVEPOT: Not an admin");
        _;
    }

    event PreSaleCreated(address indexed _token, address indexed _preSale, uint256 indexed _length);

    constructor() {
        admin = payable(msg.sender);
        adminFeePercent = 2;
        reffralPercent = 4;
        buybackPercent = 2;
        _liquiditylockduration = 90 days;
        nativetoken = IERC20(0xCB8BC53Ce1E690B4D5B60f7120006FdC626F87FC);
        routerAddress = (0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // locker = (0x7a22b885d83B2ac2c1e5428B115C8062aA8142Ea);
    }

    receive() payable external{}

    function createPreSaleBNB(
        IERC20 _token,
        uint256 [9] memory values
    ) external isHuman returns(address preSaleContract) {
        token = _token;
        require(address(token) != address(0), 'LOVEPOT: ZERO_ADDRESS');
        require(isPreSaleExist[address(token)] == false, 'LOVEPOT: PRESALE_EXISTS'); // single check is sufficient

        bytes memory bytecode = type(preSaleBnb).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token, msg.sender));

        assembly {
            preSaleContract := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IPreSale(preSaleContract).initialize(
            msg.sender,
            token,
            values,
            adminFeePercent,
            reffralPercent,
            buybackPercent,
            routerAddress,
            _liquiditylockduration,
            nativetoken
            // locker
        );
        
        uint256 tokenAmount = getTotalNumberOfTokens(
            values[0],
            values[7],
            values[5],
            values[8]
        );

        tokenAmount = tokenAmount.mul(10 ** (token.decimals()));
        token.transferFrom(msg.sender, preSaleContract, tokenAmount);
        getPreSale[address(token)] = preSaleContract;
        isPreSaleExist[address(token)] = true; // setting preSale for this token to aviod duplication
        allPreSales.push(preSaleContract);

        emit PreSaleCreated(address(token), preSaleContract, allPreSales.length);
    }

    function getTotalNumberOfTokens(
        uint256 _tokenPrice,
        uint256 _listingPrice,
        uint256 _hardCap,
        uint256 _liquidityPercent
    ) public pure returns(uint256){

        uint256 tokensForSell = _hardCap.mul(_tokenPrice).mul(1000).div(1e18);
        tokensForSell = tokensForSell.add(tokensForSell.mul(2).div(100));
        uint256 tokensForListing = (_hardCap.mul(_liquidityPercent).div(100)).mul(_listingPrice).mul(1000).div(1e18);
        return tokensForSell.add(tokensForListing).div(1000);

    }

    function setAdmin(address payable _admin) external onlyAdmin{
        admin = _admin;
    }

    function setRouterAddress(address _routerAddress) external onlyAdmin{
        routerAddress = _routerAddress;
    }
    
    function setAdminFeePercent(uint256 _adminFeePercent) external onlyAdmin{
        adminFeePercent = _adminFeePercent;
    }
    function setreffralPercent(uint256 _reffralPercent) external onlyAdmin{
        reffralPercent = _reffralPercent;
    }
    
    function getAllPreSalesLength() external view returns (uint) {
        if(allPreSales.length == 0){
            return allPreSales.length; 
        }
        else{
            return allPreSales.length-1;
        }
        
    }

    function getCurrentTime() public view returns(uint256){
        return block.timestamp;
    }

}

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './Interfaces/IERC20.sol';
import './Interfaces/ILocker.sol';
import './Interfaces/IPreSale.sol';
import './Interfaces/IPancakeswapV2Factory.sol';

contract preSaleBnb is ReentrancyGuard {

    using SafeMath for uint256;
    
    address payable public admin;
    address payable public tokenOwner;
    IERC20 public pair;
    // ILocker public locker;
    IERC20 public nativetoken;
    uint256 public liquidityunLocktime;
    uint256 public liquiditylockduration;
    address public deployer;
    IERC20 public token;
    IPancakeRouter02 public routerAddress;

    uint256 public adminFeePercent;
    uint256 public reffralPercent;
    uint256 public buybackPercent;
    uint256 public tokenPrice;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public hardCap;
    uint256 public softCap;
    uint256 public listingPrice;
    uint256 public liquidityPercent;
    uint256 public soldTokens;
    uint256 public preSaleTokens;
    uint256 public totalUser;
    uint256 public amountRaised;
    uint256 public refamountRaised;

    bool public allow;
    bool public canClaim;

    mapping(address => uint256) public tokenBalance;
    mapping(address => uint256) public bnbBalance;
    

    modifier onlyAdmin(){
        require(msg.sender == admin,"LOVEPOT: Not an admin");
        _;
    }

    modifier onlyTokenOwner(){
        require(msg.sender == tokenOwner,"LOVEPOT: Not a token owner");
        _;
    }

    modifier allowed(){
        require(allow == true,"LOVEPOT: Not allowed");
        _;
    }
    
    event tokenBought(address indexed user, uint256 indexed numberOfTokens, uint256 indexed amountBusd);

    event tokenClaimed(address indexed user, uint256 indexed numberOfTokens);

    event tokenUnSold(address indexed user, uint256 indexed numberOfTokens);

    constructor() {
        deployer = msg.sender;
        allow = true;
        admin = payable(0x1bF99f349eFdEa693e622792A3D70833979E2854);
    }

    // called once by the deployer contract at time of deployment
    function initialize(
        address _tokenOwner,
        IERC20 _token,
        uint256 [9] memory values,
        uint256 _adminfeePercent,
        uint256 _reffralPercent,
        uint256 _buybackPercent,
        address _routerAddress,
        uint256 _liquiditylockduration,
        IERC20 _nativetoken
        // address _locker
    ) external {
        require(msg.sender == deployer, "LOVEPOT: FORBIDDEN"); // sufficient check
        tokenOwner = payable(_tokenOwner);
        token = _token;
        tokenPrice = values[0];
        preSaleStartTime = values[1];
        preSaleEndTime = values[2];
        minAmount = values[3];
        maxAmount = values[4];
        hardCap = values[5];
        softCap = values[6];
        listingPrice = values[7];
        liquidityPercent = values[8];
        adminFeePercent = _adminfeePercent;
        reffralPercent = _reffralPercent;
        buybackPercent =  _buybackPercent;
        routerAddress = IPancakeRouter02(_routerAddress);
        preSaleTokens = bnbToToken(hardCap);
        liquiditylockduration = _liquiditylockduration;
        nativetoken = _nativetoken;
        // locker = ILocker(_locker);
    }

    receive() payable external{}
    
    // to buy token during preSale time => for web3 use
    function buyToken(address payable reffral) public payable allowed isHuman{
        require(block.timestamp < preSaleEndTime,"LOVEPOT: Time over"); // time check
        require(block.timestamp > preSaleStartTime,"LOVEPOT: Time not Started"); // time check
        require(getContractBnbBalance() <= hardCap,"LOVEPOT: Hardcap reached");
        uint256 numberOfTokens = bnbToToken(msg.value);
        uint256 maxBuy = bnbToToken(maxAmount);
        require(msg.value >= minAmount && msg.value <= maxAmount,"LOVEPOT: Invalid Amount");
        require(numberOfTokens.add(tokenBalance[msg.sender]) <= maxBuy,"LOVEPOT: Amount exceeded");
        if(tokenBalance[msg.sender] == 0){
            totalUser++;
        }
        tokenBalance[msg.sender] = tokenBalance[msg.sender].add(numberOfTokens);
        bnbBalance[msg.sender] = bnbBalance[msg.sender].add(msg.value.sub(msg.value.mul(reffralPercent).div(100)));
        bnbBalance[reffral] = bnbBalance[reffral].add(msg.value.mul(reffralPercent).div(100));
        refamountRaised = refamountRaised.add(msg.value.mul(reffralPercent).div(100));
        soldTokens = soldTokens.add(numberOfTokens);
        amountRaised = amountRaised.add(msg.value);

        emit tokenBought(msg.sender, numberOfTokens, msg.value);
    }

    function claim() public allowed isHuman{
        require(block.timestamp > preSaleEndTime,"LOVEPOT: Presale not over");
        require(canClaim == true,"LOVEPOT: pool not initialized yet");

        if(amountRaised < softCap){
            uint256 numberOfTokens = bnbBalance[msg.sender];
            require(numberOfTokens > 0,"LOVEPOT: Zero balance");
        
            payable(msg.sender).transfer(numberOfTokens);
            bnbBalance[msg.sender] = 0;

            emit tokenClaimed(msg.sender, numberOfTokens);
        }else {
            uint256 numberOfTokens = tokenBalance[msg.sender];
            require(numberOfTokens > 0,"LOVEPOT: Zero balance");
        
            token.transfer(msg.sender, numberOfTokens);
            tokenBalance[msg.sender] = 0;

            emit tokenClaimed(msg.sender, numberOfTokens);
        }
    }
    
    function withdrawAndInitializePool() public onlyTokenOwner allowed isHuman{
        require(block.timestamp > preSaleEndTime,"LOVEPOT: PreSale not over yet");
        if(amountRaised > softCap){
            canClaim = true;
            uint256 bnbAmountForLiquidity = amountRaised.mul(liquidityPercent).div(100);
            uint256 tokenAmountForLiquidity = listingTokens(bnbAmountForLiquidity);
            token.approve(address(routerAddress), tokenAmountForLiquidity);
            addLiquidity(tokenAmountForLiquidity, bnbAmountForLiquidity);
            pair = IERC20(IPancakeswapV2Factory(address(routerAddress)).getPair(address(token),routerAddress.WETH()));
            // pair.approve(address(locker), pair.balanceOf(address(this)));
            // (uint256 price,,,,,,,,) = locker.gFees();
            // locker.lockLPToken{value : price}(address(pair), pair.balanceOf(address(this)), block.timestamp.add(liquiditylockduration), tokenOwner, true, tokenOwner);
            liquidityunLocktime = block.timestamp.add(liquiditylockduration);
            buyTokens(amountRaised.mul(buybackPercent).div(100), address(this));
            // nativetoken.transfer(address(0), nativetoken.balanceOf(address(this)));
            // admin.transfer(amountRaised.mul(adminFeePercent).div(100));
            // token.transfer(admin, soldTokens.mul(adminFeePercent).div(100));
            tokenOwner.transfer(getContractBnbBalance().sub(refamountRaised));
            uint256 refund = getContractTokenBalance().sub(soldTokens);
            if(refund > 0){
                token.transfer(tokenOwner, refund);
        
            emit tokenUnSold(tokenOwner, refund);
            }
                
        }else{
            canClaim = true;
            token.transfer(tokenOwner, getContractTokenBalance());

            emit tokenUnSold(tokenOwner, getContractBnbBalance());
        }
    }    
    function unlocklptokens() external onlyTokenOwner{
        require(block.timestamp > liquidityunLocktime,"LOVEPOT: Liquidity lock not over yet");
        pair.transfer(tokenOwner, pair.balanceOf(address(this)));
    }
    
    function addLiquidity(
        uint256 tokenAmount,
        uint256 bnbAmount
    ) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value : bnbAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp + 360
        );
    }
    function buyTokens(uint256 amount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = routerAddress.WETH();
        path[1] = address(nativetoken);

        routerAddress.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }

    // to check number of token for buying
    function bnbToToken(uint256 _amount) public view returns(uint256){
        uint256 numberOfTokens = _amount.mul(tokenPrice).mul(1000).div(1 ether);
        return numberOfTokens.mul(10 ** (token.decimals())).div(1000);
    }
    
    // to calculate number of tokens for listing price
    function listingTokens(uint256 _amount) public view returns(uint256){
        uint256 numberOfTokens = _amount.mul(listingPrice).mul(1000).div(1 ether);
        return numberOfTokens.mul(10 ** (token.decimals())).div(1000);
    }

    // to check contribution
    function userContribution(address _user) public view returns(uint256){
        return bnbBalance[_user];
    }

    // to check token balance of user
    function userTokenBalance(address _user) public view returns(uint256){
        return tokenBalance[_user];
    }

    // to Stop preSale in case of scam
    function setAllow(bool _enable) external onlyAdmin{
        allow = _enable;
    }
    
    function getContractBnbBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getContractTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
    
}

pragma solidity ^0.8.9;

//  SPDX-License-Identifier: MIT

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

import './IERC20.sol';
import '../Libraries/SafeMath.sol';
import '../Interfaces/IPancakeRouter02.sol';
import '../AbstractContracts/ReentrancyGuard.sol';

interface IPreSale{

    function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    function deployer() external view returns(address);
    function token() external view returns(address);
    function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    function minAmount() external view returns(uint256);
    function maxAmount() external view returns(uint256);
    function softCap() external view returns(uint256);
    function hardCap() external view returns(uint256);
    function listingPrice() external view returns(uint256);
    function liquidityPercent() external view returns(uint256);

    function allow() external view returns(bool);

    function initialize(
        address _tokenOwner,
        IERC20 _token,
        uint256 [9] memory values,
        uint256 _adminfeePercent,
        uint256 _reffralPercent,
        uint256 _buybackPercent,
        address _routerAddress,
        uint256 _liquiditylockduration,
        IERC20 _nativetoken
        // address _locker
    ) external ;

    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IPancakeswapV2Factory {
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

pragma solidity ^0.8.9;

// SPDX-License-Identifier:MIT

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

interface IERCBurn {
    function burn(uint256 _amount) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}
interface ILocker {
  
  function lockLPToken (address _lpToken, uint256 _amount, uint256 _unlock_date, address payable _referral, bool _fee_in_eth, address payable _withdrawer) external payable ;
  function gFees() external view returns (
    uint256 ethFee, // Small eth fee to prevent spam on the platform
    IERCBurn secondaryFeeToken, // LPCX or UNCL
    uint256 secondaryTokenFee, // optional, LPCX or UNCL
    uint256 secondaryTokenDiscount, // discount on liquidity fee for burning secondaryToken
    uint256 liquidityFee, // fee on Love liquidity tokens
    uint256 referralPercent, // fee for referrals
    IERCBurn referralToken, // token the refferer must hold to qualify as a referrer
    uint256 referralHold, // balance the referrer must hold to qualify as a referrer
    uint256 referralDiscount
    );
  
}

pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external;
    function transferFrom(address from, address to, uint value) external;
}

pragma solidity ^0.8.9;

//SPDX-License-Identifier: MIT Licensed

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}