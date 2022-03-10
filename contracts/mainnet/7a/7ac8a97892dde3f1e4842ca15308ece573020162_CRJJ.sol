/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.8.7;

//SPDX-License-Identifier: Apache 2.0

/*
##########################################################################################################################
##########################################################################################################################

Copyright CryptIT GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

##########################################################################################################################
##########################################################################################################################

*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _newOwner();
    }

    function _newOwner() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function __owner() internal view returns (address) {
        return _owner;
    }

    function owner() public view returns (address) {
        return __owner();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

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

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract CRJJ is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private excludedFromFee;

    uint256 private _deltaLPReserve;

    uint256 private _marketingShare;
    uint256 private _stakingShare;
    uint256 private _teamShare;
    uint256 private _lpShare;

    uint256 private _buyTax;
    uint256 private _sellTax;

    uint256 private _marketingTaxCollected;
    uint256 private _stakingTaxCollected;
    uint256 private _teamTaxCollected;
    uint256 private _lpTaxCollected;

    uint256 private minimumTokensValueBeforeSwap;
    uint256 private minimumBNBToTransfer;

    uint256 private acceptSlippageReduceFactor;
    uint256 private acceptFeeOnAddLP;

    address payable public marketingAddress;
    address payable public stakingAddress;
    address payable public teamAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public enableUniSwap;

    bool inSwapAndLiquify;
    bool inSplitShares;
    bool public swapAndLiquifyEnabled;
    bool public autoSplitShares;

    event SwapAndLiquifyEnabledUpdated(bool enabled);

    event EnabledUniswap();
    event UpdateOperationWallet(
        address previousAddress,
        address newAddress,
        string operation
    );

    modifier lockForSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier lockForSplitShare() {
        inSplitShares = true;
        _;
        inSplitShares = false;
    }

    /**
     * @dev Deploy the contract, message sender will get the initial total supply minted.
     * Create initial PancaceSwap V2 pair and router. Can be updated in setRouterAddress()
     *
     * The pair should always be excluded from reward and included in fees.
     *
     */
    function initialize() public {
        _newOwner();
        _name = "ITestYouTest";
        _symbol = "CRT69";
        _decimals = 9;
        _totalSupply = 1 * 10**8 * 10**_decimals;
        _deltaLPReserve = 2 * 10**7 * 10**_decimals;
        _marketingShare = 40;
        _stakingShare = 20;
        _teamShare = 20;
        _lpShare = 20;
        _buyTax = 100;
        _sellTax = 200;
        minimumTokensValueBeforeSwap = 3 * 10**14;
        minimumBNBToTransfer = 1 * 10**15;
        acceptSlippageReduceFactor = 8;
        acceptFeeOnAddLP = 110;
        enableUniSwap = false;
        swapAndLiquifyEnabled = true;
        autoSplitShares = true;

        uint256 initialBalance = _totalSupply.sub(_deltaLPReserve);
        _balances[_msgSender()] = initialBalance;
        _balances[address(this)] = _deltaLPReserve;
        excludedFromFee[_msgSender()] = true;
        excludedFromFee[address(this)] = true;
        // _setRouterAddress(0x10ED43C718714eb63d5aA57B78B54704E256024E); //BCS MAINNET
        // _setRouterAddress(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        emit Transfer(address(0), _msgSender(), initialBalance);
        emit Transfer(address(0), address(this), _deltaLPReserve);
    }

    // Start ERC-20 standard functions

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    // End ERC-20 standart functions

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            emit Transfer(from, to, 0);
            return;
        }

        if (excludedFromFee[from] || excludedFromFee[to]) {
            _transferStandard(from, to, amount);
            return;
        }

        bool isToPair = to == uniswapV2Pair; //means sell or provide LP
        bool isFromPair = from == uniswapV2Pair; //means buy or remove LP

        if (!isToPair && !isFromPair) {
            _transferStandard(from, to, amount);
            return;
        }

        require(enableUniSwap, "Uniswap not enabled yet");

        if (isToPair) {
            if (!inSwapAndLiquify && !inSplitShares) {
                bool swapped = false;
                if (swapAndLiquifyEnabled) {
                    uint256 contractTokenBalance = balanceOf(address(this)).sub(
                        _deltaLPReserve
                    );
                    uint256 contractTokenValue = getSellValue(
                        contractTokenBalance
                    );
                    if (contractTokenValue >= minimumTokensValueBeforeSwap) {
                        _swapAndLiquify(
                            contractTokenBalance,
                            contractTokenValue
                        );
                        swapped = true;
                    }
                }
                if (!swapped && autoSplitShares) {
                    uint256 cBalance = address(this).balance;
                    if (cBalance > minimumBNBToTransfer) {
                        _sendShares(cBalance);
                    }
                }
            }

            _transferToPair(from, to, amount);
        } else {
            _transferFromPair(from, to, amount);
        }
    }

    /**
     * @dev Handles all autoswap to BNB
     *
     * @param tokensToSwap the amount that will be swapped
     *
     * NOTE: will never be called if swapAndLiquify = false!.
     */
    function _swapAndLiquify(uint256 tokensToSwap, uint256 outAmount)
        internal
        lockForSwap
    {
        swapTokensForEth(
            tokensToSwap,
            outAmount.mul(acceptSlippageReduceFactor).div(10)
        );
    }

    function swapAndLiquify() external onlyOwner {
        require(!inSwapAndLiquify, "Cannot swap inSwapAndLiquify");
        require(!inSplitShares, "Cannot swap inSplitShares");
        require(swapAndLiquifyEnabled, "Cannot swap swapAndLiquifyEnabled");

        uint256 contractTokenBalance = balanceOf(address(this)).sub(
            _deltaLPReserve
        );
        uint256 contractTokenValue = getSellValue(contractTokenBalance);

        require(
            contractTokenValue >= minimumTokensValueBeforeSwap,
            "Insuficcient value"
        );

        _swapAndLiquify(contractTokenBalance, contractTokenValue);
    }

    /**
     * @dev Handles swaping tokens stored on the contract, half of the {amount} for BNB and adding it with the other hald of tokens to LP
     *
     * @param BNBAmount amount of BNB to provide LP for
     * @return addedLP true on successful readd, false if not enought delta tokens
     *
     */
    function reAddLiquidity(uint256 BNBAmount, uint256 tokenAmount)
        internal
        returns (bool)
    {
        uint256 amountToken = addLiquidity(tokenAmount, BNBAmount);

        if (amountToken != 0) {
            _deltaLPReserve = _deltaLPReserve.sub(amountToken);
            return true;
        }
        return false;
    }

    /**
     * @dev Handles add {tokenAmount} and {BNBAmount} to LP
     *
     * @param tokenAmount amount of tokens to be added to LP
     * @param BNBAmount amount of BNB to be added to LP
     *
     * NOTE: LP tokens will be sent to the owner address.
     *
     */
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount)
        internal
        returns (uint256)
    {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        try
            uniswapV2Router.addLiquidityETH{value: BNBAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                __owner(),
                block.timestamp
            )
        returns (uint256 amountToken, uint256, uint256) {
            return amountToken;
        } catch {
            return 0;
        }
    }

    /**
     * @dev Handles selling of {tokenAmount}
     *
     * @param tokenAmount the amount of tokens to swap for BNB
     *
     */
    function swapTokensForEth(uint256 tokenAmount, uint256 expectedOutput)
        internal
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            expectedOutput,
            path,
            address(this),
            block.timestamp
        );
    }

    function getBuyValue(uint256 BNBAmount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        return uniswapV2Router.getAmountsIn(BNBAmount, path)[0];
    }

    function getSellValue(uint256 tokenAmount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        return uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
    }

    function _sendShares(uint256 amount) internal lockForSplitShare {
        uint256 mShare = amount.mul(_marketingShare).div(100);
        uint256 sShare = amount.mul(_stakingShare).div(100);
        uint256 lpShare = amount.mul(_lpShare).div(100);
        uint256 tShare = amount.sub(mShare).sub(sShare).sub(lpShare);

        bool sentLP;
        uint256 tokenAmount = getBuyValue(lpShare).mul(acceptFeeOnAddLP).div(
            100
        );

        if (_deltaLPReserve < tokenAmount) {
            tShare = tShare.add(lpShare);
        } else {
            sentLP = reAddLiquidity(lpShare, tokenAmount);

            if (!sentLP) {
                tShare = tShare.add(lpShare);
                sentLP = true;
            } else {
                _lpTaxCollected = _lpTaxCollected.add(lpShare);
            }
        }

        (bool sentM, ) = marketingAddress.call{value: mShare}("");
        (bool sentG, ) = stakingAddress.call{value: sShare}("");
        (bool sentT, ) = teamAddress.call{value: tShare}("");

        require(sentM && sentG && sentT && sentLP, "Failed to send shares");

        _marketingTaxCollected = _marketingTaxCollected.add(mShare);
        _stakingTaxCollected = _stakingTaxCollected.add(sShare);
        _teamTaxCollected = _teamTaxCollected.add(tShare);
    }

    function sendShares() external onlyOwner {
        _sendShares(address(this).balance);
    }

    function provideLP(uint256 tokenAmount) external payable {
        uint256 initBalance = balanceOf(msg.sender);
        require(initBalance >= tokenAmount, "Insufficient token balance");

        _balances[msg.sender] = _balances[msg.sender].sub(tokenAmount);
        _balances[address(this)] = _balances[address(this)].add(tokenAmount);
        emit Transfer(msg.sender, address(this), tokenAmount);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            tokenAmount,
            tokenAmount,
            msg.value,
            __owner(),
            block.timestamp + 10 minutes
        );
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _transferToPair(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);

        uint256 tax = amount.mul(_sellTax).div(1000);
        uint256 receiveAmount = amount.sub(tax);

        _balances[address(this)] = _balances[address(this)].add(tax);

        _balances[recipient] = _balances[recipient].add(receiveAmount);

        emit Transfer(sender, recipient, receiveAmount);
    }

    function _transferFromPair(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);

        uint256 tax = amount.mul(_buyTax).div(1000);
        uint256 receiveAmount = amount.sub(tax);

        _balances[address(this)] = _balances[address(this)].add(tax);

        _balances[recipient] = _balances[recipient].add(receiveAmount);

        emit Transfer(sender, recipient, receiveAmount);
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return excludedFromFee[account];
    }

    function includeInFee(address account) external onlyOwner {
        excludedFromFee[account] = false;
    }

    function excludeFromFee(address account) external onlyOwner {
        excludedFromFee[account] = true;
    }

    /**
     * @dev owner only function to set the marketing address
     *
     * Emits an {UpdateOperationWallet} event.
     *
     */
    function setMarketingAddress(address payable _marketingAddress)
        external
        onlyOwner
    {
        address prevMarketing = marketingAddress;
        marketingAddress = _marketingAddress;
        excludedFromFee[marketingAddress] = true;
        excludedFromFee[prevMarketing] = false;
        emit UpdateOperationWallet(
            prevMarketing,
            marketingAddress,
            "marketing"
        );
    }

    /**
     * @dev owner only function to set the support organizations address
     *
     * Emits an {UpdateOperationWallet} event.
     *
     */
    function setStakingAddress(address payable _stakingAddress)
        external
        onlyOwner
    {
        address prevStaking = stakingAddress;
        stakingAddress = _stakingAddress;
        excludedFromFee[stakingAddress] = true;
        excludedFromFee[prevStaking] = false;
        emit UpdateOperationWallet(prevStaking, stakingAddress, "staking");
    }

    /**
     * @dev owner only function to set the employees address
     *
     * Emits an {UpdateOperationWallet} event.
     *
     */
    function setTeamAddress(address payable _teamAddress) external onlyOwner {
        address prevTeam = teamAddress;
        teamAddress = _teamAddress;
        excludedFromFee[teamAddress] = true;
        excludedFromFee[prevTeam] = false;
        emit UpdateOperationWallet(prevTeam, teamAddress, "team");
    }

    function _setOperatorsAddresses(
        address payable _marketingAddress,
        address payable _stakingAddress,
        address payable _teamAddress
    ) internal {
        address prevMarketing = marketingAddress;
        address prevStaking = stakingAddress;
        address prevTeam = teamAddress;
        marketingAddress = _marketingAddress;
        stakingAddress = _stakingAddress;
        teamAddress = _teamAddress;
        excludedFromFee[marketingAddress] = true;
        excludedFromFee[stakingAddress] = true;
        excludedFromFee[teamAddress] = true;
        excludedFromFee[prevMarketing] = false;
        excludedFromFee[prevStaking] = false;
        excludedFromFee[prevTeam] = false;
        emit UpdateOperationWallet(
            prevMarketing,
            marketingAddress,
            "marketing"
        );
        emit UpdateOperationWallet(prevStaking, stakingAddress, "staking");
        emit UpdateOperationWallet(prevTeam, teamAddress, "team");
    }

    function setOperatorsAddresses(
        address payable _marketingAddress,
        address payable _stakingAddress,
        address payable _teamAddress
    ) external onlyOwner {
        _setOperatorsAddresses(
            _marketingAddress,
            _stakingAddress,
            _teamAddress
        );
    }

    function setStakingShare(uint256 stakingShare) external onlyOwner {
        uint256 totalShare = stakingShare
            .add(_marketingShare)
            .add(_teamShare)
            .add(_lpShare);
        require(totalShare <= 100, "Cannot set share higher than 100%");
        _marketingShare = stakingShare;
    }

    function setMarketingShare(uint256 marketingShare) external onlyOwner {
        uint256 totalShare = marketingShare
            .add(_stakingShare)
            .add(_teamShare)
            .add(_lpShare);
        require(totalShare <= 100, "Cannot set share higher than 100%");
        _stakingShare = marketingShare;
    }

    function setTeamShare(uint256 teamShare) external onlyOwner {
        uint256 totalShare = teamShare
            .add(_marketingShare)
            .add(_stakingShare)
            .add(_lpShare);
        require(totalShare <= 100, "Cannot set share higher than 100%");
        _teamShare = teamShare;
    }

    function setLPShare(uint256 lpShare) external onlyOwner {
        uint256 totalShare = lpShare
            .add(_marketingShare)
            .add(_stakingShare)
            .add(_teamShare);
        require(totalShare <= 100, "Cannot set share higher than 100%");
        _lpShare = lpShare;
    }

    function setBuyTax(uint256 buyTax) external onlyOwner {
        require(buyTax <= 250, "Cannot set fees higher than 25%!");
        _buyTax = buyTax;
    }

    function getBuyTax() external view returns (uint256) {
        return _buyTax;
    }

    function setSellTax(uint256 sellTax) external onlyOwner {
        require(sellTax <= 250, "Cannot set fees higher than 25%!");
        _sellTax = sellTax;
    }

    function getSellTax() external view returns (uint256) {
        return _sellTax;
    }

    /**
     * @dev public function to read the limiter on when the contract will auto convert to BNB
     *
     */
    function getTokenAutoSwapLimit() external view returns (uint256) {
        return minimumTokensValueBeforeSwap;
    }

    /**
     * @dev owner only function to set the limit of tokens to sell for BNB when reached
     *
     * @param _minimumTokensValueBeforeSwap the amount tokens BNB value when to sell from the contract
     *
     */
    function setTokenAutoSwapLimit(uint256 _minimumTokensValueBeforeSwap)
        external
        onlyOwner
    {
        minimumTokensValueBeforeSwap = _minimumTokensValueBeforeSwap;
    }

    function getBNBAutoTransferLimit() external view returns (uint256) {
        return minimumBNBToTransfer;
    }

    function setBNBAutoTransferLimit(uint256 _minimumBNBToTransfer)
        external
        onlyOwner
    {
        minimumBNBToTransfer = _minimumBNBToTransfer;
    }

    /**
     * @dev owner only function to control if the autoswap to BNB should happen
     *
     * Emits an {SwapAndLiquifyEnabledUpdated} event.
     *
     */
    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setAutoSplitSharesEnables(bool _enabled) external onlyOwner {
        autoSplitShares = _enabled;
    }

    function enableUniswap() external onlyOwner {
        require(enableUniSwap == false, "Already enabled!");
        enableUniSwap = true;
        emit EnabledUniswap();
    }

    function setAcceptedSlippage(uint256 accepted) external onlyOwner {
        acceptSlippageReduceFactor = accepted;
    }

    function getAcceptedSlippage() external view onlyOwner returns (uint256) {
        return acceptSlippageReduceFactor;
    }

    function setAcceptedFeeOnAdd(uint256 accepted) external onlyOwner {
        acceptFeeOnAddLP = accepted;
    }

    function getAcceptedFeeOnAdd() external view onlyOwner returns (uint256) {
        return acceptFeeOnAddLP;
    }

    function _setRouterAddress(address newRouter) internal {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        IUniswapV2Factory factory = IUniswapV2Factory(
            _newPancakeRouter.factory()
        );

        address existingPair = factory.getPair(
            address(this),
            _newPancakeRouter.WETH()
        );

        if (existingPair == address(0)) {
            uniswapV2Pair = factory.createPair(
                address(this),
                _newPancakeRouter.WETH()
            );
        } else {
            uniswapV2Pair = existingPair;
        }
        uniswapV2Router = _newPancakeRouter;
    }

    /**
     * @dev owner only function to set a new router address and create a new pair.
     *
     */
    function setRouterAddress(address newRouter) external onlyOwner {
        _setRouterAddress(newRouter);
    }

    function totalTeamTaxCollected() external view onlyOwner returns (uint256) {
        return _teamTaxCollected;
    }

    function totalMarketingTaxCollected()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _marketingTaxCollected;
    }

    function totalStakingTaxCollected()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _stakingTaxCollected;
    }

    function totalLPTaxCollected() external view onlyOwner returns (uint256) {
        return _lpTaxCollected;
    }

    function totalTaxCollected() external view onlyOwner returns (uint256) {
        return
            _marketingTaxCollected +
            _teamTaxCollected +
            _stakingTaxCollected +
            _lpTaxCollected;
    }

    function getDeltaReserve() external view returns (uint256) {
        return _deltaLPReserve;
    }

    function depositIntoReserve(uint256 amount) external {
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _deltaLPReserve = _deltaLPReserve.add(amount);
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(_msgSender(), address(this), amount);
    }

    function burn(uint256 amount) external {
        require(balanceOf(_msgSender()) >= amount, "Insufficient balance");
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(_msgSender(), address(0), amount);
    }

    function O_BuyValue(uint256 BNBAmount) external view returns (uint256) {
        return getBuyValue(BNBAmount);
    }

    function O_SellValue(uint256 tokenAmount) external view returns (uint256) {
        return getSellValue(tokenAmount);
    }

    receive() external payable {}
}