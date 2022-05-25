/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
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


contract RockProject is Ownable {
    // Mainnet BUSD: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    // Testnet BUSD: 0x03123Ef4d682d287c05c99Aeb70CA3A596acd7bb

    // Mainnet ROCK: 0xC3387E4285e9F80A7cFDf02B4ac6cdF2476A528A
    // Testnet ROCK: 0xCDEe7291FAF5E05d5fB99b7C571A61789C95245a

    // Mainnet Router: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Testnet Router: 0x1946458cBA161D112105692a884CC3FF4b05a301

    // Mainnet Admin: 0xBB2a8658df0cA295a94aE6E270b7EB610086752e
    // Testnet Admin: 0xD28202CcffD5568083e1289FD4dCE6D9A8Cbc691

    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 bedrock = IERC20(0xC3387E4285e9F80A7cFDf02B4ac6cdF2476A528A);
    IPancakeRouter01 router =
        IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public BEDROCK_ADMIN = 0xBB2a8658df0cA295a94aE6E270b7EB610086752e;

    uint8 public profitPercentage;
    uint256 public raiseAmount;
    uint256 public ventureTime;
    uint256 public collateralRock;

    address[] public investors;
    mapping(address => uint256) public investments;

    uint256 public raiseAcheivedTime;
    string public ventureState;

    constructor(
        uint8 _profit,
        uint256 _raiseAmountUsd,
        uint256 _ventureMonths
    ) {
        require(
            _profit > 0 &&
                _raiseAmountUsd >= 100000000000000000000 &&
                _ventureMonths > 0,
            "One of the attributes are invalid"
        );
        profitPercentage = _profit;
        raiseAmount = _raiseAmountUsd;
        ventureTime = _ventureMonths * 2628000;

        ventureState = "PENDING_COLLATERAL";
    }

    function depositCollateral() external onlyOwner {
        require(
            keccak256(abi.encodePacked(ventureState)) ==
                keccak256(abi.encodePacked("PENDING_COLLATERAL")),
            "Project has already initiated!"
        );

        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(bedrock);
        collateralRock = router.getAmountsOut(raiseAmount / 2, path)[1];

        require(
            bedrock.balanceOf(_msgSender()) >= collateralRock,
            "You do not have 50% rock to put as collateral!"
        );
        bedrock.transferFrom(_msgSender(), address(this), collateralRock);

        bedrock.approve(BEDROCK_ADMIN, 2 * collateralRock);
        busd.approve(BEDROCK_ADMIN, 2 * raiseAmount);
        bedrock.approve(address(router), 2 * collateralRock);
        busd.approve(address(router), 2 * raiseAmount);

        ventureState = "ACCEPTING_INVESTMENTS";
    }

    function invest(uint256 usdAmount) external {
        require(
            keccak256(abi.encodePacked(ventureState)) ==
                keccak256(abi.encodePacked("ACCEPTING_INVESTMENTS")),
            "Project is not accepting any investments!"
        );
        uint256 totalInvested = busd.balanceOf(address(this));
        require(
            totalInvested + usdAmount <= raiseAmount,
            "The project does not need this much investment!"
        );

        busd.transferFrom(_msgSender(), address(this), usdAmount);
        investments[_msgSender()] += usdAmount;
        investors.push(_msgSender());

        if (totalInvested + usdAmount >= raiseAmount) {
            raiseAcheivedTime = block.timestamp;
            ventureState = "RAISE_ACHEIVED";

            uint256 platformFee = (collateralRock * 5) / 100;
            bedrock.transfer(BEDROCK_ADMIN, platformFee);
        }
    }

    function cancelRaise() external onlyOwner {
        for (uint256 i = 0; i < investors.length; i++) {
            if (investments[investors[i]] > 0) {
                busd.transfer(investors[i], investments[investors[i]]);
                delete investments[investors[i]];
                delete investors[i];
            }
        }
        bedrock.transfer(_msgSender(), collateralRock);
        ventureState = "RAISE_CANCELLED";
    }

    function pullInvestments() external {
        uint256 myInvestment = investments[_msgSender()];
        require(
            myInvestment > 0,
            "You do not have any investments on this project!"
        );

        if (raiseAcheivedTime == 0) {
            busd.transfer(_msgSender(), myInvestment);
        } else if (block.timestamp >= raiseAcheivedTime + ventureTime) {
            uint256 myShare = (myInvestment * 100) / raiseAmount;

            if (collateralRock > 0) {
                address[] memory path = new address[](2);
                path[0] = address(bedrock);
                path[1] = address(busd);
                router.swapExactTokensForTokens(
                    collateralRock,
                    1,
                    path,
                    address(this),
                    block.timestamp + 15 minutes
                );
                collateralRock = 0;
            }

            uint256 projectBalance = busd.balanceOf(address(this));
            uint256 shouldGet = (projectBalance * myShare) / 100;
            require(
                projectBalance >= shouldGet,
                "Unfortunately the project has run out of all funds!"
            );

            busd.transfer(_msgSender(), shouldGet);
        } else {
            revert(
                "You can either pull while project is still raising or after the venture has exceeded promised time"
            );
        }
        delete investments[_msgSender()];
    }

    function pullRaise() external onlyOwner {
        require(
            keccak256(abi.encodePacked(ventureState)) ==
                keccak256(abi.encodePacked("RAISE_ACHEIVED")),
            "You have not yet reached the raise goal!"
        );
        uint256 actualRaised = busd.balanceOf(address(this));
        busd.transfer(_msgSender(), actualRaised);

        ventureState = "RAISE_PULLED";
    }

    function returnInvestments() external onlyOwner {
        require(
            keccak256(abi.encodePacked(ventureState)) ==
                keccak256(abi.encodePacked("RAISE_PULLED")),
            "Cannot return investments in current phase!"
        );
        uint256 userBalance = busd.balanceOf(_msgSender());
        uint256 expectedBalance = raiseAmount +
            ((raiseAmount * profitPercentage) / 100);

        if (userBalance < expectedBalance) {
            uint256 difference = expectedBalance - userBalance;

            address[] memory path = new address[](2);
            path[0] = address(busd);
            path[1] = address(bedrock);

            uint256 collateralPull = router.getAmountsOut(difference, path)[1];
            if (collateralPull > collateralRock) {
                collateralPull = collateralRock;
            }

            path[0] = address(bedrock);
            path[1] = address(busd);

            router.swapExactTokensForTokens(
                collateralPull,
                1,
                path,
                address(this),
                block.timestamp + 15 minutes
            );
            busd.transferFrom(_msgSender(), address(this), userBalance);
        } else {
            busd.transferFrom(_msgSender(), address(this), expectedBalance);
        }

        uint256 returnAmount = busd.balanceOf(address(this));
        for (uint256 i = 0; i < investors.length; i++) {
            uint256 initialInvestment = investments[investors[i]];
            if (initialInvestment == 0) {
                continue;
            }
            uint256 usdToReturn = (initialInvestment * returnAmount) /
                raiseAmount;
            busd.transfer(investors[i], usdToReturn);
            delete investments[investors[i]];
            delete investors[i];
        }

        if (bedrock.balanceOf(address(this)) > 0) {
            bedrock.transfer(_msgSender(), bedrock.balanceOf(address(this)));
        }

        if (busd.balanceOf(address(this)) > 0) {
            busd.transfer(_msgSender(), busd.balanceOf(address(this)));
        }

        if (returnAmount < expectedBalance) {
            ventureState = "ENDED_WITH_LOSS";
        } else {
            ventureState = "ENDED_WITH_PROFIT";
        }
    }
}