/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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
        require(b != 0);
        return a % b;
    }
}
struct ESM {
    uint256 value;
    bool check;
}

library ElegantSafeMath {
    function safeAssign(ESM memory c, uint256 defaultValue)
        external
        pure
        returns (uint256)
    {
        (uint256 value, bool check) = extractESM(c);
        return check ? value : defaultValue;
    }

    function extractESM(ESM memory c) public pure returns (uint256, bool) {
        return (c.value, c.check);
    }

    function epow(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return epow(a, ESM(b, true));
    }

    function epow(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        ESM memory xC = ESM(a.value, true);
        if (!a.check || !b.check) {
            check = false;
        } else {
            if (b.value == 0) {
                xC.value = 1;
            } else if (b.value == 1) {
                xC.value = a.value;
            } else {
                for (uint256 i = 1; i < b.value; i++) {
                    xC = emul(xC, a);
                    if (!xC.check) {
                        break;
                    }
                }
            }
        }
        return xC;
    }

    function eadd(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return eadd(a, ESM(b, true));
    }

    function eadd(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        uint256 c = 0;
        if (!a.check || !b.check) {
            check = false;
        } else {
            unchecked {
                c = a.value + b.value;
            }
            if (c < a.value) {
                check = false;
            }
        }
        ESM memory returnValue = ESM(c, check);
        return returnValue;
    }

    function esub(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return esub(a, ESM(b, true));
    }

    function esub(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        uint256 c;
        if (!a.check || !b.check) {
            check = false;
        } else {
            if (b.value > a.value) {
                check = false;
            } else {
                c = a.value - b.value;
            }
        }
        ESM memory returnValue = ESM(c, check);
        return returnValue;
    }

    function emul(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return emul(a, ESM(b, true));
    }

    function emul(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        uint256 c;
        if (!a.check || !b.check) {
            check = false;
        } else {
            if (a.value == 0) {
                c = 0;
            } else {
                unchecked {
                    c = a.value * b.value;
                }
                if (c / a.value != b.value) {
                    check = false;
                }
            }
        }
        ESM memory returnValue = ESM(c, check);
        return returnValue;
    }

    function ediv(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return ediv(a, ESM(b, true));
    }

    function ediv(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        uint256 c;
        if (!a.check || !b.check) {
            check = false;
        } else {
            if (b.value == 0) {
                check = false;
            } else {
                c = a.value / b.value;
            }
        }
        ESM memory returnValue = ESM(c, check);
        return returnValue;
    }

    function emod(ESM memory a, uint256 b) internal pure returns (ESM memory) {
        return emod(a, ESM(b, true));
    }

    function emod(ESM memory a, ESM memory b)
        internal
        pure
        returns (ESM memory)
    {
        bool check = true;
        uint256 c;
        if (!a.check || !b.check) {
            check = false;
        } else {
            if (b.value == 0) {
                check = false;
            } else {
                c = a.value % b.value;
            }
        }
        ESM memory returnValue = ESM(c, check);
        return returnValue;
    }
}

library ElegantSafeMathForNumber {
    function epow(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.epow(ESM(a, true), ESM(b, true));
    }

    function epow(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.epow(ESM(a, true), b);
    }

    function eadd(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.eadd(ESM(a, true), ESM(b, true));
    }

    function eadd(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.eadd(ESM(a, true), b);
    }

    function esub(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.esub(ESM(a, true), b);
    }

    function esub(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.esub(ESM(a, true), ESM(b, true));
    }

    function emul(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.emul(ESM(a, true), b);
    }

    function emul(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.emul(ESM(a, true), ESM(b, true));
    }

    function ediv(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.ediv(ESM(a, true), b);
    }

    function ediv(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.ediv(ESM(a, true), ESM(b, true));
    }

    function emod(uint256 a, ESM memory b) internal pure returns (ESM memory) {
        return ElegantSafeMath.emod(ESM(a, true), b);
    }

    function emod(uint256 a, uint256 b) internal pure returns (ESM memory) {
        return ElegantSafeMath.emod(ESM(a, true), ESM(b, true));
    }

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
        require(b != 0);
        return a % b;
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

library Arrays {
    function findDownerBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {
        if (array.length == 0) {
            return 0;
        }
        uint256 low = 0;
        uint256 high = array.length - 1;
        while (low <= high) {
            uint256 mid = (low + high) / 2;
            if (array[mid] == element) {
                return mid;
            } else if (array[mid] > element) {
                if (mid == 0) {
                    return 0;
                } else {
                    high = mid - 1;
                }
            } else {
                low = mid + 1;
            }
        }
        return low == 0 ? low : low - 1;
    }
}

interface IPancakeSwapPair {
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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

    function mint(address to) external returns (uint256 liquidity);

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

interface IPancakeSwapRouter {
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

interface IPancakeSwapFactory {
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

contract Ownable {
    address private _owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract IERC20Metadata is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Test {
    using ElegantSafeMath for ESM;
    using ElegantSafeMathForNumber for uint256;
    address BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    IPancakeSwapRouter public router;
    bytes public swapData;

    constructor() {
        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }

    function buyBUSD() external returns (uint256) {
        address[] memory path;
        uint256 amount = address(this).balance;
        require(amount > 0);
        IERC20 tokenContract = IERC20(BUSD);
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = BUSD;

        uint256 balanceBefore = tokenContract.balanceOf(address(this));

        bytes memory payload = abi.encodeWithSignature(
            "swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)",
            0,
            path,
            msg.sender,
            block.timestamp
        );
        (bool success, bytes memory returnData) = address(router).call{
            value: amount
        }(payload);
        swapData = returnData;
        uint256 tokenAmount;
        if (success) {
            tokenAmount = tokenContract.balanceOf(address(this)).sub(
                balanceBefore
            );
            tokenContract.transfer(msg.sender, tokenAmount);
        } else {
            payable(msg.sender).transfer(amount);
        }
        return tokenAmount;
    }

    receive() external payable {}
}