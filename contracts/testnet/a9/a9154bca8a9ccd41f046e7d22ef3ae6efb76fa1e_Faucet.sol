// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '../common/libraries/PullPaymentUtils.sol';

interface IERC20 {
	function transfer(address to, uint256 value) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Faucet is Ownable {
	using PullPaymentUtils for address[];

	/*
   	=======================================================================
   	======================== Public variatibles ===========================
   	=======================================================================
 	*/

	uint256 public constant waitTime = 1 days;

	/// list of faucet tokens
	address[] public faucetTokens;

	/// faucet address => faucet amount
	mapping(address => uint256) public faucetAmount;

	/// userAddress => last claimed time
	mapping(address => uint256) public lastAccessTime;

	/*
   	=======================================================================
   	======================== Constructor/Initializer ======================
   	=======================================================================
 	*/
	constructor(address[] memory _tokenInstances, uint256[] memory _tokenAmounts) public {
		addFaucets(_tokenInstances, _tokenAmounts);
	}

	/*
   	=======================================================================
   	======================== Events =======================================
 	  =======================================================================
 	*/
	event FaucetAdded(address faucet, uint256 amount);
	event FaucetRemoved(address faucet);
	event FaucetClaimed(address account, uint256 amount, uint256 timestamp);

	/*
   	=======================================================================
   	======================== Public Methods ===============================
   	=======================================================================
 	*/

	/**
	 * @notice This function allows owner to add new list of faucets for claiming
	 * @param _tokenInstances- faucet token address
	 * @param _tokenAmounts- amount of faucets to be claimed
	 */
	function addFaucets(address[] memory _tokenInstances, uint256[] memory _tokenAmounts)
		public
		onlyOwner
	{
		require(_tokenInstances.length == _tokenAmounts.length, 'Faucet: INVALID_TOKEN_DATA');
		for (uint256 i = 0; i < _tokenInstances.length; i++) {
			addFaucet(_tokenInstances[i], _tokenAmounts[i]);
		}
	}

	/**
	 * @notice This function allows owner to add new faucet for claiming
	 * @param _tokenAddress- faucet token address
	 * @param _amount- amount of faucets to be claimed
	 */
	function addFaucet(address _tokenAddress, uint256 _amount) public onlyOwner {
		require(_amount > 0, 'Faucet:INVALID_FAUCET_AMOUNT');
		faucetTokens.addAddressInList(_tokenAddress);
		faucetAmount[_tokenAddress] = _amount;
		emit FaucetAdded(_tokenAddress, _amount);
	}

	/**
	 * @notice This function allows owner to remove faucet from claiming
	 * @param _tokenAddress- faucet token address
	 */
	function removeFaucet(address _tokenAddress) external onlyOwner {
		faucetTokens.removeAddressFromList(_tokenAddress);
		delete faucetAmount[_tokenAddress];
		emit FaucetRemoved(_tokenAddress);
	}

	/**
	 * @notice This function allows owner to update faucet claiming amount
	 * @param _faucet- faucet token address
	 * @param _newAmount- new faucet amount
	 */
	function updateFaucetAmount(address _faucet, uint256 _newAmount) external onlyOwner {
		require(_newAmount > 0, 'Faucet:INVALID_FAUCET_AMOUNT');
		(bool exists, ) = faucetTokens.isAddressExists(_faucet);
		require(exists, 'Faucet: INVALID_CLAIM');
		faucetAmount[_faucet] = _newAmount;
	}

	/**
	 * @notice This function allows users to claim the faucets
	 * @param _faucetToken- faucet token to claim
	 */
	function requestTokens(address _faucetToken) external {
		(bool exists, ) = faucetTokens.isAddressExists(_faucetToken);
		require(exists, 'Faucet: INVALID_CLAIM');
		require(allowedToWithdraw(msg.sender), 'Faucet: MUST_WAIT');
		IERC20(_faucetToken).transfer(msg.sender, faucetAmount[_faucetToken]);
		lastAccessTime[msg.sender] = block.timestamp + waitTime;
		emit FaucetClaimed(msg.sender, faucetAmount[_faucetToken], block.timestamp);
	}

	function allowedToWithdraw(address _address) public view returns (bool) {
		return block.timestamp >= lastAccessTime[_address];
	}

	function getFaucetList() external view returns (address[] memory) {
		return faucetTokens;
	}

	function isFaucetSupported(address _token) external view returns (bool supported) {
		(supported, ) = faucetTokens.isAddressExists(_token);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PullPaymentUtils {
	/**
	 * @notice This method allows admin to except the addresses to have multiple tokens of same NFT.
	 * @param _address indicates the address to add.
	 */
	function addAddressInList(address[] storage _list, address _address) internal {
		require(_address != address(0), 'PullPaymentUtils: CANNOT_EXCEPT_ZERO_ADDRESS');

		(bool isExists, ) = isAddressExists(_list, _address);
		require(!isExists, 'PullPaymentUtils: ADDRESS_ALREADY_EXISTS');

		_list.push(_address);
	}

	/**
	 * @notice This method allows user to remove the particular address from the address list
	 */
	function removeAddressFromList(address[] storage _list, address _item) internal {
		uint256 listItems = _list.length;
		require(listItems > 0, 'PullPaymentUtils: EMPTY_LIST');

		// check and remove if the last item is item to be removed.
		if (_list[listItems - 1] == _item) {
			_list.pop();
			return;
		}

		(bool isExists, uint256 index) = isAddressExists(_list, _item);
		require(isExists, 'PullPaymentUtils: ITEM_DOES_NOT_EXISTS');

		// move supported token to last
		if (listItems > 1) {
			address temp = _list[listItems - 1];
			_list[index] = temp;
		}

		//remove supported token
		_list.pop();
	}

	/**
	 * @notice This method allows to check if particular address exists in list or not
	 * @param _list indicates list of addresses
	 * @param _item indicates address
	 * @return isExists - returns true if item exists otherwise returns false. index - index of the existing item from the list.
	 */
	function isAddressExists(address[] storage _list, address _item)
		internal
		view
		returns (bool isExists, uint256 index)
	{
		for (uint256 i = 0; i < _list.length; i++) {
			if (_list[i] == _item) {
				isExists = true;
				index = i;
				break;
			}
		}
	}
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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