//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "TransferHelper.sol";
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

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}



interface IPancakeRouter {
    function getAmountsOut(uint amountIn, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
		
	function getAmountsIn(uint amountOut, address[] calldata path)
		external
		view
		returns (uint[] memory amounts);

 
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File: @openzeppelin/contracts/access/Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract SwapContract is Ownable {
    //address of the PCS V2 router
    // address private constant PANCAKE_V2_ROUTER =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    //address of WETH token.  This is needed because some times it is better to trade through WETH.
    //you might get a better price using WETH.
    //example trading from token A to WETH then WETH to token B might result in a better price
    address public WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;


    function  swap  (
        address[] calldata pathInput,
        address[] calldata router,
        uint256 _amountIn
    )  external onlyOwner  {
        require(pathInput.length >= 2, "INVALID_PATH <1");

        for (uint256 i = 0; i < pathInput.length - 1; i++) {
            uint256 balance = IERC20(pathInput[i]).balanceOf(address(this));
            if (pathInput[0] == WETH) balance = _amountIn;

            TransferHelper.safeApprove(
                pathInput[i],
                router[i],
                type(uint256).max
            );

            address[] memory path;
            path = new address[](2);
            path[0] = pathInput[i];
            path[1] = pathInput[i + 1];
            address receiver = address(this);

            //swap
            uint256 time = 1999999999;

            try
                IPancakeRouter(router[i]).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    balance,
                    0,
                    path,
                    receiver,
                    time
                )
            {} catch {}
            
        }
    }

    function saveETH () public onlyOwner {
        uint256 lastBalance = IERC20(WETH).balanceOf(address(this));
        TransferHelper.safeTransfer(WETH, msg.sender, lastBalance);
    }

    function saveTOKEN (address tkns) public onlyOwner {
        uint256 lastBalance = IERC20(tkns).balanceOf(address(this));
        TransferHelper.safeTransfer(tkns, msg.sender, lastBalance);
    }

    function updateWETH(address  newAddress) external onlyOwner {
        WETH = newAddress;
    }


    //this function will return the minimum amount from a swap
    //input the 3 parameters below and it will return the minimum amount out
    //this is needed for the swap function above
  function getAmountOutMin(
        address[] calldata pathInput,
        address router,
        uint256 _amountIn
    ) external view returns (uint256) {
        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (pathInput[0] == WETH || pathInput[1] == WETH) {
            path = new address[](2);
            path[0] = pathInput[0];
            path[1] = pathInput[1];
        } else {
            path = new address[](3);
            path[0] = pathInput[0];
            path[1] = WETH;
            path[2] = pathInput[1];
        }
        uint256[] memory amountOutMins = IPancakeRouter(router).getAmountsOut(
            _amountIn,
            path
        );
        return amountOutMins[path.length - 1];
    }

    function getAmountInMin(
        address[] calldata pathInput,
        address router,
        uint256 _amountOut
    ) external view returns (uint256) {
        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (pathInput[0] == WETH || pathInput[1] == WETH) {
            path = new address[](2);
            path[0] = pathInput[0];
            path[1] = pathInput[1];
        } else {
            path = new address[](3);
            path[0] = pathInput[0];
            path[1] = WETH;
            path[2] = pathInput[1];
        }
        uint256[] memory amountOutMins = IPancakeRouter(router).getAmountsIn(
            _amountOut,
            path
        );
        return amountOutMins[path.length - 1];
    }
}