// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "./libraries/Auth.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./libraries/Context.sol";
import "./interfaces/IDinoFarming.sol";
import "./interfaces/IERC20.sol";

contract RouterDinoFarming is Context, Auth {
    using SafeMath for uint256;

    mapping(address => uint256) public lastCalculateShare;

    address public wbnbAddress;
    address public wethAddress;
    address public routerDexAddress;
    
    address public farmingBNBAddress;
    address public farmingBUSDAddress;

    uint256 percentDenominator = 10000;
    uint256 percentBNB = 5000;
    uint256 percentBUSD = 5000;


    constructor() Auth(msg.sender) {
        if(block.chainid == 97) routerDexAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        else if(block.chainid == 56) routerDexAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        else routerDexAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

        wbnbAddress = IUniswapV2Router02(routerDexAddress).WETH();        
        wethAddress = IUniswapV2Router02(routerDexAddress).WETH();
    }

    receive() external payable {
    }

    function deposit() external payable {
        uint256 amountDeposit = msg.value;
        if(farmingBNBAddress != address(0)) {
            uint256 supply = IERC20(farmingBNBAddress).totalSupply();
            if(supply > 0) {
                uint256 amount = amountDeposit.mul(percentBNB).div(percentDenominator);
                IDinoFarming(farmingBNBAddress).deposit{value:amount}();
            }
        }
        if(farmingBUSDAddress != address(0)) {
            uint256 supply = IERC20(farmingBUSDAddress).totalSupply();
            if(supply > 0) {
                uint256 amount = amountDeposit.mul(percentBUSD).div(percentDenominator);
                IDinoFarming(farmingBUSDAddress).deposit{value:amount}();
            }
        }
    }

    function addFarmingETH(address farmingAddress, uint256 amountA, address recipient) external payable {
        uint256 balanceEthBefore = IWETH(wethAddress).balanceOf(address(this));
        IWETH(wethAddress).deposit{value:msg.value}();
        uint256 balanceEthAfter = IWETH(wethAddress).balanceOf(address(this));
        uint256 balanceEthDiff = balanceEthAfter.sub(balanceEthBefore);

        // send weboo to router
        IERC20(IDinoFarming(farmingAddress).tokenA()).transferFrom(_msgSender(),address(this),amountA);

        // add farming
        IERC20(IDinoFarming(farmingAddress).tokenA()).approve(farmingAddress,amountA);
        IERC20(IDinoFarming(farmingAddress).tokenB()).approve(farmingAddress,balanceEthDiff);
        IDinoFarming(farmingAddress).addFarming(amountA,balanceEthDiff,recipient);
    }

    function addFarming(address farmingAddress, uint256 amountA, uint256 amountB, address recipient) external {
        // send weboo to router
        IERC20(IDinoFarming(farmingAddress).tokenA()).transferFrom(_msgSender(),address(this),amountA);
        // send token to router
        IERC20(IDinoFarming(farmingAddress).tokenB()).transferFrom(_msgSender(),address(this),amountB);
        // add farming
        IERC20(IDinoFarming(farmingAddress).tokenA()).approve(farmingAddress,amountA);
        IERC20(IDinoFarming(farmingAddress).tokenB()).approve(farmingAddress,amountB);
        IDinoFarming(farmingAddress).addFarming(amountA,amountB,recipient);
    }

    function removeFarmingETH(address farmingAddress, uint256 amountRemove, address recipient) external {
        uint256 balanceTokenABefore = IERC20(IDinoFarming(farmingAddress).tokenA()).balanceOf(address(this));
        uint256 balanceTokenBBefore = IERC20(IDinoFarming(farmingAddress).tokenB()).balanceOf(address(this));

        //send LP to router
        IERC20(farmingAddress).transferFrom(_msgSender(),address(this),amountRemove);
        IDinoFarming(farmingAddress).removeFarming(amountRemove);

        uint256 balanceTokenAAfter = IERC20(IDinoFarming(farmingAddress).tokenA()).balanceOf(address(this));
        uint256 balanceTokenBAfter = IERC20(IDinoFarming(farmingAddress).tokenB()).balanceOf(address(this));

        uint256 balanceTokenADiff = balanceTokenAAfter.sub(balanceTokenABefore);
        uint256 balanceTokenBDiff = balanceTokenBAfter.sub(balanceTokenBBefore);

        // send token A to recipient
        IERC20(IDinoFarming(farmingAddress).tokenA()).transfer(recipient,balanceTokenADiff);

        //send eth to recipient
        IWETH(wethAddress).withdraw(balanceTokenBDiff);
        payable(recipient).transfer(balanceTokenBDiff);
    }

    function removeFarming(address farmingAddress, uint256 amountRemove, address recipient) external {
        uint256 balanceTokenABefore = IERC20(IDinoFarming(farmingAddress).tokenA()).balanceOf(address(this));
        uint256 balanceTokenBBefore = IERC20(IDinoFarming(farmingAddress).tokenB()).balanceOf(address(this));
        //send LP to router
        IERC20(farmingAddress).transferFrom(_msgSender(),address(this),amountRemove);
        IDinoFarming(farmingAddress).removeFarming(amountRemove);

        uint256 balanceTokenAAfter = IERC20(IDinoFarming(farmingAddress).tokenA()).balanceOf(address(this));
        uint256 balanceTokenBAfter = IERC20(IDinoFarming(farmingAddress).tokenB()).balanceOf(address(this));

        uint256 balanceTokenADiff = balanceTokenAAfter.sub(balanceTokenABefore);
        uint256 balanceTokenBDiff = balanceTokenBAfter.sub(balanceTokenBBefore);

        // send token A to recipient
        IERC20(IDinoFarming(farmingAddress).tokenA()).transfer(recipient,balanceTokenADiff);
        IERC20(IDinoFarming(farmingAddress).tokenB()).transfer(recipient,balanceTokenBDiff);
    }

    function balanceOf(address farmingAddress, address account) external view returns(uint256){
        return IDinoFarming(farmingAddress).balanceOf(account);
    }

    function dividendOf(address farmingAddress, address account) external view returns(uint256) {
        return IDinoFarming(farmingAddress).dividendOf(account);
    }

    function claimTo(address farmingAddress, address account, address targetToken) external {
        IDinoFarming(farmingAddress).claimTo(account,targetToken);
    }

    function claimToWeth(address farmingAddress, address account) external {
        IDinoFarming(farmingAddress).claimToWeth(account);
    }

    function claimToWethIfHasReward(address farmingAddress, address account) public {
        if(IDinoFarming(farmingAddress).dividendOf(account) > 0){
            IDinoFarming(farmingAddress).claimToWeth(account);
        }
    }

    function claimToOther(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to,amount);
    }

    function _claimWeth(address to, uint256 amount) internal {
        if(address(this).balance >= amount){
            payable(to).transfer(amount);
        }
    }
    function claimWeth(address to, uint256 amount) external onlyOwner {
        _claimWeth(to, amount);
    }
    function calculateShare(address farmingAddress) external {
        IDinoFarming(farmingAddress).calculateShare();
        lastCalculateShare[farmingAddress] = block.timestamp;
    }

    function setFarmingBNBAddress(address _address) external onlyOwner {
        farmingBNBAddress = _address;
    }

    function setFarmingBUSDAddress(address _address) external onlyOwner {
        farmingBUSDAddress = _address;
    }

    function setPercentDistribution(uint256 _bnbPercent, uint256 _busdPercent) external onlyOwner {
        percentBNB = _bnbPercent;
        percentBUSD = _busdPercent;
        require(_bnbPercent+_busdPercent==percentDenominator,"Tax Total Should 10000");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "BabyToken: !AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function _getOwner() public view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDinoFarming {
    function tokenA() external view returns(address);
    function tokenB() external view returns(address);
    function addFarming(uint256 amountA, uint256 amountB, address recipient)  external;
    function removeFarming(uint256 amountRemove) external;
    function calculateShare() external;
    function dividendOf(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function claimTo(address account, address targetToken) external;
    function claimToWeth(address account) external;
    function claimTotalOf(address account) external view returns(uint256);
    function deposit() external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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