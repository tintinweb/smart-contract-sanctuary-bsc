/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: UNLICENSED
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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
// File: @openzeppelin/contracts/access/Ownable.sol
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
pragma solidity ^0.8.0;
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// File: contracts/interfaces/IRouter.sol
pragma solidity >=0.6.2;
interface IRouter {
    function WETH() external pure returns (address);
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
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
// File: contracts/interfaces/IWETH.sol
pragma solidity >=0.4.0;
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
}
// File: contracts/interfaces/IBEP20.sol
pragma solidity >=0.4.0;
interface IBEP20 {
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
// File: contracts/contract.sol
pragma solidity ^0.8.0;
contract HoneypotChecker is Ownable {
    constructor() {}
    uint256 MAX_INT = 2**256 - 1;
    struct CheckerResponse {
        uint256 buyGas;
        uint256 sellGas;
        uint256 estimatedBuy;
        uint256 exactBuy;
        uint256 estimatedSell;
        uint256 exactSell;
    }
    function destroy() external payable onlyOwner {
        address owner = owner();
        selfdestruct(payable(owner));
    }
    function _calculateGas(IRouter router, uint256 amountIn, address[] memory path) internal returns (uint256){
        uint256 usedGas = gasleft();
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, 
            0, 
            path, 
            address(this), 
            block.timestamp + 100
        );
        usedGas = usedGas - gasleft();
        return usedGas;
    }
    function check(address dexRouter, address[] calldata path) external payable returns(CheckerResponse memory) {
        require(path.length == 2);
        IRouter router = IRouter(dexRouter);
        IBEP20 baseToken = IBEP20(path[0]);
        IBEP20 targetToken = IBEP20(path[1]);
        uint tokenBalance;
        address[] memory routePath = new address[](2);
        uint expectedAmountsOut;
        if(path[0] == router.WETH()) {
            IWETH wbnb = IWETH(router.WETH());
            wbnb.deposit{value: msg.value}();
            tokenBalance = baseToken.balanceOf(address(this));
            expectedAmountsOut = router.getAmountsOut(msg.value, path)[1];
        } else {
            routePath[0] = router.WETH();
            routePath[1] = path[0];
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                routePath,
                address(this), 
                block.timestamp + 100
            );
            tokenBalance = baseToken.balanceOf(address(this));
            expectedAmountsOut = router.getAmountsOut(tokenBalance, path)[1];
        }
        // approve token
        baseToken.approve(dexRouter, MAX_INT);
        targetToken.approve(dexRouter, MAX_INT);
        uint estimatedBuy = expectedAmountsOut;
        uint buyGas = _calculateGas(router, tokenBalance, path);
        tokenBalance = targetToken.balanceOf(address(this));
        uint exactBuy = tokenBalance;
        //swap Path
        routePath[0] = path[1];
        routePath[1] = path[0];
        expectedAmountsOut = router.getAmountsOut(tokenBalance, routePath)[1];
        uint estimatedSell = expectedAmountsOut;
        uint sellGas = _calculateGas(router, tokenBalance, routePath);
        tokenBalance = baseToken.balanceOf(address(this));
        uint exactSell = tokenBalance;
        CheckerResponse memory response = CheckerResponse(
            buyGas,
            sellGas,
            estimatedBuy,
            exactBuy,
            estimatedSell,
            exactSell
        );
        return response;
    }
}