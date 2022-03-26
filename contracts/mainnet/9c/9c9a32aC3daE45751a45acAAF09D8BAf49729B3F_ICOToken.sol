//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./System.sol";
import "./MapManager.sol";
import "./RelationshipManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IBigSale {
    function buy(address parent) external payable;
    function withdraw() external;
}

contract ICOToken is ERC20, Ownable, System, IBigSale, RelationshipManager, MapManager {
    IERC20 public Token;
    mapping(address => uint256) public buyHistory;

    uint256 public price;
    uint256 public rewardsPercent;
    uint256 public divBase = 1e4;
    uint256 public buyLimitMin = 0.1 ether;
    uint256 public buyLimitMax = 3 ether;

    uint256 public ethTotal;
    uint256 steps = 1;
    address feeTo;
    address feeToDefault;

    event JoinICO(address user, address parent, uint256 ethAll, uint256 tokenAmount, uint256 ethReward);
    event Withdrawed(address user, uint256 amount);

    constructor(uint256 _price, uint256 _rewardsPercent) ERC20("ICOToken", "IT") {
        updateRate(_price, _rewardsPercent);
        feeTo = _msgSender();
        feeToDefault = _msgSender();
    }

    function updateTokenAddress(address _tokenAddress) public onlyOwner {
        Token = IERC20(_tokenAddress);
    }

    function updateFeeTo(address _feeTo, address _feeToDefault) public onlyOwner {
        feeTo = _feeTo;
        feeToDefault = _feeToDefault;
    }

    function updateStatus(uint256 _step) public onlyOwner {
        steps = _step;
    }

    function updateRate(uint256 _price, uint256 _rewardsPercent) public onlyOwner {
        price = _price;
        rewardsPercent = _rewardsPercent;
    }

    function withdraw() public virtual override {
        require(steps == 8, "not permitted");
        uint256 amount = balanceOf(_msgSender());
        _burn(_msgSender(), amount);
        Token.transfer(_msgSender(), amount);

        emit Withdrawed(_msgSender(), amount);
    }

    function buy(address parent) public virtual override payable {
        require(steps == 1, "not permitted");
        require(msg.value >= buyLimitMin, "bnb must greater or equal 0.1 bnb");
        require(msg.value <= buyLimitMax, "bnb must less or equal 3 bnb");
        require(buyHistory[_msgSender()] < buyLimitMax, "bnb must less or equal 3 bnb");
        mapAdd(_msgSender());

        buyHistory[_msgSender()] += msg.value;

        if (parent == address(0) || parent == _msgSender()) parent = address(this);
        _updateRelationship(parent, _msgSender());

        uint256 amount = msg.value * rewardsPercent / divBase;
        uint256 amountReal = msg.value - amount;
        ethTotal += amountReal;
        _distributeToken(_msgSender(), msg.value);
        _distributeEth(parent, amount);
        payable(feeTo).transfer(amountReal);

        emit JoinICO(_msgSender(), parent, msg.value, amount * price, amountReal);
    }
    function _distributeToken(address user, uint256 eth) internal {
        uint256 tokenAmount = eth * price;
        _mint(user, tokenAmount);
    }
    function _distributeEth(address user, uint256 eth) internal {
        if (eth > 0 && user != address(this) && mapExists(user)) payable(user).transfer(eth);
        else payable(feeToDefault).transfer(eth);
    }

    function balanceOfMulti(address token, address[] memory user) public view returns(uint256[] memory) {
        uint256[] memory res = new uint256[](user.length);
        IERC20 T = IERC20(token);
        for (uint i=0;i<user.length;i++) {
            res[i] = T.balanceOf(user[i]);
        }
        return res;
    }

}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _move(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _move(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        _afterTokenTransfer(address(0), account, amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract System is Ownable {
    receive() external payable {}
    fallback() external payable {}
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOwner {
        require(address(token_) != address(this), "not permitted");
        token_.transfer(_recipient, token_.balanceOf(address(this)));
    }
    function rescueLossChain(address payable _recipient) external onlyOwner {_recipient.transfer(address(this).balance);}
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract MapManager {
    address[] public mapLists;

    function mapAdd(address _map) internal {
        if (!mapExists(_map))
            mapLists.push(_map);
    }

    function mapRemove(address _map) internal {
        for (uint i=0;i<mapLists.length;i++) {
            if (mapLists[i] == _map) {
                mapLists[i] = mapLists[mapLists.length-1];
                break;
            }
        }
        mapLists.pop();
    }

    function mapExists(address addr) public view returns(bool) {
        for (uint i=0;i<mapLists.length;i++) {
            if (mapLists[i] == addr) return true;
        }
        return false;
    }

    function mapListsLength() public view returns(uint256) {
        return mapLists.length;
    }

    function getMapLists() public view returns(address[] memory) {
        return mapLists;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./MemberManager.sol";

abstract contract RelationshipManager is MemberManager {
    struct Member {
        address user;
        address parent;
        address[] children;
    }
    mapping(address => Member) public relationship;

    function _updateRelationship(address parent, address child) internal {
        if (_userJoin(child)) {
            relationship[child].parent = parent;
            if (parent != child) relationship[parent].children.push(child);
        }
    }

    function getChildrenLength(address user) public view returns(uint256) {
        return relationship[user].children.length;
    }

    function getChildren(address user) public view returns(address[] memory) {
        return relationship[user].children;
    }

    function getMemberListsWithDetail(uint256 limit, uint256 page) public view returns(Member[] memory) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getMemberLength();
        uint256 offset = (page - 1) * limit;
        require(offset < total, "over offset");
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        Member[] memory res = new Member[](dataRealLength);
        for (uint i=0;i<dataRealLength;i++) {
            uint256 idx = i+offset;
            res[i] = relationship[members[idx]];
        }
        return res;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract MemberManager {
    uint256 public totalMembers;
    address[] public members;
    mapping(address => bool) public isMemberExists;

    bool onJoining;
    modifier onlyNotJoining() {
        require(!onJoining, "join re entry");
        onJoining = true;
        _;
        onJoining = false;
    }

    function _userJoin(address child) internal onlyNotJoining returns(bool) {
        if (!isMemberExists[child]) {
            totalMembers++;
            members.push(child);
            isMemberExists[child] = true;
            return true;
        }
        return false;
    }

    function getMemberLength() public view returns(uint256) {
        return members.length;
    }

    function getMemberLists(uint256 limit, uint256 page) public view returns(address[] memory) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getMemberLength();
        uint256 offset = (page - 1) * limit;
        require(offset < total, "over offset");
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        address[] memory res = new address[](dataRealLength);
        for (uint i=0;i<dataRealLength;i++) {
            uint256 idx = i+offset;
            res[i] = members[idx];
        }
        return res;
    }
}