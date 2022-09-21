/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPancakePair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                //hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
                hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074'   // Change to INIT_CODE_PAIR_HASH of Pancake Factory
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

interface IPancakeRouter {

    function WETH() external view returns (address ) ;
    function addLiquidity( address tokenA,address tokenB,uint256 amountADesired,uint256 amountBDesired,uint256 amountAMin,uint256 amountBMin,address to,uint256 deadline ) external  returns (uint256 amountA, uint256 amountB, uint256 liquidity) ;        
    function addLiquidityETH( address token,uint256 amountTokenDesired,uint256 amountTokenMin,uint256 amountETHMin,address to,uint256 deadline ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) ;
    function factory() external view returns (address ) ;
    function getAmountIn( uint256 amountOut,uint256 reserveIn,uint256 reserveOut ) external pure returns (uint256 amountIn) ;   
    function getAmountOut( uint256 amountIn,uint256 reserveIn,uint256 reserveOut ) external pure returns (uint256 amountOut) ;  
    function getAmountsIn( uint256 amountOut,address[] calldata path ) external view returns (uint256[] memory amounts) ;       
    function getAmountsOut( uint256 amountIn,address[] calldata path ) external view returns (uint256[] memory amounts) ;       
    function quote( uint256 amountA,uint256 reserveA,uint256 reserveB ) external pure returns (uint256 amountB) ;
    function removeLiquidity( address tokenA,address tokenB,uint256 liquidity,uint256 amountAMin,uint256 amountBMin,address to,uint256 deadline ) external  returns (uint256 amountA, uint256 amountB) ;
    function removeLiquidityETH( address token,uint256 liquidity,uint256 amountTokenMin,uint256 amountETHMin,address to,uint256 deadline ) external  returns (uint256 amountToken, uint256 amountETH) ;
    function removeLiquidityETHSupportingFeeOnTransferTokens( address token,uint256 liquidity,uint256 amountTokenMin,uint256 amountETHMin,address to,uint256 deadline ) external  returns (uint256 amountETH) ;
    function removeLiquidityETHWithPermit( address token,uint256 liquidity,uint256 amountTokenMin,uint256 amountETHMin,address to,uint256 deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s ) external  returns (uint256 amountToken, uint256 amountETH) ;
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token,uint256 liquidity,uint256 amountTokenMin,uint256 amountETHMin,address to,uint256 deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s ) external  returns (uint256 amountETH) ;
    function removeLiquidityWithPermit( address tokenA,address tokenB,uint256 liquidity,uint256 amountAMin,uint256 amountBMin,address to,uint256 deadline,bool approveMax,uint8 v,bytes32 r,bytes32 s ) external  returns (uint256 amountA, uint256 amountB) ;
    function swapETHForExactTokens( uint256 amountOut,address[] calldata path,address to,uint256 deadline ) external payable returns (uint256[] memory amounts) ;
    function swapExactETHForTokens( uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external payable returns (uint256[] memory amounts) ;
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external payable  ;
    function swapExactTokensForETH( uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external returns (uint256[] memory amounts) ;
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external   ;
    function swapExactTokensForTokens( uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external  returns (uint256[] memory amounts) ;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline ) external   ;
    function swapTokensForExactETH( uint256 amountOut,uint256 amountInMax,address[] calldata path,address to,uint256 deadline ) external returns (uint256[] memory amounts) ;
    function swapTokensForExactTokens( uint256 amountOut,uint256 amountInMax,address[] calldata path,address to,uint256 deadline ) external  returns (uint256[] memory amounts) ;
    receive () external payable;
  
}

contract LaunchPool {
    using SafeMath for uint256;
    address payable public deployer;
    address payable public owner;
    uint256[] public vestDuration = [0, 30 days, 60 days];
    uint256[] public vestingClaim = [30, 35, 35]; // in percentage
    address wBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

    enum Release {
        NOT_SET,
        FAILED,
        RELEASED
    }

    IPancakeRouter public PancakeRouter = IPancakeRouter(payable(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3));
    IERC20 public tokenSell;
    uint256 public perTokenBuy;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public totalTokenSell;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public maxBuy;
    uint256 public minBuy;
    uint256 public alreadyRaised;
    Release public release;
    uint256 public releaseTime;
    address public activeCurrency;
    bool public isWhitelist;
    bool public isCheckSoftCap = true;
    bool public isVesting = true;

    struct UserInfo {
        uint256 totalToken;
        uint256 totalSpent;
    }

    struct LockLP {
        address owner; 
        uint256 amount;
        uint256 unlockDate;
    }

    enum Claims {
        HALF,
        FULL,
        FAILED
    }

    mapping(address => UserInfo) public usersTokenBought; // userAddress => User Info
    mapping(address => LockLP) public LockedLP; // LP token => locked info
    mapping(address => bool) public whitelistedAddress;
    mapping(address => mapping(uint256 => bool)) public claimInPeriod; // userAddress => period => true/false

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    modifier withdrawCheck() {
        require(getSoftFilled() == true, "Can't withdraw");
        _;
    }

    event BUY(address Buyer, uint256 amount);
    event CLAIM(address Buyer, Claims claim);
    event RELEASE(Release released);
    event LockAdded(
        address indexed token,
        address owner,
        uint256 amount,
        uint256 unlockDate
    );

    constructor(address payable _owner, address _activeCurrency) {
        owner = _owner;
        activeCurrency = _activeCurrency;
    }

    // onlyOwner Function
    function setEventPeriod(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        require(address(tokenSell) != address(0), "Setup raised first");
        require(_startTime != 0, "Cannot set 0 value");
        require(_endTime > _startTime, "End time must be greater");
        startTime = _startTime;
        endTime = _endTime;
    }

    function setRaised(
        address _tokenSale,
        uint256 _perTokenBuy,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _maxBuy,
        uint256 _minBuy,
        bool _isWhitelist,
        bool _isCheckSoftCap,
        bool _isVesting
    ) external onlyOwner {
        // require(startTime == 0, "Raising period already start");
        require(_hardcap > _softcap, "Hardcap must greater than softcap");
        tokenSell = IERC20(_tokenSale);
        uint256 _totalTokenSale = _hardcap.mul(_perTokenBuy);
        uint256 allowance = tokenSell.allowance(msg.sender, address(this));
        uint256 balance = tokenSell.balanceOf(msg.sender);
        //require(balance >= _totalTokenSale, "Not enough tokens");
        require(allowance >= _totalTokenSale, "Check the token allowance");
        perTokenBuy = _perTokenBuy; //4 
        totalTokenSell = _totalTokenSale;
        softCap = _softcap;
        hardCap = _hardcap;
        maxBuy = _maxBuy; // in in active currency
        minBuy = _minBuy; // in in active currency
        isWhitelist = _isWhitelist;
        isVesting = _isVesting; // only set one time
        isCheckSoftCap = _isCheckSoftCap; // only set one time
        //tokenSell.transferFrom(msg.sender, address(this), _perTokenBuy.div(100).mul(75) ); 
    }

    function setMinMaxBuy(uint256 _minBuy, uint _maxBuy) external onlyOwner {
        require(_maxBuy > _minBuy, "max buy less than min buy");
        minBuy = _minBuy;
        maxBuy = _maxBuy;
    }

    function setIsWhitelist(bool _isWhitelist) external onlyOwner {
        require(isWhitelist != _isWhitelist, "cannot assign same value");
        isWhitelist = _isWhitelist;
    }

    function addWhitelised(
        address[] memory whitelistAddresses,
        bool[] memory values
    ) external onlyOwner {
        require(
            whitelistAddresses.length == values.length,
            "provide same length"
        );
        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            whitelistedAddress[whitelistAddresses[i]] = values[i];
        }
    }

    function setVestingPeriodAndClaim(
        uint256[] memory _vests,
        uint256[] memory _claims
    ) external onlyOwner {
        require(_vests.length == _claims.length, "length must be same");
        require(block.timestamp < startTime, "Raising period already started");
        uint total;
        for (uint256 i = 0; i < _claims.length; i++) {
            total += _claims[i];
        }
        require(total == 100, "total claim must be 100");

        for (uint256 i = 0; i < _vests.length; i++) {
            vestDuration[i] = _vests[i].mul(1 days);
            vestingClaim[i] = _claims[i];
        }
    }

    // dari sini
    function _safeTransferFromEnsureExactAmount(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
        IERC20(token).transferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Not enough token was transfered"
        );
    }

    // function for lock lp
    function lock(
        address _token,
        address _owner,
        uint256 _amount,
        uint256 _unlockDate
    ) internal {
        require(
            _unlockDate > block.timestamp,
            "Unlock date should be in the future"
        );
        require(_amount > 0, "Amount should be greater than 0");

        LockLP memory lockLp = LockedLP[_token];
        lockLp.owner = _owner;
        lockLp.amount = _amount;
        lockLp.unlockDate = _unlockDate;
        LockedLP[_token] = lockLp;

        _safeTransferFromEnsureExactAmount(
            _token,
            msg.sender,
            address(this),
            _amount
        );

        emit LockAdded(_token, _owner, _amount, _unlockDate);
    }

    // function for finalize lp
    function _finalize(uint256 _lockPeriod) internal {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance * 15 / 100);
        payable(deployer).transfer(balance * 5 / 100);

        (uint amountA, uint amountB, uint liquidity) = PancakeRouter.addLiquidity(
            activeCurrency, 
            wBNB, 
            minBuy, 
            minBuy, 
            balance * 80 / 100, 
            balance * 80 / 100,
            msg.sender,
            _lockPeriod
        );

        address factory = PancakeRouter.factory();
        address pair = PancakeLibrary.pairFor(factory, activeCurrency, wBNB);
        lock(msg.sender, pair, liquidity, _lockPeriod);
    }

    function setRelease(Release _release, uint256 _lockPeriod) external onlyOwner {
        require(startTime != 0, "Raise no start");
        require(release != _release, "Can't setup same release");
        if (isCheckSoftCap) {
            require(getSoftFilled(), "Softcap not fullfiled");
        }
        if (getHardFilled() == false) {
            require(block.timestamp > endTime, "Raising not end");
        }
        release = _release;
        releaseTime = block.timestamp;
        _finalize(_lockPeriod);

        emit RELEASE(_release);
    }

    // function for withdraw LP token
    function withdrawLP(address _tokenLP) external onlyOwner {
        LockLP memory data = LockedLP[_tokenLP];
        require(data.owner == msg.sender, "You are not the owner of this LP");
        require(data.unlockDate <= block.timestamp, "The LP is still in lock period");
        IERC20(_tokenLP).transferFrom(address(this), msg.sender, data.amount);
    }
    // sampe sini

    function withdrawBNB() public onlyOwner withdrawCheck {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
    {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    // Buy Function
    function getHardFilled() public view returns (bool) {
        return alreadyRaised >= hardCap;
    }

    function getSoftFilled() public view returns (bool) {
        return alreadyRaised >= softCap;
    }

    function getSellTokenAmount(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return _amount * perTokenBuy;
    }

    function buy(uint256 amount) external payable {
        if (isWhitelist) {
            require(whitelistedAddress[msg.sender], "not whitelisted");
        }
        require(block.timestamp != 0, "Raising period not set");
        require(block.timestamp >= startTime, "Raising period not started yet");
        require(block.timestamp < endTime, "Raising period already end");
        require(getHardFilled() == false, "Raise already fullfilled");

        UserInfo memory userInfo = usersTokenBought[msg.sender];

        uint256 tokenSellAmount;

        if (IERC20(activeCurrency) == IERC20(wBNB)) {
            require(msg.value > 0, "Please input value");
            require(
                userInfo.totalSpent.add(msg.value) >= minBuy,
                "Less than min buy"
            );
            require(
                userInfo.totalSpent.add(msg.value) <= maxBuy,
                "More than max buy"
            );
            require(
                msg.value + alreadyRaised <= hardCap,
                "amount buy more than total hardcap"
            );

            tokenSellAmount = getSellTokenAmount(msg.value);
            userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
            userInfo.totalSpent = userInfo.totalSpent.add(msg.value);
            usersTokenBought[msg.sender] = userInfo;

            alreadyRaised = alreadyRaised.add(msg.value);
        } else {
            require(amount > 0, "Please input value");
            require(
                userInfo.totalSpent.add(amount) >= minBuy,
                "Less than min buy"
            );
            require(
                userInfo.totalSpent.add(amount) <= maxBuy,
                "More than max buy"
            );
            require(
                amount + alreadyRaised <= hardCap,
                "amount buy more than total hardcap"
            );

            tokenSellAmount = getSellTokenAmount(amount);
            require(
                IERC20(activeCurrency).balanceOf(msg.sender) >= amount,
                "not enough balance"
            );
            require(
                IERC20(activeCurrency).allowance(msg.sender, address(this)) >= amount,
                "not enough allowance"
            );

            IERC20(activeCurrency).transferFrom(msg.sender, address(this), amount);
            userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
            userInfo.totalSpent = userInfo.totalSpent.add(amount);
            usersTokenBought[msg.sender] = userInfo;
            alreadyRaised = alreadyRaised.add(amount);
        }

        emit BUY(msg.sender, tokenSellAmount);
    }

    // Claim Function
    function claimFailed() external {
        require(block.timestamp > endTime, "Raising not end");
        if (isCheckSoftCap) {
            require(getSoftFilled() == false, "Soft cap already fullfiled");
        } else {
            require(release == Release.FAILED, "Release not failed");
        }

        uint256 userSpent = usersTokenBought[msg.sender].totalSpent;
        require(userSpent > 0, "Already claimed");

        if (IERC20(activeCurrency) == IERC20(wBNB)) {
            payable(msg.sender).transfer(userSpent);
        } else {
            IERC20(activeCurrency).transfer(msg.sender, userSpent);
        }

        delete usersTokenBought[msg.sender];
        emit CLAIM(msg.sender, Claims.FAILED);
    }

    modifier checkPeriod(uint256 _claim) {
        require(
            vestDuration[_claim] + releaseTime <= block.timestamp,
            "Claim not avalaible yet"
        );
        _;
    }

    function claimSuccess(uint256 _claim)
        external
        checkPeriod(uint256(_claim))
    {
        require(release == Release.RELEASED, "Not Release Time");
        UserInfo storage userInfo = usersTokenBought[msg.sender];
        require(userInfo.totalToken > 0, "You can't claim any amount");

        uint256 amountClaim;
        Claims claim;

        if (isVesting == false) {
            amountClaim = userInfo.totalToken;
            usersTokenBought[msg.sender] = userInfo;
            tokenSell.transfer(msg.sender, amountClaim);
            claim = Claims.FULL;
        } else {
            require(_claim < vestDuration.length, "more than max claim");
            require(
                claimInPeriod[msg.sender][_claim] == false,
                "already claim"
            );
            amountClaim = userInfo.totalToken.mul(vestingClaim[_claim]).div(
                100
            );
            usersTokenBought[msg.sender] = userInfo;
            tokenSell.transfer(msg.sender, amountClaim);
            claimInPeriod[msg.sender][_claim] = true;
            claim = Claims.HALF;
        }

        emit CLAIM(msg.sender, claim);
    }

    function getRaised()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256[] memory,
            uint256,
            uint256,
            uint256,
            IERC20,
            bool,
            bool,
            bool
        )
    {
        return (
            alreadyRaised,
            startTime,
            endTime,
            softCap,
            hardCap,
            releaseTime,
            vestDuration,
            minBuy,
            maxBuy,
            perTokenBuy,
            IERC20(activeCurrency),
            isWhitelist,
            isCheckSoftCap,
            isVesting
        );
    }
}