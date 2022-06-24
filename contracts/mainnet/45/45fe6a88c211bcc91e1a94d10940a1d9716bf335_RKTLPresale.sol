/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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


interface IRKTLToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function getOwner() external view returns (address);
    function getCirculatingSupply() external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function setOwner(address owner) external;
    function setInitialDistributionFinished(bool value) external;
    function clearStuckBalance(address receiver) external;
    function rescueToken(address tokenAddress, uint256 tokens) external returns (bool success);
    function setPresaleFactory(address presaleFactory) external;
    function setAutoRebase(bool autoRebase) external;
    function setRebaseFrequency(uint256 rebaseFrequency) external;
    function setRewardYield(uint256 rewardYield, uint256 rewardYieldDenominator) external;
    function setNextRebase(uint256 nextRebase) external;
    function manualRebase() external;
}


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


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



contract RKTLPresale is Ownable {
    IRKTLToken _RKTLAddress;
    IERC20 _busdAddress;
    IPancakeRouter02 public _pancake02Router;

    // min/max cap
    uint256 public minCapBUSD                                       = 100 * 10 ** 18;
    uint256 public maxCapBUSD                                       = 5000 * 10 ** 18;
    uint256 public pTokenPrice_BUSD                                 = 125 * 10 ** 15;
    
    // presale period
    uint256 public start_time                                       = 1656676800;
    uint256 public end_time                                         = 1657195200;

    // owner address token receive
    address payable presaleOwnerAddress                             = payable(0x794CF29F302dFd6FACaf6f9A85E337feF28443A9);

    mapping (address => uint256) private _userPaidBUSD;

    constructor(address _router, address _RKTL, address _busd) {
        _pancake02Router = IPancakeRouter02(_router);
        _RKTLAddress = IRKTLToken(_RKTL);
        _busdAddress = IERC20(_busd);
    }

    function transferReferralBonus(address addr, uint256 tokenAmount) internal {
        if (addr != address(0)) {
            uint256 referralBonus = tokenAmount * 8 / 100;
            _RKTLAddress.transfer(addr, referralBonus);
        }
    }

    function buyTokensByBUSD(uint256 _amountPrice, address referrer) external {
        require(block.timestamp >= start_time && block.timestamp <= end_time, "RKTLPresale: Not presale period");

        // token amount user want to buy
        uint256 tokenAmount = _amountPrice / pTokenPrice_BUSD * 10 ** 18;

        uint256 currentPaid = _userPaidBUSD[msg.sender];
        require(currentPaid + _amountPrice >= minCapBUSD && currentPaid + _amountPrice <= maxCapBUSD, "RKTLPresale: The price is not allowed for presale.");
        
        // transfer BUSD to owners
        _busdAddress.transferFrom(msg.sender, presaleOwnerAddress, _amountPrice);

        // transfer RKTL token to user
        _RKTLAddress.transfer(msg.sender, tokenAmount);
        
        // transfer token to referrer
        transferReferralBonus(referrer, tokenAmount);
        
        // add BUSD user bought
        _userPaidBUSD[msg.sender] += _amountPrice;

        emit Presale(address(this), msg.sender, tokenAmount);
    }

    function buyTokensByBNB(address referrer) external payable {
        require(block.timestamp >= start_time && block.timestamp <= end_time, "RKTLPresale: Not presale period");
        
        require(msg.value > 0, "Insufficient BNB amount");
        uint256 amountPrice = getLatestBNBPrice (msg.value);
 
        // token amount user want to buy
        uint256 tokenAmount = amountPrice / pTokenPrice_BUSD * 10 ** 18;

        uint256 currentPaid = _userPaidBUSD[msg.sender];
        require(currentPaid + amountPrice >= minCapBUSD && currentPaid + amountPrice <= maxCapBUSD, "RKTLPresale: The price is not allowed for presale.");
        
        // transfer BNB to owner
        presaleOwnerAddress.transfer(msg.value);

        // transfer RKTL token to user
        _RKTLAddress.transfer(msg.sender, tokenAmount);

        // transfer token to referrer
        transferReferralBonus(referrer, tokenAmount);

        // add BUSD user bought
        _userPaidBUSD[msg.sender] += amountPrice;

        emit Presale(address(this), msg.sender, tokenAmount);
    }

    function getLatestBNBPrice(uint256 _amount) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _pancake02Router.WETH();
        path[1] = address(_busdAddress);

        uint256[] memory price_out = _pancake02Router.getAmountsOut(_amount, path);
        uint256 price_round = price_out[1] / 10 ** 18;
        return price_round * 10 ** 18;
    }

    function withdrawAll() external onlyOwner{
        uint256 balance = _RKTLAddress.balanceOf(address(this));
        if(balance > 0) {
            _RKTLAddress.transfer(msg.sender, balance);
        }

        emit WithdrawAll (msg.sender, balance);
    }

    function getUserPaidBUSD () public view returns (uint256) {
        return _userPaidBUSD[msg.sender];
    }

    function setMinCapBUSD(uint256 _minCap) external onlyOwner {
        minCapBUSD = _minCap;

        emit SetMinCap(_minCap);
    }

    function setMaxCapBUSD(uint256 _maxCap) external onlyOwner {
        maxCapBUSD = _maxCap;

        emit SetMaxCap(_maxCap);
    }

    function setStartTime(uint256 _time) external onlyOwner {
        start_time = _time;

        emit SetStartTime(_time);
    }

    function setEndTime(uint256 _time) external onlyOwner {
        end_time = _time;

        emit SetEndTime(_time);
    }

    function setpTokenPriceBUSD(uint256 _pTokenPrice) external onlyOwner {
        pTokenPrice_BUSD = _pTokenPrice;

        emit SetpTokenPrice(_pTokenPrice, 1);
    }

    function setPresaleOwnerAddress(address _add) external onlyOwner {
        presaleOwnerAddress = payable(_add);

        emit SetPresaleOwnerAddress (_add);
    }

    event Presale(address _from, address _to, uint256 _amount);
    event SetMinCap(uint256 _amount);
    event SetMaxCap(uint256 _amount);
    event SetpTokenPrice(uint256 _price, uint _type);
    event SetPresaleOwnerAddress(address _add);
    event SetStartTime(uint256 _time);
    event SetEndTime(uint256 _time);
    event WithdrawAll(address addr, uint256 RKTL);

    receive() payable external {}

    fallback() payable external {}
}