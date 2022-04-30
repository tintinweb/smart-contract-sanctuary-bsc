/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// File: libraries/Ownable.sol



pragma solidity 0.6.12;

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
    /* --------- Access Control --------- */
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
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	* @dev Transfers ownership of the contract to a new account (`newOwner`).
	*/
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

// File: libraries/SafeMath.sol



pragma solidity 0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMathBabylonSwap {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// File: libraries/TransferHelper.sol



pragma solidity 0.6.12;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: interfaces/IERC20.sol



pragma solidity 0.6.12;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: interfaces/IBank.sol



pragma solidity 0.6.12;


interface IBank {
    function addReward(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) external;

    function addrewardtoken(address token, uint256 amount) external;
}

interface IFarm {
    function addLPInfo(
        IERC20 _lpToken,
        IERC20 _rewardToken0,
        IERC20 _rewardToken1
    ) external;

    function addReward(
        address _lp,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) external;

    function addrewardtoken(
        address _lp,
        address token,
        uint256 amount
    ) external;
}

// File: interfaces/IBabylonSwapV2Factory.sol



pragma solidity 0.6.12;

interface IBabylonSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
    function PERCENT100() external view returns (uint256);
    function DEADADDRESS() external view returns (address);
    
    function lockFee() external view returns (uint256);
    // function sLockFee() external view returns (uint256);
    function pause() external view returns (bool);
    function setRouter(address _router) external ;
    function feeTransfer() external view returns (address);

    function setFeeTransfer(address)external ;
    
}

// File: newSwapFeeTransfer.sol



pragma solidity 0.6.12;







contract BabylonSwapFeeTransfer is Ownable {
    using SafeMathBabylonSwap for uint256;

    uint256 public constant PERCENT100 = 1000000;
    address public constant DEADADDRESS =
        0x000000000000000000000000000000000000dEaD;

    address public factory;
    address public router;

    address public roulette;
    address public farm;
    address public evangelist;

    // Bank address
    address public miningBank;

    // Swap fee

    uint256 public miningbankFee = 300;
    uint256 public farmFee = 900;
    uint256 public rouletteFee = 100;
    uint256 public evangelistFee = 200;

    address public feeSetter;

    constructor() public {
        feeSetter = msg.sender;
    }

    function takeSwapFee(address lp, address token) public returns (uint256) {
        uint256 amount = IERC20(token).balanceOf(address(this));
        uint256 PERCENT = PERCENT100;
        uint256[10] memory fees;

        fees[0] = amount.mul(miningbankFee).div(PERCENT); //miningbankFee
        fees[1] = amount.mul(farmFee).div(PERCENT); //farmFee
        fees[2] = amount.mul(rouletteFee).div(PERCENT); //rouletteFee
        fees[3] = amount.mul(evangelistFee).div(PERCENT); //evangelistFee

        _approvetokens(token, miningBank, amount);
        IBank(miningBank).addrewardtoken(token, fees[0]);

        _approvetokens(token, farm, amount);
        IFarm(farm).addrewardtoken(lp, token, fees[1]);

        TransferHelper.safeTransfer(token, roulette, fees[2]);
    }

    function swaptotalFee() public view returns (uint256) {
        return miningbankFee + farmFee + rouletteFee + evangelistFee;
    }

    function _approvetokens(
        address _token,
        address _receiver,
        uint256 _amount
    ) private {
        if (
            _token != address(0x000) ||
            IERC20(_token).allowance(address(this), _receiver) < _amount
        ) {
            IERC20(_token).approve(_receiver, _amount);
        }
    }

    function configure(
        address _roulette,
        address _farm,
        address _miningBank,
        address _evangelist,
        address _factory,
        address _router
    ) external {
        require(msg.sender == feeSetter, "Only fee setter");

        roulette = _roulette;
        farm = _farm;
        miningBank = _miningBank;
        evangelist = _evangelist;

        factory = _factory;
        router = _router;
    }
}