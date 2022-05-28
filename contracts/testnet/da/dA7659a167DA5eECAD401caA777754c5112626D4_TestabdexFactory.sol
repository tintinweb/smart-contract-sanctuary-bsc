// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;

import './interfaces/ITestabdexFactory.sol';
import './libraries/Ownable.sol';
import './TestabdexPair.sol';

contract TestabdexFactory is Ownable, ITestabdexFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(TestabdexPair).creationCode));
    address public CHEF_FACTORY;
    address public feeTo;
    address public feeToSetter;

    mapping(address => bool) public isEXToken;
    mapping(address => bool) public isHole;
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address[] public allHoles;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(
        address tokenA, 
        address tokenB,
        address burnToken,
        uint256 burnTokenSupplyLimit,
        uint32[3] calldata burnTokenParams
    ) external returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        require(getPair[token0][token1] == address(0), 'Testabdex: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(TestabdexPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ITestabdexPair(pair).initialize(token0, token1, burnToken, burnTokenSupplyLimit, burnTokenParams);     
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "Testabdex: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Testabdex: ZERO_ADDRESS");
    }

    function _getPair(address tokenA, address tokenB) private view returns (ITestabdexPair pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        address pair_ = getPair[token0][token1];
        require(pair_ != address(0), 'Testabdex: PAIR_NOT_EXISTS'); 
        pair = ITestabdexPair(pair_);
    } 

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Testabdex: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Testabdex: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function allHolesLength() external view returns (uint256) {
        return allHoles.length;
    }

    function addHoles(address[] calldata holes) external onlyOwner {
        for (uint32 i = 0; i < holes.length; i++) {
            if (!isHole[holes[i]]) { 
                allHoles.push(holes[i]);
                isHole[holes[i]] = true;
            }           
        }
    }

    function setEXToken(address token, bool ex) external onlyOwner {
        isEXToken[token] = ex;
    }

    function setBurnToken(address tokenA, address tokenB, address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare) external onlyOwner {
        _getPair(tokenA, tokenB).setBurnToken(token, supplyLimit, burnShare, feeShare, poolShare);    
    }

    function setSwapLimit(
        address tokenA, 
        address tokenB,
        address token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    ) external onlyOwner {
        _getPair(tokenA, tokenB).setSwapLimit(token, startTimeStamp, endTimeStamp, userAmountLimit, totalAmountLimit);   
    }

    function setAdmin(address tokenA, address tokenB, address admin) external onlyOwner {
        _getPair(tokenA, tokenB).setAdmin(admin);
    }

    function setCHEF_FACTORY(address factory) external onlyOwner {
        CHEF_FACTORY = factory;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;

import './interfaces/ITestabdexPair.sol';
import './TestabdexERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './libraries/Ownable.sol';
import './interfaces/IERC20.sol';
import './interfaces/ITestabdexFactory.sol';
import './interfaces/ITestabdexCallee.sol';
import "./interfaces/ITestabdexChefFactory.sol";

contract TestabdexPair is Ownable, ITestabdexPair, TestabdexERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR_TRANSFER = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant SELECTOR_BURN = bytes4(keccak256(bytes('burn(uint256)')));
    address private constant ADDRESS_DEAD = 0x000000000000000000000000000000000000dEaD;

    address public factory;
    address public token0;
    address public token1;

    uint112 private swapFee0;  
    uint112 private swapFee1; 
    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Testabdex: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    struct SwapLimit {
        address token;
        uint32 startTimeStamp;
        uint32 endTimeStamp;
        uint256 userAmountLimit;
        uint256 totalAmountLimit;
        uint256 totalSwapAmount;
        mapping(address => uint256) userSwapAmounts;     
    }
    SwapLimit private _swapLimit;

    struct BurnToken {
        address token;
        uint256 supplyLimit;
        uint32 burnShare;
        uint32 feeShare;
        uint32 poolShare;   
    }
    BurnToken private burnToken; 

    function getSwapFee() public view returns (uint112 _swapFee0, uint112 _swapFee1, uint32 _blockTimestampLast) {
        _swapFee0 = swapFee0;
        _swapFee1 = swapFee1;
        _blockTimestampLast = blockTimestampLast;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function getTokenPool() public view returns (address _token0, address _token1, uint112 _reserve0, uint112 _reserve1) {
        _token0 = token0;
        _token1 = token1;
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_TRANSFER, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Testabdex: TRANSFER_FAILED');
    }

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
    event SetSwapBurnToken(
        address indexed burnToken,
        uint minimumSupply,
        uint burnShare,
        uint feeShare,
        uint poolShare
    );
    event SetSwapTokenLimit(
        address indexed token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    );

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        address _token0, 
        address _token1,
        address _burnToken,
        uint256 _burnTokenSupplyLimit,
        uint32[3] calldata _burnTokenParams
    ) 
        external 
    {
        require(msg.sender == factory, 'Testabdex: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        require(_burnToken == _token0 || _burnToken == _token1, 'Testabdex: INVALID_TOKEN');
        require((_burnTokenParams[0] + _burnTokenParams[1] + _burnTokenParams[2]) > 0, 'Testabdex: SHARES_UNDERFLOW');
        burnToken = BurnToken(_burnToken, _burnTokenSupplyLimit, _burnTokenParams[0], uint32(_burnTokenParams[1]), uint32(_burnTokenParams[2]));
        emit SetSwapBurnToken(_burnToken, _burnTokenSupplyLimit, _burnTokenParams[0], uint32(_burnTokenParams[1]), uint32(_burnTokenParams[2]));
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'Testabdex: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _updateSwapFee(uint swapFee0In, uint swapFee1In, uint swapFee0Out, uint swapFee1Out) private {
        uint _swapFee0 = uint(swapFee0).add(swapFee0In).sub(swapFee0Out);
        uint _swapFee1 = uint(swapFee1).add(swapFee1In).sub(swapFee1Out);
        require(_swapFee0 <= uint112(-1) && _swapFee1 <= uint112(-1), 'Testabdex: SWAPFEE_OVERFLOW');
        swapFee0 = uint112(_swapFee0);
        swapFee1 = uint112(_swapFee1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        ITestabdexFactory _factory = ITestabdexFactory(factory);
        address _feeTo = _factory.feeTo();
        feeOn = _feeTo != address(0) && (_factory.isEXToken(token0) || _factory.isEXToken(token1));
    
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                //mint fee
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast)).mul(5);
                    uint denominator = rootK.mul(25).add(rootKLast.mul(5));
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(_feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings

        (uint balance0, uint balance1) = _getPoolBalance();
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'Testabdex: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    function _getPoolBalance() private view returns (uint balance0, uint balance1) {
        (uint112 _swapFee0, uint112 _swapFee1,) = getSwapFee();
        balance0 = IERC20(token0).balanceOf(address(this)).sub(_swapFee0);
        balance1 = IERC20(token1).balanceOf(address(this)).sub(_swapFee1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'Testabdex: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        {   
            (uint112 _swapFee0, uint112 _swapFee1,) = getSwapFee();
            uint fee0Out = liquidity.mul(_swapFee0) / _totalSupply;
            uint fee1Out = liquidity.mul(_swapFee1) / _totalSupply;
            _updateSwapFee(0, 0, fee0Out, fee1Out);
        }

        (balance0, balance1) = _getPoolBalance();
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {     
        require(amount0Out > 0 || amount1Out > 0, 'Testabdex: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'Testabdex: INSUFFICIENT_LIQUIDITY');
        
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'Testabdex: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) ITestabdexCallee(to).TestabdexCall(msg.sender, amount0Out, amount1Out, data);
        }

        (uint balance0, uint balance1) = _getPoolBalance();
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'Testabdex: INSUFFICIENT_INPUT_AMOUNT');
        
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint fee0In = amount0Out.mul(3)/997;
        uint fee1In = amount1Out.mul(3)/997;
        uint balance0Adjusted = balance0.sub(fee0In);
        uint balance1Adjusted = balance1.sub(fee1In);
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1), 'Testabdex: K');
        _updateSwapFee(fee0In, fee1In, 0, 0);
        } 

        //check swapLimit
        require(_checkUserSwapLimit(to, amount0In, amount1In), 'Testabdex: SWAP_LIMITED');
        {//burn
        address _token = burnToken.token == token0 ? token0 : token1;
        uint256 _amountIn = burnToken.token == token0 ? amount0In : amount1In;
        if (_amountIn > 0) { _swapBurn(_token, _amountIn); }
        }

        (balance0, balance1) = _getPoolBalance();
        _update(balance0, balance1, _reserve0, _reserve1);

        _updateChefWeights();
        
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function _updateChefWeights() private {
        address chefFactory = ITestabdexFactory(factory).CHEF_FACTORY();
        if (chefFactory != address(0)) {
            uint _totalSupply = totalSupply;
            (uint112 _reserveA, uint112 _reserveB,) = getReserves(); 
            uint256 priceA = uint256(_reserveA) / _totalSupply;
            uint256 priceB = uint256(_reserveB) / _totalSupply;
            ITestabdexChefFactory(chefFactory).updateLPWeights(token0, token1, priceA, priceB); 
        }     
    }

    function _getTokenTotalSupply(address token) private view returns (uint256 amount) {
        IERC20 _token = IERC20(token);
        amount = IERC20(token).totalSupply();

        ITestabdexFactory _factory = ITestabdexFactory(factory);
        uint256 _length = _factory.allHolesLength();
        for (uint256 i = 0; i < _length; i++) {
            amount -= _token.balanceOf(_factory.allHoles(i));
        }
    }

    function _safeBurn(address token, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_BURN, value));
        bool isBurned = success && (data.length == 0 || abi.decode(data, (bool)));
        if (!isBurned) {
            _safeTransfer(token, ADDRESS_DEAD, value);
        }
    }

    function _swapBurn(address token, uint256 amountIn) private {
        uint256 totalAmount = _getTokenTotalSupply(token);
        uint256 _minSupply = burnToken.supplyLimit;
        if (totalAmount > _minSupply) { 
            uint256 amountToBurn = amountIn.mul(burnToken.burnShare)/(burnToken.burnShare + burnToken.feeShare + burnToken.poolShare);
            amountToBurn = Math.min(totalAmount.sub(_minSupply), amountToBurn);
            if (amountToBurn > 0) {  _safeBurn(token, amountToBurn); } 
        }   

        uint256 amountToFee = amountIn.mul(burnToken.feeShare)/(burnToken.burnShare + burnToken.feeShare + burnToken.poolShare);
        (uint fee0In, uint fee1In) = (token0 == token) ? (amountToFee, uint(0)) : (uint(0), amountToFee);
        _updateSwapFee(fee0In, fee1In, 0, 0);     
    }

    function setSwapLimit(
        address token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    )
        external
        lock 
        onlyOwner
    {
        require(endTimeStamp > startTimeStamp, 'Testabdex: endTimeStamp must greater than startTimeStamp');
        require(token == address(0) || token == token0 || token == token1, 'Testabdex: invalid token');
        _swapLimit.startTimeStamp = startTimeStamp;
        _swapLimit.endTimeStamp = endTimeStamp;
        _swapLimit.userAmountLimit = userAmountLimit;
        _swapLimit.totalAmountLimit = totalAmountLimit;

        emit SetSwapTokenLimit(token, startTimeStamp, endTimeStamp, userAmountLimit, totalAmountLimit);
    }

    function getSwapLimit() external view returns (address token, uint32 startTimeStamp, uint32 endTimeStamp, uint256 userAmountLimit, uint256 totalAmountLimit) {
        if (_hasSwapLimit()) {
            token = _swapLimit.token;
            startTimeStamp = _swapLimit.startTimeStamp;
            endTimeStamp = _swapLimit.endTimeStamp;
            userAmountLimit = _swapLimit.userAmountLimit;
            totalAmountLimit = _swapLimit.totalAmountLimit;     
        }        
    }

    function _hasSwapLimit() private view returns (bool on) {
        bool validToken = _swapLimit.token != address(0);
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        bool inTime = blockTimestamp >= _swapLimit.startTimeStamp && blockTimestamp <= _swapLimit.endTimeStamp;
        bool validAmount = _swapLimit.userAmountLimit > 0 || _swapLimit.totalAmountLimit > 0;
        on = validToken && validAmount && inTime;
    }

    function getUserLimitedSwapAmounts(address from) external view returns (uint256 amount) {
        if (_hasSwapLimit()) { amount = _swapLimit.userSwapAmounts[from]; }
    }

    function _updateUserLimitedSwapAmounts(address from, uint256 amountIn) private {
        if (_hasSwapLimit()) { _swapLimit.userSwapAmounts[from] += amountIn; }
    }

    function _checkUserSwapLimit(address user, uint256 amount0In, uint256 amount1In) private returns (bool checked) {
        checked = true;
        if (_hasSwapLimit()) {
            uint256 amountIn = _swapLimit.token == token0 ? amount0In : amount1In;
            uint256 limitUser = _swapLimit.userAmountLimit;
            uint256 limitTotal = _swapLimit.totalAmountLimit;
            uint256 amountSpan = 0;
            if (limitUser > 0) { amountSpan = Math.min(limitUser.sub(_swapLimit.userSwapAmounts[user]), amountSpan); }
            if (limitTotal > 0) { amountSpan = Math.min(limitTotal.sub(_swapLimit.totalSwapAmount), amountSpan); }
            checked = amountSpan >= amountIn;
            if (checked) {
                _swapLimit.userSwapAmounts[user] += amountIn;
                _swapLimit.totalSwapAmount += amountIn;
            }
        }
    }

    function getBurnToken() external view returns (address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare) {
        token = burnToken.token;
        supplyLimit = burnToken.supplyLimit;
        poolShare = burnToken.poolShare;
        burnShare = burnToken.burnShare;
        feeShare = burnToken.feeShare;
    }

    function setBurnToken(address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare) external lock onlyOwner {
        require(token == token0 || token == token1, 'Testabdex: INVALID_TOKEN');
        require(uint(poolShare).add(uint(burnShare)) > 0, 'Testabdex: SHARES_UNDERFLOW');
        burnToken.token = token;
        burnToken.supplyLimit = supplyLimit;
        burnToken.poolShare = poolShare;
        burnToken.burnShare = burnShare;
        burnToken.feeShare = feeShare;

        emit SetSwapBurnToken(token, supplyLimit, burnShare, feeShare, poolShare);
    }

    function setAdmin(address admin) external onlyOwner {
        transferOwnership(admin);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface ITestabdexFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA, 
        address tokenB,
        address burnToken,
        uint256 burnTokenSupplyLimit,
        uint32[3] calldata burnTokenParams
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function allHoles(uint256) external view returns (address hole);

    function allHolesLength() external view returns (uint256);

    function addHoles(address[] calldata) external;

    function isEXToken(address) external view returns (bool);

    function setEXToken(address, bool) external;

    function setBurnToken(
        address tokenA, 
        address tokenB, 
        address token, 
        uint256 supplyLimit, 
        uint32 burnShare, 
        uint32 feeShare, 
        uint32 poolShare
    ) external;
    
    function setAdmin(address tokenA, address tokenB, address admin) external;

    function setSwapLimit(
        address tokenA, 
        address tokenB,
        address token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    ) external;

    function CHEF_FACTORY() external view returns (address);

    function setCHEF_FACTORY(address factory) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ITestabdexChefFactory {
    function updateLPWeights(address tokenA, address tokenB, uint256 priceA, uint256 priveB) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface ITestabdexCallee {
    function TestabdexCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;

import "./interfaces/ITestabdexERC20.sol";
import "./libraries/SafeMath.sol";

contract TestabdexERC20 is ITestabdexERC20 {
    using SafeMath for uint256;

    string public constant name = "Testabdex LPs";
    string public constant symbol = "Testabdex-LP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Testabdex: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Testabdex: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface ITestabdexPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event SetSwapBurnToken(
        address indexed burnToken,
        uint minimumSupply,
        uint burnShare,
        uint feeShare,
        uint poolShare
    );
    event SetSwapTokenLimit(
        address indexed token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    );

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function getTokenPool() external view returns (address _token0, address _token1, uint112 reserve0, uint112 reserve1);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(
        address tokenA,
        address tokenB,
        address burnToken,
        uint256 burnTokenSupplyLimit,
        uint32[3] calldata burnTokenParams
    ) external;

    function getSwapFee()
        external
        view
        returns (
            uint112 swapFee0,
            uint112 swapFee1,
            uint32 blockTimestampLast
        );

    function getBurnToken() external view returns (address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare); 

    function setBurnToken(address token, uint256 supplyLimit, uint32 burnShare, uint32 feeShare, uint32 poolShare) external;

    function setSwapLimit(
        address token,
        uint32 startTimeStamp,
        uint32 endTimeStamp,
        uint256 userAmountLimit,
        uint256 totalAmountLimit
    ) external;

    function getSwapLimit() external view returns (address token, uint32 startTimeStamp, uint32 endTimeStamp, uint256 userAmountLimit, uint256 totalAmountLimit); 

    function getUserLimitedSwapAmounts(address from) external view returns (uint256 amount);

    function setAdmin(address admin) external;

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface ITestabdexERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}