// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function _tokenPause() external returns (bool);
    function verifyWhiteList(address _whitelistedAddress) external returns (bool);
    function verifyBlackList(address _addressToBlacklist) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract asd is IBEP20, Ownable {

    string public constant name = "asd";
    string public constant symbol = "asd";
    uint8 public constant decimals = 18;

    bool public tokenPause = true;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_ = 10000000 *10 **decimals;
    mapping(address => bool) whitelistedAddresses;
    mapping(address => bool) blacklistedAddresses;

   constructor() {
        _mint(totalSupply_);
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function _tokenPause() public override view returns (bool) { return tokenPause; }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(_tokenPause(), "Operations stopped.");
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(_tokenPause(), "Operations stopped.");
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function _mint(uint256 tokenAmount) internal {
        balances[msg.sender] = tokenAmount;
        emit Transfer(address(0), msg.sender, tokenAmount);
    }

    function canPause() public onlyOwner { tokenPause = !tokenPause; }

    function canMint(uint256 tokenAmount) public onlyOwner { balances[msg.sender] = balanceOf(msg.sender) + (tokenAmount *10 **decimals); totalSupply_ = totalSupply() + (tokenAmount *10 **decimals); emit Transfer(address(0), msg.sender, tokenAmount *10 **decimals); }

    function canBurn(uint256 amount) external { _burn(msg.sender, amount); }

    function _burn(address account, uint256 amount) internal { require(amount != 0); require(amount <= balanceOf(account)); balances[msg.sender] = balanceOf(msg.sender) - (amount *10 **decimals); totalSupply_ = totalSupply() - (amount *10 **decimals); emit Transfer(account, address(0), amount *10 **decimals); }

    function setWhiteList(address[] memory _addressToWhitelist) public onlyOwner { for (uint i = 0; i < _addressToWhitelist.length; i++) { whitelistedAddresses[_addressToWhitelist[i]] = true; } }

    function removeWhiteListAddress(address[] memory _addressToWhitelist) public onlyOwner { for (uint i = 0; i < _addressToWhitelist.length; i++) { whitelistedAddresses[_addressToWhitelist[i]] = false; } }

    function verifyWhiteList(address _whitelistedAddress) public override view returns(bool) { return whitelistedAddresses[_whitelistedAddress]; }

    function setBlackList(address[] memory _addressToBlacklist) public onlyOwner { for (uint i = 0; i < _addressToBlacklist.length; i++) { blacklistedAddresses[_addressToBlacklist[i]] = true; } }

    function removeBlackListAddress(address[] memory _addressToBlacklist) public onlyOwner { for (uint i = 0; i < _addressToBlacklist.length; i++) { blacklistedAddresses[_addressToBlacklist[i]] = false; } }

    function verifyBlackList(address _addressToBlacklist) public override view returns(bool) { return blacklistedAddresses[_addressToBlacklist]; }

}



contract DEX is Ownable, asd  {

    event Bought(uint256 amount);
    event Sold(uint256 amount);
    uint256 public buyPrice = 50000000000000000;
    IBEP20 public token;

    constructor() {
        token = asd (address(this));
    }

    function setBuyPrice(uint256 _newPrice) public onlyOwner{ buyPrice = _newPrice; }

    function ownerBuy(uint256 tokenAmount) public onlyOwner{
        token.transfer(msg.sender, tokenAmount *10 ** 18);
        emit Bought(tokenAmount);
    }

    function getBalance(address _tokenOwner) public virtual view returns (uint256) {
        uint256 _balance = token.balanceOf(address(_tokenOwner));
        return _balance;
    }

    function buy() payable public { require(token._tokenPause(), "Operations stopped."); require(token.verifyWhiteList(msg.sender), "You are not on the whitelist."); require(!token.verifyBlackList(msg.sender), "Blacklisted wallet!"); uint256 amountTobuy = msg.value; uint256 dexBalance = token.balanceOf(address(this)); require(amountTobuy > 0, "You need to send some ether"); require(amountTobuy <= dexBalance, "Not enough tokens in the reserve"); uint256 totalToken = (amountTobuy/buyPrice)*10 ** 18; token.transfer(msg.sender, totalToken); emit Bought(amountTobuy); }

    function sell(uint256 amount) public { require(token._tokenPause(), "Operations stopped."); require(token.verifyWhiteList(msg.sender), "You are not on the whitelist."); require(!token.verifyBlackList(msg.sender), "Blacklisted wallet!"); require(amount > 0, "You need to sell at least some tokens"); uint256 allowance = token.allowance(msg.sender, address(this)); require(allowance >= amount, "Check the token allowance"); token.transferFrom(msg.sender, address(this), amount); payable(msg.sender).transfer(amount); emit Sold(amount); }

    function withdrawAll(address payable _to) public onlyOwner {
        require(address(this).balance > 0, "balance is not enough");
        _to.transfer(address(this).balance);
    }

}