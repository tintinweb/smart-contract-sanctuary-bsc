/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        _transferOwnership(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
  
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20Migration is Ownable {

    struct PoolInfo {
        bool                activated;
        bool                isFixed;
        IERC20              tokenA;            
        IERC20              tokenB;        
        uint256             rate;
        uint256             balanceTokenA;
        uint256             balanceTokenB;
        uint256             fees;
        IPancakeRouter02    routerA;
        IPancakeRouter02    routerB;
        IPancakePair        pairA;
        IPancakePair        pairB;
    }
    

    address public devAddress;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) public isOnAddLiquidity;
    mapping(address => bool) public isOnSwap;
  
    modifier onAddLiquidity(address _token){
        require(!isOnSwap[_token] && !isOnAddLiquidity[_token], "addLiquidity: add liquidity is not allowed currently.");
        isOnAddLiquidity[_token] = true;
        _;
        isOnAddLiquidity[_token] = false;
    }

    modifier onSwap(address _tokenA, address _tokenB){
        require(!isOnSwap[_tokenA] && !isOnAddLiquidity[_tokenA], "migrateERC20: migration is not allowed for token A currently.");
        require(!isOnSwap[_tokenB] && !isOnAddLiquidity[_tokenB], "migrateERC20: migration is not allowed for token B currently.");
        isOnSwap[_tokenA] = true;
        isOnSwap[_tokenB] = true;
        _;
        isOnSwap[_tokenA] = false;
        isOnSwap[_tokenB] = false;
    }

    PoolInfo[] public poolInfo;

    event poolCreated(
        address _creator,
        address _tokenA, 
        address _tokenB, 
        uint256 _blockTimestamp, 
        uint256 fees
    );

    event liquidityAdded(
        address _liquidityProvider, 
        uint256 _pid, address _tokenA, 
        address _tokenB, 
        uint256 _amountRequested, 
        uint256 _amountReceived, 
        uint256 _slippage, 
        uint256 poolBalance, 
        uint256 _blockTimestamp
    );

    event fixMigration(
        address _migrator, 
        uint256 _pid, 
        address _tokenA, 
        address _tokenB, 
        uint256 _realAmountAReceived, 
        uint256 _realAmountBReceived,
        uint256 _poolBalanceB, 
        uint256 _blockTimestamp
    );

    event realTimeMigration(
        address _migrator, 
        uint256 _pid, 
        address _tokenA, 
        address _tokenB, 
        uint256 _realAmountASent, 
        uint256 _realAmountBGet,
        uint256 _blockTimestamp
    );

      event debugger(
       uint256 nonce,
       uint256 value
    );

    constructor(){
        devAddress = _msgSender();
    }

    function addPool(
        bool                _activated,
        bool                _isFixed, 
        address             _tokenA, 
        address             _tokenB, 
        uint256             _rate, 
        uint256             _fees,
        IPancakeRouter02    _routerA,
        IPancakeRouter02    _routerB,
        IPancakePair        _pairA,
        IPancakePair        _pairB
    ) external onlyOwner returns(bool) {

        if(!_isFixed){
            require(address(_pairA) != address(0) && address(_pairB) != address(0), "addPool: pair should be different than address 0.");
            address pairAtoken0 = _pairA.token0();
            address pairAtoken1 = _pairA.token1();
            address pairBtoken0 = _pairB.token0();
            address pairBtoken1 = _pairB.token1();
            address token2 = pairAtoken0 == _tokenA ? pairAtoken1 : pairAtoken0;
            address token3 = pairBtoken0 == _tokenB ? pairBtoken1 : pairBtoken0;

            require(token2 == token3, "addPool: pair doesn't match");

        }

        PoolInfo memory newPool = PoolInfo({
            activated: _activated,
            isFixed: _isFixed,
            tokenA: IERC20(_tokenA),
            tokenB: IERC20(_tokenB),
            rate: _rate,
            balanceTokenA: 0,
            balanceTokenB: 0,
            fees: _fees,
            routerA: _routerA,
            routerB: _routerB,
            pairA: _pairA,
            pairB: _pairB
        });
        poolInfo.push(newPool);
        return true;
    }

    function addLiquidity(
        uint256 _pid,
        IERC20  _tokenA,
        IERC20  _tokenB,
        uint256 _amountB,
        uint256 _slippage
    ) external onAddLiquidity(address(_tokenB)) returns(bool) {
        require(_pid <= poolInfo.length -1, "addLiquidity: pool doesn't exist");
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.tokenA) == address(_tokenA), "addLiquidity: token A input doesn't match.");
        require(address(pool.tokenB) == address(_tokenB), "addLiquidity: token B input doesn't match.");
        require(_amountB > 0, "addLiquidity: amount token B should be grater than 0.");
        uint256 prevBalance = pool.balanceTokenB;
        _tokenB.transferFrom(_msgSender(), address(this), _amountB);
        uint256 _amoutBMinExpected = _amountB - uint256(uint256(_amountB * _slippage) / 100);
        require(_tokenB.balanceOf(address(this)) >= _amoutBMinExpected + prevBalance, "addLiquidity: transfer amount doesn't match slippage.");
        uint256 realAmountB = _tokenB.balanceOf(address(this)) - prevBalance;
        pool.balanceTokenB += realAmountB;
        emit liquidityAdded(_msgSender(), _pid, address(_tokenA), address(_tokenB), _amountB, realAmountB, _slippage, pool.balanceTokenB, block.timestamp);
        return true;
    }

    function migrateFixeRateERC20(
        uint256 _pid,
        IERC20 _tokenA, 
        IERC20 _tokenB, 
        uint256 _amountA,
        uint256 _slippageA,
        uint256 _slippageB
    ) private onSwap(address(_tokenA), address(_tokenB)) returns(bool){
        require(_amountA > 10000, "migrateERC20: amount token A should be grater than 10000.");
        require(_amountA <= _tokenA.balanceOf(_msgSender()), "migrateERC20: amount token A should be grater than your balance.");
        require(_amountA <= _tokenA.allowance(_msgSender(), address(this)), "migrateERC20: amount token A should be approved to be spend by this contract.");
        PoolInfo storage pool = poolInfo[_pid];
        require(address(pool.tokenA) == address(_tokenA), "migrateERC20: token A input doesn't match.");
        require(address(pool.tokenB) == address(_tokenB), "migrateERC20: token B input doesn't match.");
        require(pool.activated, "migrateERC20: migration is not active currently.");
        require(_amountA > 0, "migrateERC20: amount token A should be grater than 0.");
        uint256[] memory values = new uint256[](11);
        values[0] = pool.tokenA.balanceOf(address(this)); // prevBalanceA
        values[1] = _amountA - uint256(uint256(_amountA * _slippageA) / 100); // amoutAMinExpected
        _tokenA.transferFrom(_msgSender(), address(this), _amountA);
        values[2] = _tokenA.balanceOf(address(this)) - values[0]; // newAmountA
        require(values[2] >= values[1], "migrateERC20: amount token A doesn't match slippage A.");
        values[3] = getAmountOut(values[2], pool.rate, _tokenA.decimals());  // baseAmountTokenB
        require(values[3] <= pool.balanceTokenB && values[3] <= _tokenB.balanceOf(address(this)), "migrateERC20: not enough fund in the pool.");
        values[4] = pool.fees > 0 ? uint256(uint256(values[3] * pool.fees) / 10000) : 0; // feesAmount
        values[5] = values[3] - values[4]; //amountTokenB
        values[6] = values[4] - uint256(uint256(values[4] * _slippageB) / 100); //feesMinExpected

        if(pool.fees > 0){
            values[8] = _tokenB.balanceOf(devAddress); //previousDevBalance
            _tokenB.transfer(devAddress, values[4]);
            values[7] =  _tokenB.balanceOf(devAddress) - values[8]; //afterDevBalance
            require(values[7] >= values[6], "migrateERC20: not enough token B get by devAddress, please check slippage B.");
        }

        values[8] =  values[5] - uint256(uint256(values[5] * _slippageB) / 100); //amountBMinExpected
        values[9] = _tokenB.balanceOf(_msgSender()); //previousRecipientBalanceB
        _tokenB.transfer(_msgSender(), values[5]);
        values[10] = _tokenB.balanceOf(_msgSender()) - values[9]; //realAmountTokenB
        require(values[10] >= values[8], "migrateERC20: amount token B doesn't match slippage B.");
        pool.balanceTokenB -= values[3];
        _tokenA.transfer(burnAddress, values[2]);

        emit fixMigration(
            _msgSender(), 
            _pid, 
            address(_tokenA), 
            address(_tokenB), 
            values[2], 
            values[9],
            pool.balanceTokenB, 
            block.timestamp
        );
        return true;
    }


    function migrateRealTimeRateERC20(
        uint256 _pid,
        IERC20 _tokenA, 
        IERC20 _tokenB, 
        uint256 _amountA,
        uint256 _slippageA,
        uint256 _slippageB
    ) private  returns(bool){
        require(_amountA > 10000, "migrateERC20: amount token A should be grater than 10000.");
        require(_amountA <= _tokenA.balanceOf(_msgSender()), "migrateERC20: amount token A should be grater than your balance.");
        PoolInfo storage pool = poolInfo[_pid];
        require(_amountA <= _tokenA.allowance(_msgSender(), address(this)), "migrateERC20: amount token A should be approved to be spend by this contract.");
        require(address(pool.tokenA) == address(_tokenA), "migrateERC20: token A input doesn't match.");
        require(address(pool.tokenB) == address(_tokenB), "migrateERC20: token B input doesn't match.");
        require(pool.activated, "migrateERC20: migration is not active currently.");
        require(!isOnSwap[address(_tokenA)] && !isOnAddLiquidity[address(_tokenA)], "migrateERC20: migration is not allowed for token A currently.");
        uint256[] memory values = new uint256[](19);
        (values[0], values[1],) = pool.pairA.getReserves(); // reserve0 / reserve1
        isOnSwap[address(_tokenA)] = true;
        values[2] = _tokenA.balanceOf(address(this)); // previousBalanceA
        _tokenA.transferFrom(_msgSender(), address(this), _amountA);
        values[3] = _tokenA.balanceOf(address(this)) - values[2]; // newBalance - previous balance
        values[4] = _amountA - uint256(uint256(_amountA * _slippageA) / 100); // min Amount A to get
        require(values[3] >= values[4], "migrateERC20: not enough amount A get by the contract.");
        values[5] = values[3] - uint256(uint256(values[3] * _slippageA) / 100); // min Amount A That Router Will Get
        values[6] = pool.pairA.token0() == address(pool.tokenA) ? pool.routerA.getAmountOut(values[5], values[0], values[1]) : pool.routerA.getAmountOut(values[5], values[1], values[0]); // amountOtherToken
        address pairAotherToken = pool.pairA.token0() == address(pool.tokenA) ? pool.pairA.token1() : pool.pairA.token0(); 
        address pairBotherToken = pool.pairB.token0() == address(pool.tokenB) ? pool.pairB.token1() : pool.pairB.token0();
        require(pairAotherToken == pairBotherToken, "migrateERC20: other token doesn't match");
        require(!isOnSwap[pairAotherToken] && !isOnAddLiquidity[pairAotherToken], "migrateERC20: other token is swap currently, please wait and retry.");
        isOnSwap[pairAotherToken] = true;
        values[7] = IERC20(pairAotherToken).balanceOf(address(this)); // previous otherToken Balance
        address[] memory path = new address[](2);
        path[0] = address(_tokenA);
        path[1] = pairAotherToken;
        _tokenA.approve(address(pool.routerA), values[3]);

        pool.routerA.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            values[3], 
            values[6],
            path, 
            address(this),
            block.timestamp + 1 hours
        );

        values[8] = IERC20(pairAotherToken).balanceOf(address(this)) - values[7]; // newBalanceOtherToken
        require(values[8] >= values[6], "migrateERC20: not enough amount of other token from router A.");
        values[9] = pool.fees > 0 ? uint256(uint256(values[8] * pool.fees) / 10000):0; // feesAmount
        values[10] = values[8] - values[9]; // AmountToReSwapAfterFees

        if(pool.fees > 0){
            values[11] = IERC20(pairAotherToken).balanceOf(devAddress); //previousDevBalance
            IERC20(pairAotherToken).transfer(devAddress, values[9]);
            values[12] =  IERC20(pairAotherToken).balanceOf(devAddress) - values[11]; // balance diff after transfer
            require(values[12] >= values[9], "migrateERC20: not enough other token get by devAddress.");
        }

        (values[13], values[14],) = pool.pairB.getReserves(); // reserve0 / reserve1

        values[15] = pool.pairB.token0() == address(pool.tokenB) ? values[15] = pool.routerB.getAmountOut(values[10], uint256(values[14]), uint256(values[13])) : values[15] = pool.routerB.getAmountOut(values[10], uint256(values[13]), uint256(values[14])); // expected amountB without slippage
        values[16] = values[15] - uint256(uint256(values[15] * _slippageB) / 100); // expected amountB minus slippage
        values[17] = pool.tokenB.balanceOf(_msgSender()); //previousRecipientBalanceB
        path[0] = pairBotherToken;
        path[1] = address(pool.tokenB);
        IERC20(pairBotherToken).approve(address(pool.routerB), values[10]);

        pool.routerB.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            values[10], 
            values[16],
            path, 
            _msgSender(),
            block.timestamp + 1 hours
        );

        values[18] = _tokenB.balanceOf(_msgSender()) - values[17]; //realAmountTokenB
        require(values[18] >= values[16], "migrateERC20: not enough token B get by sender, please check slippage B.");

        emit realTimeMigration(
            _msgSender(), 
            _pid, 
            address(_tokenA), 
            address(_tokenB), 
            values[3], 
            values[18],
            block.timestamp
        );

        isOnSwap[pairAotherToken] = false;
        isOnSwap[address(_tokenA)] = false;

        return true;
    }

    receive() external payable{}
    
    function migrationERC20(
        uint256 _pid,
        IERC20 _tokenA, 
        IERC20 _tokenB, 
        uint256 _amountA,
        uint256 _slippageA,
        uint256 _slippageB

    ) external returns(bool){
        require(_pid < poolsLength(), "migrateERC20: pool doesn't exist");
        PoolInfo storage pool = poolInfo[_pid];
        bool success;

        if(pool.isFixed){
            success = migrateFixeRateERC20(
                _pid,
                _tokenA, 
                _tokenB, 
                _amountA,
                _slippageA,
                _slippageB
            );
        } else {
            success = migrateRealTimeRateERC20(
                _pid,
                _tokenA, 
                _tokenB, 
                _amountA,
                _slippageA,
                _slippageB
            );
        }
        require(success, "ERC20Migration: migration error.");
        return success;
    }


    function getArbitrageMinPrice(uint256 _pid, uint256 _slippageA, uint256 _slippageB, uint256 _amountTokenA)external view  returns(uint256){
        require(_pid < poolsLength(), "getArbitrageMinPrice: pid doesn't exist.");
        PoolInfo memory pool = poolInfo[_pid];
        require(!pool.isFixed, "getArbitrageMinPrice: pool is a fixed amount pool mode.");
        uint256 minAmount1TokenA = _amountTokenA - (uint256(_amountTokenA * _slippageA ) / 100);
        uint256 minAmount2TokenA = minAmount1TokenA - (uint256(minAmount1TokenA * _slippageA ) / 100);
        address[] memory path = new address[](2);
        path[0] = address(pool.tokenA);
        path[1] = pool.routerA.WETH();
        uint256 minAmountWETH = pool.routerA.getAmountsOut(minAmount2TokenA, path)[1];
        path[0] = path[1];
        path[1] = address(pool.tokenB);
        uint256 amountB =  pool.routerB.getAmountsOut(minAmountWETH, path)[1];
        uint256 rawAmount = amountB - uint256(uint256(amountB * _slippageB) / 100);
        return rawAmount - uint256(uint256(rawAmount * pool.fees) / 10000);
    }

    // pool setter
    function setPoolActivated(uint256 _pid, bool _activated) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.activated = _activated;
    }

    function setPoolIsFixed(uint256 _pid, bool _isFixed) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.isFixed = _isFixed;
    }

    function setPoolTokenA(uint256 _pid, IERC20 _tokenA) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.tokenA = _tokenA;
    }

    function setPoolTokenB(uint256 _pid, IERC20 _tokenB) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.tokenB = _tokenB;
    }

    function setPoolBalanceTokenA(uint256 _pid, uint256 _balanceTokenA) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.balanceTokenA = _balanceTokenA;
    }

    function setPoolBalanceTokenB(uint256 _pid, uint256 _balanceTokenB) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.balanceTokenB = _balanceTokenB;
    }

    function setPoolFees(uint256 _pid, uint256 _fees) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.fees = _fees;
    }

    function setRouterA(uint256 _pid, IPancakeRouter02 _routerA) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.routerA = _routerA;
    }

    function setRouterB(uint256 _pid, IPancakeRouter02 _routerB) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.routerB = _routerB;
    }

    function setPairA(uint256 _pid, IPancakePair _pairA) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.pairA = _pairA;
    }

    function setPairB(uint256 _pid, IPancakePair _pairB) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.pairB = _pairB;
    }

    // common setter
    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setBurnAddress(address _burnAddress) external onlyOwner {
        burnAddress = _burnAddress;
    }

    function getAmountOut(uint256 amountIn, uint256 rate, uint256 decimalsTokenA) public pure returns(uint256){
        return uint256(uint256(amountIn * rate)/ 10 ** decimalsTokenA);
    }

    function withdraw(uint256 _ethAmount, bool _withdrawAll) external onlyOwner returns(bool){
        uint256 ethBalance = address(this).balance;
        uint256 ethAmount;
        if(_withdrawAll){
            ethAmount = ethBalance;
        } else {
            ethAmount = _ethAmount;
        }
        require(ethAmount <= ethBalance, "withdraw: eth balance must be larger than amount.");
        (bool success,) = payable(_msgSender()).call{value: ethAmount}(new bytes(0));
        require(success, "withdraw: transfer error.");
        return true;
    }

    function ERC20Withdraw(uint256 _pid, address _tokenAddress, uint256 _tokenAmount, bool _decreasePool, bool _withdrawAll) external onlyOwner returns(bool){
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        require(_tokenAmount <= tokenBalance, "ERC20withdraw: token balance must be larger than amount.");
        token.transfer(_msgSender(), tokenAmount);
        if(_decreasePool){
            PoolInfo storage pool = poolInfo[_pid];
            require(pool.balanceTokenB >= tokenAmount, "ERC20withdraw: pool balance token B must be larger than amount.");
            pool.balanceTokenB -= tokenAmount;
        }
        return true;
    }

    function poolsLength() public view returns(uint256){
        return poolInfo.length;
    }

}