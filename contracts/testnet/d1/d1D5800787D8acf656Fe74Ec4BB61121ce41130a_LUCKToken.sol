/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

pragma solidity ^0.8.11;
//SPDX-License-Identifier: UNLICENSED


library AddressAddressKeyIterableMapping {
    struct Record {
        bool exists; // this feels like a waste of storage...
        uint256 index;
    }

    struct Store {
        mapping(address => Record) map;
        address[] keys;
    }

    function keyCount(Store storage store) internal view returns (uint256 count) {
        count = store.keys.length;
    }

    function keyAt(Store storage store, uint256 index) internal view returns (address key) {
        key = store.keys[index];
    }

    function allKeys(Store storage store) internal view returns (address[] memory keys) {
        keys = store.keys;
    }

    function get(Store storage store, address key) internal view returns (bool exists) {
        Record storage rec = store.map[key];
        exists = rec.exists;
    }

    function put(Store storage store, address key) internal returns (bool replaced) {
        replaced = false;
        if (store.map[key].exists) {
            removeFromArray(store, key);
            // we have to change the array, can't just overwrite the fields
            replaced = true;
        }
        store.keys.push(key);
        Record storage rec = store.map[key];
        rec.exists = true;
        rec.index = store.keys.length - 1;
    }

    function remove(Store storage store, address key) internal returns (bool deleted) {
        if (store.map[key].exists) {
            removeFromArray(store, key);
            // we have to change the array, can't just overwrite the fields
            delete store.map[key];
            deleted = true;
        }
        else {
            deleted = false;
        }
    }

    function removeFromArray(Store storage store, address key) private {
        uint256 index = store.map[key].index;
        uint256 lastIndex = store.keys.length - 1;
        if (index != lastIndex) {
            require(store.keys[index] == key);
            address lastKey = store.keys[store.keys.length - 1];
            Record storage last = store.map[lastKey];
            store.keys[index] = lastKey;
            last.index = index;
        }
        store.keys.pop();
    }
}

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


