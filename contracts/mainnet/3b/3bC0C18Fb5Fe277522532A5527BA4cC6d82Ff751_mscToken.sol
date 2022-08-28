/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract mscToken is IERC20, Ownable {
	using SafeMath for uint256;

	mapping(address => uint256) private _tOwned;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => bool) private _isSwapExempt;
	mapping(address => bool) private _isExcludedFromFee;

	address public addBurn = 0x000000000000000000000000000000000000dEaD;   
	address public ceoAdd = 0x2c48fe1877F8785de63D3368492032AebFC7a461;   
	address public ctoAdd = 0xD729F35301aa11EE1B523156fC5470e36B845AC3;   
	address public addFoundation = 0x4fA8AC23a664c6ecec6E024C8AbA4e844C96FE5c;   
	address public addNft = 0x1c58817CBE7A8b3dB7eEa34e4a1Ceb8223160c46;    
	address public addMining = 0xf934ECfBED3009d97fe58Bd849eFd2D737dF7456;    
	address public addWithdrow = 0x806470102714E6A203759d55d2aE10a59766B0B6;   
	address public addMint = 0x9bC6372A7779b9d3D8432Fc6183140f95d6aA401;     
	address public addAdmin = 0xEe9865c1F565DE7B93540C5e70FEAb691CF7430e;   

	string private _name = "My Score Coin";
	string private _symbol = "MSC";
	uint8 private _decimals = 18;

	uint256 public _burnFee = 500;
	uint256 public _NftFee = 500;
	uint256 public _FoundationFee = 100;

	uint256 private _tTotal = 1 * 10**7 * 10**18;


	constructor() {
		_tOwned[msg.sender] = _tTotal;
		_isExcludedFromFee[msg.sender] = true;
		_isExcludedFromFee[address(this)] = true;
		_isExcludedFromFee[address(0)] = true;
		_isExcludedFromFee[addBurn] = true;
		_isExcludedFromFee[ceoAdd] = true;
		_isExcludedFromFee[ctoAdd] = true;
		_isExcludedFromFee[addFoundation] = true;
		_isExcludedFromFee[addNft] = true;
		_isExcludedFromFee[addMining] = true;
		_isExcludedFromFee[addWithdrow] = true;
		_isExcludedFromFee[addMint] = true;
		_isExcludedFromFee[addAdmin] = true;
		emit Transfer(address(0), msg.sender, _tTotal);
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint256) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _tOwned[account];
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount,"ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve( msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function isExcludedFromFee(address account) public view returns (bool) {
		return _isExcludedFromFee[account];
	}
	function excludeFromFee(address account) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		_isExcludedFromFee[account] = true;
	}

	function includeFromFee(address account) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		_isExcludedFromFee[account] = false;
	}

	function isExcludedSwap(address account) public view returns (bool) {
		return _isSwapExempt[account];
	}
	function excludeSwap(address account) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		_isSwapExempt[account] = true;
	}

	function includeSwap(address account) public {
		require(msg.sender==ctoAdd, "Err: error cto address");
		_isSwapExempt[account] = false;
	}


	function setctoAdd(address _ctoAdd) public {
		require(msg.sender==ceoAdd, "Err: error ceo address");
		ctoAdd = _ctoAdd;
	}

	function _approve(address owner, address spender, uint256 amount ) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");

		_tokenTransfer(from, to, amount);
	}   

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		uint256 nNftfee = 0;
		uint256 nFoundationfee = _FoundationFee;
		uint256 nBurnfee = 0;
		uint256 nTotalfee = 0;
		
		if (_isSwapExempt[sender]) {
		    nNftfee = _NftFee;
		    nTotalfee = nNftfee.add(nFoundationfee);
		}
		if (nTotalfee==0) {
		    nBurnfee = _burnFee;
		    nTotalfee = nBurnfee.add(nFoundationfee);
		}
		if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
		    nNftfee = 0;
		    nFoundationfee = 0;
		    nBurnfee = 0;
		    nTotalfee = 0;
		}
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		if (nNftfee>0){
			_tOwned[addNft] = _tOwned[addNft].add(tAmount.div(10000).mul(nNftfee));
			emit Transfer(sender, addNft, tAmount.div(10000).mul(nNftfee));
		}
		if (nFoundationfee>0){
			_tOwned[addFoundation] = _tOwned[addFoundation].add(tAmount.div(10000).mul(nFoundationfee));
			emit Transfer(sender, addFoundation, tAmount.div(10000).mul(nFoundationfee));
		}
		if (nBurnfee>0){
			_tOwned[addBurn] = _tOwned[addBurn].add(tAmount.div(10000).mul(nBurnfee));
			emit Transfer(sender, addBurn, tAmount.div(10000).mul(nBurnfee));
		}
		uint256 recipientRate = 10000 - nTotalfee;
		_tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));

		emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
	}
}