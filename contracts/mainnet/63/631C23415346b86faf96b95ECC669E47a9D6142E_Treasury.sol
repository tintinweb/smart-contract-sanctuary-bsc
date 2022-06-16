//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./staking.sol";

contract Treasury is Ownable {
    event Deposit(address from, uint256 amount);

    address public tokenAddress;

    constructor(address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        ERC20 Token = ERC20(tokenAddress);
        Token.transfer(to, amount);
    }

    function deposit(uint256 amount) external {
        ERC20 Token = ERC20(tokenAddress);
        Token.transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }
}

contract Cleanable is Ownable {
    // claim token that unexpectedly send to contract
    function claimToken(address tokenAddress, uint256 amount)
        external
        onlyOwner
    {
        ERC20(tokenAddress).transfer(owner(), amount);
    }

    // claim ETH that unexpectedly send to contract
    function claimETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }
}

contract StakingRouter is Cleanable {
    event AdminChanged(address admin, address newAdmin);
    event GameCreated(address stakingPoolAddress, GameInfo _gameInfo);

    event GameWin(uint256 gameID, uint256 amount);
    event GameLose(uint256 gameID, uint256 amount);

    address public admin;
    address public treasury;
    address public tokenAddress;

    address[] public games;
    mapping(address => uint256) public gameIds;

    constructor(address _admin, address _tokenAddress) public {
        admin = _admin;
        tokenAddress = _tokenAddress;

        Treasury _treasury = new Treasury(tokenAddress);
        treasury = address(_treasury);
    }

    function create(GameInfo memory _gameInfo) public {
        StakingPool newGame = new StakingPool(_gameInfo, tokenAddress);

        gameIds[address(newGame)] = games.length;
        games.push(address(newGame));

        emit GameCreated(address(newGame), _gameInfo);
    }

    /* ------------- admin actions ------------- */

    function gameWin(uint256 gameId, uint256 amount) public onlyAdmin {
        require(games[gameId] != address(0), "Invalide game ID");

        StakingPool game = StakingPool(games[gameId]);
        Treasury _treasury = Treasury(treasury);

        game.gameWithdraw(address(_treasury), amount);
        emit GameWin(gameId, amount);
    }

    function gameLose(uint256 gameId, uint256 amount) public onlyAdmin {
        require(games[gameId] != address(0), "Invalide game ID");

        StakingPool game = StakingPool(games[gameId]);
        Treasury _treasury = Treasury(treasury);

        _treasury.withdraw(address(game), amount);
        emit GameLose(gameId, amount);
    }

    function withdraw(address to, uint256 amount) public onlyAdmin {
        Treasury _treasury = Treasury(treasury);
        _treasury.withdraw(to, amount);
    }

    function batchWithdraw(address[] memory tos, uint256[] memory amounts)
        external
        onlyAdmin
    {
        uint256 length = tos.length;
        require(amounts.length == length, "Request parameter not valid");
        for (uint256 i = 0; i < length; i++) {
            withdraw(tos[i], amounts[i]);
        }
    }

    function batchGameUpdate(
        uint256[] memory _gameIds,
        uint256[] memory _amounts,
        bool[] memory _winstates
    ) external onlyAdmin {
        uint256 length = _gameIds.length;
        require(
            _amounts.length == length && _winstates.length == length,
            "sync error : invalide parameters"
        );

        for (uint256 i = 0; i < length; i++) {
            if (_winstates[i]) {
                gameWin(_gameIds[i], _amounts[i]);
            } else {
                gameLose(_gameIds[i], _amounts[i]);
            }
        }
    }

    /* ------------- ownable ------------- */

    function changeAdmin(address newAdmin) external {
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    modifier onlyAdmin() {
        require(admin == _msgSender(), "Factory: caller is not the admin");
        _;
    }

    /* ------------- view ------------ */
    function totalGames() external view returns (uint256) {
        return games.length;
    }

    function stakingInfos(uint256[] memory ids)
        external
        view
        returns (address[] memory pools, GameInfo[] memory infos)
    {
        pools = new address[](ids.length);
        infos = new GameInfo[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            pools[i] = games[i];
            infos[i] = StakingPool(pools[i]).getGameInfo();
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

struct GameInfo {
    address gameOwner;
    uint feeRate;
    string gameName;
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract StakingPool is Context, ERC20, Ownable {
    event Stake(address staker, uint amount);
    event UnStake(address staker, uint amount);
    event Win(uint amount);
    event Lose(uint amount);

    using SafeMath for uint256;

    GameInfo public gameInfo;
    address public xbtAddress;

    constructor(GameInfo memory _gameInfo, address _xbtAddress)
        public
        ERC20(
            string(abi.encodePacked("sXBT", _gameInfo.gameName)),
            "sXBT",
            0,
            0
        )
    {
        gameInfo.gameOwner = _gameInfo.gameOwner;
        gameInfo.feeRate = _gameInfo.feeRate;
        gameInfo.gameName = _gameInfo.gameName;
        xbtAddress = _xbtAddress;
    }

    function stake(uint256 amount) public returns (bool) {
        ERC20 XBTToken = ERC20(xbtAddress);

        //fee count
        uint feeAmount = (amount * gameInfo.feeRate) / 1000000;

        uint256 mintAmount = 0;

        if (_totalSupply == 0) mintAmount = amount.sub(feeAmount);
        else
            mintAmount =
                ((amount.sub(feeAmount)) * _totalSupply) /
                XBTToken.balanceOf(address(this));

        XBTToken.transferFrom(msg.sender, address(this), amount);
        XBTToken.transfer(owner(), feeAmount / 2);
        XBTToken.transfer(gameInfo.gameOwner, feeAmount / 2);

        _mint(_msgSender(), mintAmount);
        emit Stake(msg.sender, amount.sub(feeAmount));
        return true;
    }

    function unstake(uint256 amount) public returns (bool) {
        ERC20 XBTToken = ERC20(xbtAddress);

        uint256 withdrawAmount;
        withdrawAmount =
            (XBTToken.balanceOf(address(this)) * amount) /
            _totalSupply;
        XBTToken.transfer(msg.sender, withdrawAmount);

        _burn(_msgSender(), amount);
        emit UnStake(msg.sender, withdrawAmount);
        return true;
    }

    // xbt/sATARI rate (1000000)
    function getRate() public view returns (uint256 rate) {
        ERC20 XBTToken = ERC20(xbtAddress);
        rate = (XBTToken.balanceOf(address(this)) * 1000000) / _totalSupply;
    }

    /* ------------- game Actions ------------- */
    function gameWithdraw(address to, uint amount) public onlyOwner {
        ERC20 XBTToken = ERC20(xbtAddress);
        XBTToken.transfer(to, amount);
    }

    /* ------------- view ------------- */
    function getGameInfo() public view returns (GameInfo memory) {
        return gameInfo;
    }
}

//SPDX-License-Identifier: UNLICENSED
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
    /* --------- safe math --------- */
library SafeMath {
	/**
	* @dev Returns the addition of two unsigned integers, reverting on
	* overflow.
	*
	* Counterpart to Solidity's `+` operator.
	*
	* Requirements:
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
	* - Subtraction cannot overflow.
	*/
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
	* - The divisor cannot be zero.
	*/
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	* @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	* Reverts with custom message when dividing by zero.
	*
	* Counterpart to Solidity's `%` operator. This function uses a `revert`
	* opcode (which leaves remaining gas untouched) while Solidity uses an
	* invalid opcode to revert (consuming all remaining gas).
	*
	* Requirements:
	* - The divisor cannot be zero.
	*/
	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

contract ERC20 is Context{

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);

	using SafeMath for uint256;

	mapping (address => uint256) internal _balances;

	mapping (address => mapping (address => uint256)) internal _allowances;

	uint256 internal _totalSupply;
	uint8 internal _decimals = 18;
	string internal _symbol;
	string internal _name;
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _totalSupply = totalSupply;
        _decimals = decimals;
		_balances[msg.sender] = _totalSupply;
    }

	function decimals() external view returns (uint8) {
		return _decimals;
	}

	function symbol() external view returns (string memory) {
		return _symbol;
	}

	function name() external view returns (string memory) {
		return _name;
	}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) external returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
		return true;
	}

	function burn(uint256 amount) external {
		_burn(msg.sender,amount);
	}

	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: mint to the zero address");

		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal {
		require(account != address(0), "BEP20: burn from the zero address");

		_balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal {
		require(owner != address(0), "BEP20: approve from the zero address");
		require(spender != address(0), "BEP20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _burnFrom(address account, uint256 amount) internal {
		_burn(account, amount);
		_approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
	}

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

}