contract LUCKToken {
    string public name = "LUCK token";
    string public symbol = "LUCK";
    uint256 public totalSupply;
    uint256 public detectiontime;
    uint256 public unlockingtime;
    uint256 public unlockingtime2;
    uint256 public unlockingtime3;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isPairCon;
    uint8 public decimals = 18;

    uint8 public levleMax;
    uint8 public fee;
    uint8 public burnfee;
    uint8 public fundpoolWalletfee;
    uint8 public foundersWalletfee;
    uint8 public communityWalletfee;
    uint8 public marketingWalletfee;
    uint8 public liquiditycontributionfee;
    uint8 public founderWalletfee;
    uint8 public marketingfee;
    uint8 public fundWalletfee;

    address public fundpoolWalletAddr = address(0x34C1841c5DC9F7390A556305Bb1f0d67Fbe9947F);
    address public foundersWalletAddr = address(0xfe4242864F982171Cb86cd3A95540Dc77A621a46);
    address public communityWalletAddr = address(0xabBC351682aA1Fe5B15522aE3Bc616f6448eaD6F);
    address public marketingWalletAddr = address(0xE864EC0406FEa97699e00acBEbA3d06028d7984b);
    address public liquiditycontributionAddr = address(0x4b413d8ABfDedd8BDfc6Db81c9C261C586071509);
    address public founderWalletAddr = address(0xEAD5a825Cb86092B02cbF44B0AA38596b356f915);
    address public fundWalletAddr = address(0x56FF3197d952a79a0ea76bb01422cf2674811E5d);
    address public lockaccountAddr = address(0x08C2D41512c8fcF888c98910a66b424BA25bE7e9);
    address public lockaccountAddr2 = address(0xC31C1A8C484CBbE5128C9e3C6a862A422D2D32f8);
    address public lockaccountAddr3 = address(0x4b413d8ABfDedd8BDfc6Db81c9C261C586071509);



    address public Deployer;
    address _burnaddr = address(0x000000000000000000000000000000000000dEaD);
    address private USDTaddr = address(0x55d398326f99059fF775485246999027B3197955);
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    mapping(address => bool)public botlist;
    mapping(uint8 => uint8)public levelTofee;
    mapping(address => address)public upOneLevel;
    mapping(address => bool)public isregister;
    mapping(address => mapping(address => uint256)) public allowance;

    AddressAddressKeyIterableMapping.Store private LpAddressList;

    IERC20 public uniswapV2Paircontract;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    constructor(){
        unlockingtime = block.timestamp + 7776000;
        unlockingtime2 = block.timestamp + 5184000;
        unlockingtime3 = block.timestamp + 1296000;
        Deployer = address(0x880c522bF14AC4Ed6075F57572E66062d5DE8DEA);
        totalSupply = 21000 * 10 ** uint256(decimals);
        balanceOf[Deployer] = 5250 * 10 ** uint256(decimals);
        balanceOf[lockaccountAddr] = 10500 * 10 ** uint256(decimals);
        balanceOf[lockaccountAddr2] = 3150 * 10 ** uint256(decimals);
        balanceOf[lockaccountAddr3] = 2100 * 10 ** uint256(decimals);
        isExcludedFromFee[Deployer] = true;
        isExcludedFromFee[lockaccountAddr] = true;
        isExcludedFromFee[lockaccountAddr2] = true;
        isExcludedFromFee[lockaccountAddr3] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[fundpoolWalletAddr] = true;
        isExcludedFromFee[foundersWalletAddr] = true;
        isExcludedFromFee[communityWalletAddr] = true;
        isExcludedFromFee[marketingWalletAddr] = true;
        isExcludedFromFee[liquiditycontributionAddr] = true;
        isExcludedFromFee[founderWalletAddr] = true;
        isExcludedFromFee[fundWalletAddr] = true;


        levelTofee[1] = 15;
        levelTofee[2] = 25;
        levelTofee[3] = 10;
        levelTofee[4] = 10;
        levelTofee[5] = 10;
        levelTofee[6] = 10;
        levelTofee[7] = 10;
        levelTofee[8] = 10;
        levleMax = 8;
        fee = 10;

        burnfee = 5;
        fundpoolWalletfee = 10;
        foundersWalletfee = 9;
        communityWalletfee = 9;
        marketingWalletfee = 8;
        liquiditycontributionfee = 13;
        founderWalletfee = 6;
        marketingfee = 30;
        fundWalletfee = 10;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3   0x10ED43C718714eb63d5aA57B78B54704E256024E
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(USDTaddr));
        isPairCon[uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Paircontract = IERC20(uniswapV2Pair);
        emit Transfer(address(0), Deployer, 5250 * 10 ** uint256(decimals));
        emit Transfer(address(0), lockaccountAddr, 10500 * 10 ** uint256(decimals));
        emit Transfer(address(0), lockaccountAddr2, 3150 * 10 ** uint256(decimals));
        emit Transfer(address(0), lockaccountAddr3, 2100 * 10 ** uint256(decimals));
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        if (!isContract(msg.sender) && !isContract(_to)) {
            _registerLogic(msg.sender, _to);
        }
        return true;
    }

    function _registerLogic(address _from, address _to) private {
        if (isExcludedFromFee[_from] && !isregister[_to]) {
            isregister[_to] = true;
        } else if (isregister[_from] && !isregister[_to]) {
            upOneLevel[_to] = _from;
            isregister[_to] = true;
        }
    }
    bool public regularWay;

    function UPregularWay()external {
        require(Deployer==msg.sender);
        if(regularWay){
            regularWay = false;
        }else{
            regularWay = true;
        }
    }

    

    function _transfer(address _from, address _to, uint256 _value) private returns (bool) {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value > 0, "err:_value <= 0");
        require(balanceOf[_from] >= _value, "err:balanceOf[_from] < _value");
        require(balanceOf[_to] + _value > balanceOf[_to], "err:balanceOf[_to] + _value <= balanceOf[_to]");
        if(regularWay){
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;
            emit Transfer(_from, _to, _value);
            return true;
        }

        require(!botlist[_from] && !botlist[_to], "err:from or to is bot!");

        if (_from == lockaccountAddr) {
            require(unlockingtime <= block.timestamp);
        }else if (_from == lockaccountAddr2) {
            require(unlockingtime2 <= block.timestamp);
        }else if (_from == lockaccountAddr3) {
            require(unlockingtime3 <= block.timestamp);
        }

        if (detectiontime == 0) {
            detectiontime = block.timestamp + 1;
        }
        if (block.timestamp <= detectiontime && !isExcludedFromFee[_from] && !isExcludedFromFee[_to]) {
            botlist[_to] = true;
        }
        if (!isExcludedFromFee[_from] && !isExcludedFromFee[_to]) {
            if(!isPairCon[_to]){
                require(balanceOf[_to] + _value <= 5 * 10 ** 18, "err:balanceOf[_to]>5 token");
            }
            
            require(_value <= 10 ** 18, "err:value>1 token");
        }

        if (!isContract(_to) && !isContract(_from)) {
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;
            emit Transfer(_from, _to, _value);
            return true;
        }


        if (isExcludedFromFee[_from] || isExcludedFromFee[_to]) {
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        if (!isExcludedFromFee[_from] && !isExcludedFromFee[_to]) {
            balanceOf[_from] = balanceOf[_from] - _value;
            uint256 value_ = _value * fee / 100;
            uint256 amount_ = _value - value_;
            balanceOf[_to] += amount_;
            balanceOf[address(this)] += value_;
            emit Transfer(_from, _to, amount_);
            emit Transfer(_from, address(this), value_);

            uint256 Sum;
            Sum += (balanceOf[address(this)] * burnfee / 100);
            balanceOf[_burnaddr] += (balanceOf[address(this)] * burnfee / 100);
            emit Transfer(address(this), _burnaddr, balanceOf[address(this)] * burnfee / 100);
            Sum += (balanceOf[address(this)] * fundpoolWalletfee / 100);
            balanceOf[fundpoolWalletAddr] += (balanceOf[address(this)] * fundpoolWalletfee / 100);
            emit Transfer(address(this), fundpoolWalletAddr, (balanceOf[address(this)] * fundpoolWalletfee / 100));
            Sum += (balanceOf[address(this)] * foundersWalletfee / 100);
            balanceOf[foundersWalletAddr] += (balanceOf[address(this)] * foundersWalletfee / 100);
            emit Transfer(address(this), foundersWalletAddr, (balanceOf[address(this)] * foundersWalletfee / 100));
            Sum += (balanceOf[address(this)] * communityWalletfee / 100);
            balanceOf[communityWalletAddr] += (balanceOf[address(this)] * communityWalletfee / 100);
            emit Transfer(address(this), communityWalletAddr, (balanceOf[address(this)] * communityWalletfee / 100));
            Sum += (balanceOf[address(this)] * marketingWalletfee / 100);
            balanceOf[marketingWalletAddr] += (balanceOf[address(this)] * marketingWalletfee / 100);
            emit Transfer(address(this), marketingWalletAddr, (balanceOf[address(this)] * marketingWalletfee / 100));
            Sum += (balanceOf[address(this)] * liquiditycontributionfee / 100);
            balanceOf[liquiditycontributionAddr] += (balanceOf[address(this)] * liquiditycontributionfee / 100);
            emit Transfer(address(this), liquiditycontributionAddr, (balanceOf[address(this)] * liquiditycontributionfee / 100));
            Sum += (balanceOf[address(this)] * founderWalletfee / 100);
            balanceOf[founderWalletAddr] += (balanceOf[address(this)] * founderWalletfee / 100);
            emit Transfer(address(this), founderWalletAddr, (balanceOf[address(this)] * founderWalletfee / 100));
            Sum += (balanceOf[address(this)] * fundWalletfee / 100);
            balanceOf[fundWalletAddr] += (balanceOf[address(this)] * fundWalletfee / 100);
            emit Transfer(address(this), fundWalletAddr, (balanceOf[address(this)] * fundWalletfee / 100));
            balanceOf[address(this)] -= Sum;

            if (isContract(_from) && !isContract(_to)) {
                if (isregister[_to] && upOneLevel[_to] != address(0)) {
                    address _temporary = _to;
                    uint256 this_balance = balanceOf[address(this)];
                    for (uint8 i = 1; i <= levleMax; i++) {
                        if (upOneLevel[_temporary] == address(0)) {
                            break;
                        } else {
                            uint256 _v = levelTofee[i] * balanceOf[address(this)] / 100;
                            if (this_balance >= _v) {
                                this_balance -= _v;
                                balanceOf[upOneLevel[_temporary]] += _v;
                                emit Transfer(address(this), upOneLevel[_temporary], _v);
                                _temporary = upOneLevel[_temporary];
                            } else {
                                break;
                            }
                        }
                    }
                    balanceOf[address(this)] = this_balance;
                    if (balanceOf[address(this)] > 0) {
                        balanceOf[marketingWalletAddr] += balanceOf[address(this)];
                        emit Transfer(address(this), marketingWalletAddr, balanceOf[address(this)]);
                        balanceOf[address(this)] = 0;
                    }

                } else {
                    balanceOf[marketingWalletAddr] += balanceOf[address(this)];
                    emit Transfer(address(this), marketingWalletAddr, balanceOf[address(this)]);
                    balanceOf[address(this)] = 0;
                    isregister[_to] = true;
                }
                if (AddressAddressKeyIterableMapping.get(LpAddressList, _to)) {
                    if (uniswapV2Paircontract.balanceOf(_to) * 100 / uniswapV2Paircontract.totalSupply() < 5) {
                        AddressAddressKeyIterableMapping.remove(LpAddressList, _to);
                    }
                } else {
                    if (uniswapV2Paircontract.balanceOf(_to) * 100 / uniswapV2Paircontract.totalSupply() >= 5) {
                        AddressAddressKeyIterableMapping.put(LpAddressList, _to);
                    }
                }

            } else if (!isContract(_from) && isContract(_to)) {
                if (isregister[_from] && upOneLevel[_from] != address(0)) {
                    address _temporary = _from;
                    uint256 this_balance = balanceOf[address(this)];
                    for (uint8 i = 1; i <= levleMax; i++) {
                        if (upOneLevel[_temporary] == address(0)) {
                            break;
                        } else {
                            uint256 _v = levelTofee[i] * balanceOf[address(this)] / 100;
                            if (this_balance >= _v) {
                                this_balance -= _v;
                                balanceOf[upOneLevel[_temporary]] += _v;
                                emit Transfer(address(this), upOneLevel[_temporary], _v);
                                _temporary = upOneLevel[_temporary];
                            } else {
                                break;
                            }
                        }
                    }
                    balanceOf[address(this)] = this_balance;
                    if (balanceOf[address(this)] > 0) {
                        balanceOf[marketingWalletAddr] += balanceOf[address(this)];
                        emit Transfer(address(this), marketingWalletAddr, balanceOf[address(this)]);
                        balanceOf[address(this)] = 0;
                    }
                } else {
                    balanceOf[marketingWalletAddr] += balanceOf[address(this)];
                    emit Transfer(address(this), marketingWalletAddr, balanceOf[address(this)]);
                    balanceOf[address(this)] = 0;
                    isregister[_from] = true;
                }
                if (AddressAddressKeyIterableMapping.get(LpAddressList, _from)) {
                    if (uniswapV2Paircontract.balanceOf(_from) * 100 / uniswapV2Paircontract.totalSupply() < 5) {
                        AddressAddressKeyIterableMapping.remove(LpAddressList, _from);
                    }
                }
            } else {
                if (balanceOf[address(this)] > 0) {
                    balanceOf[marketingWalletAddr] += balanceOf[address(this)];
                    emit Transfer(address(this), marketingWalletAddr, balanceOf[address(this)]);
                    balanceOf[address(this)] = 0;
                }
            }

            if (balanceOf[address(liquiditycontributionAddr)] >= 20000 * 10 ** 18) {
                uint256 count = AddressAddressKeyIterableMapping.keyCount(LpAddressList);
                uint256 liquiditycontributionAddr_amount = balanceOf[address(liquiditycontributionAddr)];
                uint256 sumLP;
                for (uint256 n = 0;n < count; n++){
                    sumLP += uniswapV2Paircontract.balanceOf(AddressAddressKeyIterableMapping.keyAt(LpAddressList, n));
                }
                for (uint256 j = 0; j < count; j++) {
                    uint256 Value = (uniswapV2Paircontract.balanceOf(AddressAddressKeyIterableMapping.keyAt(LpAddressList, j)) * balanceOf[address(liquiditycontributionAddr)] / sumLP);
                    liquiditycontributionAddr_amount -= Value;
                    balanceOf[address(AddressAddressKeyIterableMapping.keyAt(LpAddressList, j))] += Value;
                    emit Transfer(address(this), address(AddressAddressKeyIterableMapping.keyAt(LpAddressList, j)), Value);
                }
                balanceOf[address(liquiditycontributionAddr)] = liquiditycontributionAddr_amount;
            }
            return true;
        } else {
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;
            emit Transfer(_from, _to, _value);
            return true;
        }

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
        return true;
    }

    function _approve(
        address _send,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_send != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowance[_send][_spender] = _amount;
        emit Approval(_send, _spender, _amount);
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        address _send = msg.sender;
        _approve(_send, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        address _send = msg.sender;
        _approve(_send, _spender, allowance[_send][_spender] + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        address _send = msg.sender;
        uint256 currentAllowance = allowance[_send][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_send, _spender, currentAllowance - _subtractedValue);
    }
        return true;
    }

    receive() external payable {

    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
    
    function InvitationInfo(address _addr)public view returns(uint256,uint256){
        uint256 NumberOfPeople;
        uint256 total;
        if (isregister[_addr] && upOneLevel[_addr] != address(0)) {
            address _temporary = _addr;
            for (uint8 i = 1; i <= levleMax; i++) {
                if (upOneLevel[_temporary] == address(0)) {
                    break;
                } else {
                    total += balanceOf[upOneLevel[_temporary]];
                    NumberOfPeople += 1;
                    _temporary = upOneLevel[_temporary];
                }
            }
        }
        return (NumberOfPeople,total);
    }

    function UpdateBotlistStatus(address _addr)external{
        require(Deployer==msg.sender);
        if(botlist[_addr]){
            botlist[_addr]=false;
        }else{
            botlist[_addr]=true;
        }
    }

    function UpdateExcludedFromFee(address _addr)external{
        require(Deployer==msg.sender);
        if(isExcludedFromFee[_addr]){
            isExcludedFromFee[_addr]=false;
        }else{
            isExcludedFromFee[_addr]=true;
        }
    }
    
    function UpdatePairCon(address _pair) external{
        require(Deployer==msg.sender);
        if(isPairCon[_pair]){
            isPairCon[_pair] = false;
        }else{
            isPairCon[_pair] = true;
        }
    }


}